#!/bin/bash
# =============================================================================
# ☕ deploy-workstation.sh — Infrastucture Deployment
# =============================================================================
# This is the actual deployment process that creates your workstation.
# Idempotent, self-recovering, and caffeinated.
# Runs locally or in Cloud Build.
# =============================================================================

set -euo pipefail

# Source library and config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.env"
TOTAL_STEPS=12
source "${SCRIPT_DIR}/lib.sh"

# Parse flags
PROJECT_ID=""
REGION_FLAG=""
WEBHOOK_URL=""
USER_ACCOUNT=""
PROFILE="full"
CUSTOM_MODULES=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project) PROJECT_ID="$2"; shift 2 ;;
        --region)  REGION_FLAG="$2"; shift 2 ;;
        --webhook) WEBHOOK_URL="$2"; shift 2 ;;
        --account) USER_ACCOUNT="$2"; shift 2 ;;
        --profile) PROFILE="$2"; shift 2 ;;
        --modules) CUSTOM_MODULES="$2"; shift 2 ;;
        *) shift ;;
    esac
done

REGION="${REGION_FLAG:-$REGION}" # Use flag or default from config.env

# Bean blends (profiles)
declare -A PROFILE_MODULES
PROFILE_MODULES[minimal]="core,desktop"
PROFILE_MODULES[dev]="core,desktop,tmux,ai-tools-minimal"
PROFILE_MODULES[ai]="core,desktop,tmux,ides,ai-tools"
PROFILE_MODULES[full]="core,desktop,tmux,ides,ai-tools,languages,tailscale"

if [ "$PROFILE" = "custom" ]; then
    MODULES="${CUSTOM_MODULES}"
else
    MODULES="${PROFILE_MODULES[$PROFILE]:-${PROFILE_MODULES[full]}}"
fi

profile_has_module() {
    echo ",$MODULES," | grep -q ",$1,"
}

IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/workstation:latest"
PASS=0; FAIL=0; WARN=0
START_TIME=$(date +%s)

if [ -d "/workspace/repo/cloudworkstations/sway" ]; then
    REPO_DIR="/workspace/repo"
else
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

notify() {
    notify_webhook "$WEBHOOK_URL" "$1" "$2" "$3"
}

notify_and_fail() {
    local elapsed=$(( $(date +%s) - START_TIME ))
    local mins=$(( elapsed / 60 ))
    notify "☕ Deployment Failed" "Project: ${PROJECT_ID}" \
        "<b>Step Failed:</b> ${1}<br><b>Time:</b> ${mins}m<br><br>The brew spilled! Check Cloud Build logs."
    exit 1
}

ws_ssh() {
    retry 3 10 timeout 300 gcloud workstations ssh "$WORKSTATION" \
        --project="$PROJECT_ID" --region="$REGION" \
        --cluster="$CLUSTER" --config="$CONFIG" \
        --quiet \
        --command="$1" -- -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
}

# SSH helper for long-running commands (15 min timeout, fewer retries)
ws_ssh_long() {
    retry 2 15 timeout 900 gcloud workstations ssh "$WORKSTATION" \
        --project="$PROJECT_ID" --region="$REGION" \
        --cluster="$CLUSTER" --config="$CONFIG" \
        --quiet \
        --command="$1" -- -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
}

ws_scp() {
    retry 3 10 gcloud workstations scp "$1" "${WORKSTATION}:$2" \
        --project="$PROJECT_ID" --region="$REGION" \
        --cluster="$CLUSTER" --config="$CONFIG" \
        --quiet -- -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
}

# Helper to pipe data into a file on the workstation
ws_pipe() {
    local dest_cmd="$1"
    gcloud workstations ssh "$WORKSTATION" \
        --project="$PROJECT_ID" --region="$REGION" \
        --cluster="$CLUSTER" --config="$CONFIG" \
        --quiet \
        --command="$dest_cmd" -- -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
}

test_pass() { PASS=$((PASS + 1)); log_info "  ✅ PASS: $1"; }
test_fail() { FAIL=$((FAIL + 1)); log_error "  ❌ FAIL: $1"; }
test_warn() { WARN=$((WARN + 1)); log_warn "  ⚠️  WARN: $1"; }

# =========================================================================
step "Provisioning APIs"
# =========================================================================
log_info "Enabling the GCP APIs..."
retry 3 5 gcloud services enable \
    workstations.googleapis.com \
    artifactregistry.googleapis.com \
    compute.googleapis.com \
    cloudscheduler.googleapis.com \
    cloudbuild.googleapis.com \
    iam.googleapis.com \
    logging.googleapis.com \
    cloudresourcemanager.googleapis.com \
    --project="$PROJECT_ID"

PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
log_info "  ✅ APIs are warm and ready"

COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# =========================================================================
step "Preparing the Registry (Artifact Registry)"
# =========================================================================
if gcloud artifacts repositories describe "$AR_REPO" \
    --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
    log_info "  ✅ Registry already exists"
else
    log_info "  🏗️  Creating the repository..."
    retry 2 5 gcloud artifacts repositories create "$AR_REPO" \
        --repository-format=docker \
        --location="$REGION" \
        --project="$PROJECT_ID" \
        --description="Workstation Coffee Beans"
fi

# =========================================================================
step "Building the Docker Image"
# =========================================================================
log_info "🔎 Checking if we already have fresh beans (Image)..."
if gcloud artifacts docker images list "${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/workstation" \
    --project="$PROJECT_ID" --format="value(package)" --limit=1 2>/dev/null | grep -q "workstation"; then
    log_info "  ✅ Image found in registry. Skipping the froth to save time."
    test_pass "Docker image already exists"
else
    log_info "  🏗️  Building the workstation image (this takes a while)..."
    cd "${REPO_DIR}"
    if retry 2 30 gcloud builds submit \
        --config=cloudworkstations/sway/cloudbuild-image.yaml \
        --substitutions="_REGION=${REGION},_AR_REPO=${AR_REPO}" \
        --project="$PROJECT_ID" \
        --region="$REGION" \
        --timeout=1800 \
        --quiet; then
        test_pass "Docker image frothed and pushed"
        notify "🍦 Progress: Image Ready" "Project: ${PROJECT_ID}" "The image is ready. Deploying the infrastructure next..."
    else
        test_fail "Docker image failed to build"
        notify_and_fail "Docker build"
    fi
fi

# =========================================================================
step "Setting up the Water Line (VPC + NAT)"
# =========================================================================
if gcloud compute networks describe default --project="$PROJECT_ID" >/dev/null 2>&1; then
    log_info "  ✅ Default network exists"
else
    log_info "  🏗️  Creating the network..."
    gcloud compute networks create default --subnet-mode=auto --project="$PROJECT_ID" --quiet 2>&1 | head -3
fi

if gcloud compute routers describe ws-router --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
    log_info "  ✅ Router exists"
else
    gcloud compute routers create ws-router --network=default --region="$REGION" --project="$PROJECT_ID"
fi

if gcloud compute routers nats describe ws-nat --router=ws-router --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
    log_info "  ✅ NAT exists"
else
    gcloud compute routers nats create ws-nat --router=ws-router --region="$REGION" \
        --auto-allocate-nat-external-ips --nat-all-subnet-ip-ranges --project="$PROJECT_ID"
fi

# =========================================================================
step "Creating the Cluster"
# =========================================================================
if gcloud workstations clusters describe "$CLUSTER" --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
    log_info "  ✅ Cluster exists"
else
    log_info "  🏗️  Creating cluster (5-10 min)..."
    gcloud workstations clusters create "$CLUSTER" --region="$REGION" --project="$PROJECT_ID"
fi

# =========================================================================
step "Setting the Temperature (Config)"
# =========================================================================
# Prepare environment variables for injection
ENV_VARS="GOOGLE_CLOUD_PROJECT=${PROJECT_ID},GOOGLE_CLOUD_LOCATION=${REGION}"
[ -n "${GOOGLE_API_KEY:-}" ] && ENV_VARS="${ENV_VARS},GOOGLE_API_KEY=${GOOGLE_API_KEY}"

if gcloud workstations configs describe "$CONFIG" --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
    log_info "  ✅ Config exists — updating environment variables..."
    retry 2 10 gcloud workstations configs update "$CONFIG" \
        --cluster="$CLUSTER" --region="$REGION" \
        --service-account="$COMPUTE_SA" \
        --project="$PROJECT_ID" \
        --clear-container-env \
        --container-env="$ENV_VARS" \
        --quiet
else
    log_info "  🏗️  Creating config..."
    retry 2 10 gcloud workstations configs create "$CONFIG" \
        --cluster="$CLUSTER" --region="$REGION" \
        --machine-type="$MACHINE_TYPE" \
        --accelerator-type="$ACCELERATOR_TYPE" --accelerator-count="$ACCELERATOR_COUNT" \
        --pd-reclaim-policy=retain --pd-disk-type="$DISK_TYPE" --pd-disk-size="$DISK_SIZE" \
        --container-custom-image="$IMAGE" --service-account="$COMPUTE_SA" \
        --project="$PROJECT_ID" \
        --container-env="$ENV_VARS" \
        --quiet
fi

# =========================================================================
step "Pouring the Workstation"
# =========================================================================
if gcloud workstations describe "$WORKSTATION" --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
    log_info "  ✅ Workstation exists"
else
    gcloud workstations create "$WORKSTATION" --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID"
fi

WS_STATE=$(gcloud workstations describe "$WORKSTATION" --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID" --format="value(state)" 2>/dev/null)
if [ "$WS_STATE" != "STATE_RUNNING" ]; then
    log_info "🔥 Starting the workstation..."
    gcloud workstations start "$WORKSTATION" --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID"
fi

log_info "🔌 Waiting for SSH access..."
for i in $(seq 1 60); do
    if ws_ssh "echo ready" >/dev/null 2>&1; then
        test_pass "SSH access is warm"
        break
    fi
    sleep 10
done

# =========================================================================
step "Installing Nix"
# =========================================================================
log_info "📦 Installing the Nix package manager..."
ws_scp "${SCRIPT_DIR}/remote/setup-nix.sh" "~/setup-nix.sh"
ws_ssh "bash ~/setup-nix.sh"
test_pass "Nix is installed"

# =========================================================================
step "Syncing Home Manager"
# =========================================================================
log_info "🔄 Syncing packages..."
IDES_ENABLED=$(profile_has_module "ides" && echo "true" || echo "false")
ws_scp "${SCRIPT_DIR}/remote/setup-home-manager.sh" "~/setup-home-manager.sh"
ws_ssh_long "bash ~/setup-home-manager.sh \"$MODULES\" \"$IDES_ENABLED\""
test_pass "Packages synced"

# =========================================================================
step "Enabling Persistence"
# =========================================================================
log_info "💾 Copying Nix store to persistent disk..."
ws_ssh_long 'sudo cp -a /nix /home/user/nix'
test_pass "Persistence ready"

# =========================================================================
step "Polishing the Machine"
# =========================================================================
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
log_info "✨ Deploying boot scripts and fonts from $BASE_DIR..."
tar czf - -C "${BASE_DIR}/workstation-image/boot" . | ws_pipe "mkdir -p ~/boot && tar xzf -"
tar czf - -C "${BASE_DIR}/dev-fonts" . | ws_pipe "mkdir -p ~/boot/fonts && tar xzf -"

log_info "🚀 Running internal setup..."
ws_ssh_long "sudo bash ~/boot/setup.sh"
test_pass "Setup script finished"

# =========================================================================
step "Setting the Schedule"
# =========================================================================
log_info "⏰ Configuring weekday auto-start/stop..."
WS_API_BASE="https://workstations.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs/${CONFIG}/workstations/${WORKSTATION}"

gcloud scheduler jobs create http ws-weekday-start \
    --project="$PROJECT_ID" --location="$REGION" --schedule="0 6 * * 1-5" --time-zone="America/Los_Angeles" \
    --uri="${WS_API_BASE}:start" --http-method=POST --oauth-service-account-email="$COMPUTE_SA" --quiet 2>/dev/null || true

gcloud scheduler jobs create http ws-weekday-stop \
    --project="$PROJECT_ID" --location="$REGION" --schedule="0 21 * * 1-5" --time-zone="America/Los_Angeles" \
    --uri="${WS_API_BASE}:stop" --http-method=POST --oauth-service-account-email="$COMPUTE_SA" --quiet 2>/dev/null || true
test_pass "Scheduler jobs set"

# =========================================================================
step "DEPLOYMENT COMPLETE!"
# =========================================================================
WS_HOST=$(gcloud workstations describe "$WORKSTATION" --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID" --format="value(host)")
log_info "🎉 Your workstation is ready! Grab your coffee and go to: https://${WS_HOST}"

notify "☕ Workstation Ready!" "Project: ${PROJECT_ID}" \
    "Your workstation is ready to serve!<br><br><b>URL:</b> <a href=\"https://${WS_HOST}\">https://${WS_HOST}</a>"

log_info "🔌 Powering down the machine to save costs..."
gcloud workstations stop "$WORKSTATION" --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID" --quiet
log_info "✅ Machine is OFF. Enjoy!"

