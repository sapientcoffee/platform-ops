#!/bin/bash
# =============================================================================
# ☕ Cloud Workstation — Management Tool
# =============================================================================
# Main entry point for GPU Cloud Workstations.
# Provision infrastructure, delete resources, or
# configure automated image updates.
#
# Usage:
#   bash scripts/workstation.sh setup    -p PROJECT_ID [-w WEBHOOK]
#   bash scripts/workstation.sh teardown -p PROJECT_ID [-w WEBHOOK] [-y]
#
# Requirements:
#   - gcloud CLI authenticated with Owner role on the target project
#   - NVIDIA T4 GPU quota in us-central1 (at least 1)
# =============================================================================

set -euo pipefail

# Source library and config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.env"
source "${SCRIPT_DIR}/lib.sh"

# Auto-detect repo URL from git remote
REPO_URL=$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null || echo "https://github.com/sapientcoffee/platform-ops.git")

usage() {
    echo "Usage:"
    echo "  bash scripts/workstation.sh setup    -p PROJECT_ID [-w WEBHOOK_URL]"
    echo "  bash scripts/workstation.sh teardown -p PROJECT_ID [-w WEBHOOK_URL] [-y] [--dry-run]"
    echo ""
    echo "Commands:"
    echo "  setup      🛎️  Provision infrastructure and deploy workstation"
    echo "  teardown   🧹  Delete all workstation resources"
    echo ""
    echo "Optional (Separate Process):"
    echo "  triggers   ⏰  Configure automated weekly image updates"
    echo ""
    echo "Required:"
    echo "  -p, --project PROJECT_ID    GCP project ID"
    echo ""
    echo "Optional:"
    echo "  --profile PROFILE           Bean blend: minimal, dev, ai, full (default: full)"
    echo "  --modules MODULES           Custom flavor shots (comma-separated modules)"
    echo "  -w, --webhook URL           Google Chat / Slack webhook for status updates"
    echo "  -y, --yes                   Skip confirmation prompt (teardown only)"
    echo "  --dry-run                   Show what would be deleted (teardown only)"
    exit 1
}

# --- Parse command ---
COMMAND="${1:-}"
if [ -z "$COMMAND" ] || [[ "$COMMAND" == -* ]]; then
    log_error "First argument must be 'setup' or 'teardown'"
    usage
fi
shift

# --- Parse flags ---
PROJECT_ID=""
WEBHOOK_URL=""
PROFILE="full"
CUSTOM_MODULES=""
SKIP_CONFIRM=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--project)  PROJECT_ID="$2"; shift 2 ;;
        --profile)     PROFILE="$2"; shift 2 ;;
        --modules)     CUSTOM_MODULES="$2"; PROFILE="custom"; shift 2 ;;
        -w|--webhook)  WEBHOOK_URL="$2"; shift 2 ;;
        -y|--yes)      SKIP_CONFIRM=true; shift ;;
        --dry-run)     DRY_RUN=true; shift ;;
        -h|--help)     usage ;;
        *) log_warn "Unknown option: $1"; shift ;;
    esac
done

export DRY_RUN # Export so lib.sh run_cmd can use it

# Validate inputs
if [ -z "$PROJECT_ID" ]; then log_error "--project is required"; usage; fi

# =========================================================================
# TRIGGERS
# =========================================================================
if [ "$COMMAND" = "triggers" ]; then
    log_info "🔥 Setting up the automatic roaster (triggers)..."
    bash "${SCRIPT_DIR}/configure-automation.sh" --project "$PROJECT_ID" --region "$REGION"
    exit 0
fi

# =========================================================================
# PRE-FLIGHT CHECKS
# =========================================================================
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE} ☕ Cloud Workstation Cafe — ${COMMAND^^}${NC}"
echo " Project: $PROJECT_ID"
echo " Region:  $REGION"
echo " Blend:   $PROFILE"
[ -n "$CUSTOM_MODULES" ] && echo " Shots:   $CUSTOM_MODULES"
[ -n "$WEBHOOK_URL" ] && echo " Webhook: 🔔 Enabled"
[ "$DRY_RUN" = true ] && echo -e " Mode:    ${YELLOW}DRY RUN${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""

check_dependencies gcloud git curl tar jq

log_info "🧐 Checking your credentials..."
ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || true)
if [ -z "$ACCOUNT" ]; then
    log_error "No active gcloud account. Run: gcloud auth login"
    exit 1
fi
log_info "  ✅ Authenticated as: $ACCOUNT"

log_info "🔍 Inspecting the project..."
if ! gcloud projects describe "$PROJECT_ID" >/dev/null 2>&1; then
    log_error "Project '$PROJECT_ID' not found or you don't have access."
    exit 1
fi
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
log_info "  ✅ Project number: $PROJECT_NUMBER"

# Check GPU Quota only for setup
if [ "$COMMAND" = "setup" ]; then
    check_gpu_quota "$PROJECT_ID" "$REGION" "$ACCELERATOR_TYPE"
fi

# =========================================================================
# SETUP
# =========================================================================
if [ "$COMMAND" = "setup" ]; then

    # --- Pre-flight checks: Image & Triggers ---
    log_info "🔎 Checking if the beans are already roasted (Image)..."
    IMAGE_EXISTS=$(gcloud artifacts docker images list "${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/workstation" \
        --project="$PROJECT_ID" --format="value(package)" --limit=1 2>/dev/null || true)
    
    if [ -n "$IMAGE_EXISTS" ]; then
        log_info "  ✅ Image found in registry."
    else
        log_info "  🧊 No image found. We'll need a full froth."
    fi

    log_info "🔎 Checking if the automatic roaster is set up (Triggers)..."
    TRIGGER_COUNT=$(gcloud builds triggers list --project="$PROJECT_ID" --region="$REGION" \
        --filter="name:${TRIGGER_ON_CHANGE_NAME} OR name:${TRIGGER_WEEKLY_NAME}" \
        --format="value(name)" 2>/dev/null | wc -l)
    
    if [ "$TRIGGER_COUNT" -ge 2 ]; then
        log_info "  ✅ Automated triggers are already configured."
    else
        log_info "  ⏰ Triggers are missing. I'll remind you to run 'triggers' later."
    fi

    # --- Ensure default VPC network exists ---
    log_info "🔌 Checking the espresso machine power (VPC)..."
    if gcloud compute networks describe default --project="$PROJECT_ID" >/dev/null 2>&1; then
        log_info "  ✅ Default network exists"
    else
        log_info "  🏗️  Building a new network..."
        gcloud compute networks create default \
            --subnet-mode=auto --project="$PROJECT_ID" --quiet 2>&1 | head -3
        log_info "  ✅ Default network created"
    fi

    # --- Enable Cloud Build API ---
    log_info "📦 Getting the Cloud Build beans ready..."
    gcloud services enable cloudbuild.googleapis.com --project="$PROJECT_ID" --quiet 2>/dev/null

    # --- Grant required IAM roles ---
    log_info "🔐 Configuring the barista's keys (IAM)..."
    CB_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
    COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

    for SA in "$CB_SA" "$COMPUTE_SA"; do
        for ROLE in "roles/owner" "roles/logging.logWriter"; do
            if gcloud projects get-iam-policy "$PROJECT_ID" --format=json 2>/dev/null | \
                grep -q "$SA.*$(basename "$ROLE")" 2>/dev/null; then
                true
            else
                gcloud projects add-iam-policy-binding "$PROJECT_ID" \
                    --member="serviceAccount:${SA}" \
                    --role="$ROLE" \
                    --condition=None \
                    --quiet --format=none 2>&1 || true
            fi
        done
    done
    log_info "  ✅ Service account permissions configured"

    # --- Run deployment locally ---
    echo ""
    log_info "🚀 Starting the local brew (Deployment)..."
    echo ""
    echo "  This order includes:"
    echo "    ☕ APIs, Artifact Registry, Docker image,"
    echo "    🥛 Cloud NAT, Workstation cluster + config,"
    echo "    🧊 Nix, fonts, ZSH, Starship, dev tools,"
    echo "    🍰 Cloud Scheduler"
    echo ""
    
    notify_webhook "$WEBHOOK_URL" "☕ Order Received" "Project: ${PROJECT_ID}" \
        "Local brew started for project ${PROJECT_ID}. I'll ping you when it's ready!"

    # Execute the deployment script locally with flags
    bash "${SCRIPT_DIR}/deploy-workstation.sh" \
        --project "${PROJECT_ID}" \
        --region "${REGION}" \
        --webhook "${WEBHOOK_URL}" \
        --account "${ACCOUNT}" \
        --profile "${PROFILE}" \
        --modules "${CUSTOM_MODULES}"

    echo -e "${BLUE}=============================================${NC}"
    echo " 🎉 Order fulfilled successfully!"
    echo -e "${BLUE}=============================================${NC}"
    echo ""
    [ -n "$WEBHOOK_URL" ] && echo " 🔔 Notifications enabled"
    echo ""
    echo " You can now access your workstation at the URL printed above."
    echo -e "${BLUE}=============================================${NC}"

# =========================================================================
# TEARDOWN
# =========================================================================
elif [ "$COMMAND" = "teardown" ]; then

    echo " 🧹 This will clean up the following resources:"
    echo "   - Workstation: $WORKSTATION"
    echo "   - Workstation Config: $CONFIG"
    echo "   - Workstation Cluster: $CLUSTER"
    echo "   - Artifact Registry: $AR_REPO"
    echo "   - Cloud NAT + Router"
    echo "   - Cloud Scheduler jobs"
    echo "   - Pending Cloud Build jobs"
    echo ""

    if [ "$SKIP_CONFIRM" = false ] && [ "$DRY_RUN" = false ]; then
        read -p "🤔 Are you sure? The shop will be closed. (yes/no): " CONFIRM
        if [ "$CONFIRM" != "yes" ]; then
            log_info "☕ Order cancelled. The shop remains open."
            exit 0
        fi
    fi

    echo ""
    notify_webhook "$WEBHOOK_URL" "🧹 Closing Shop" "Project: ${PROJECT_ID}" "Cleaning all resources..."

    gcloud_timeout() {
        local secs=$1; shift
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN]${NC} timeout $secs $@"
            return 0
        fi
        if timeout "$secs" "$@" 2>&1; then
            return 0
        else
            local rc=$?
            if [ $rc -eq 124 ]; then
                log_warn "TIMEOUT: skipping step"
            fi
            return $rc
        fi
    }

    wait_deleted() {
        local desc_cmd="$1" name="$2" max_wait="${3:-300}"
        [ "$DRY_RUN" = true ] && return 0
        local elapsed=0
        while [ $elapsed -lt $max_wait ]; do
            if ! eval "$desc_cmd" >/dev/null 2>&1; then
                return 0
            fi
            log_info "  🧹 Waiting for $name to be cleaned ($elapsed/${max_wait}s)..."
            sleep 15
            elapsed=$((elapsed + 15))
        done
        log_warn "$name is taking a while to clean"
        return 1
    }

    api_enabled() {
        [ "$DRY_RUN" = true ] && return 0
        timeout 15 gcloud services list --enabled --project="$PROJECT_ID" \
            --format="value(name)" 2>/dev/null | grep -q "$1"
    }

    # 1. Delete Workstation
    log_info "🚽 Cleaning the workstation..."
    if api_enabled "workstations.googleapis.com"; then
        if gcloud_timeout 30 gcloud workstations describe "$WORKSTATION" \
            --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" \
            --project="$PROJECT_ID" >/dev/null 2>&1 || [ "$DRY_RUN" = true ]; then
            
            gcloud_timeout 120 gcloud workstations stop "$WORKSTATION" \
                --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" \
                --project="$PROJECT_ID" --quiet 2>/dev/null || true
            
            gcloud_timeout 120 gcloud workstations delete "$WORKSTATION" \
                --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" \
                --project="$PROJECT_ID" --quiet
            
            log_info "  ✅ Done"
            wait_deleted "gcloud workstations describe $WORKSTATION --config=$CONFIG --cluster=$CLUSTER --region=$REGION --project=$PROJECT_ID" "workstation" 120
        else
            log_info "  💨 Not found — skipping"
        fi
    fi

    # 2. Delete Config
    log_info "🧺 Cleaning the config..."
    if api_enabled "workstations.googleapis.com"; then
        if gcloud_timeout 30 gcloud workstations configs describe "$CONFIG" \
            --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1 || [ "$DRY_RUN" = true ]; then
            
            gcloud_timeout 120 gcloud workstations configs delete "$CONFIG" \
                --cluster="$CLUSTER" --region="$REGION" \
                --project="$PROJECT_ID" --quiet
            
            log_info "  ✅ Done"
            wait_deleted "gcloud workstations configs describe $CONFIG --cluster=$CLUSTER --region=$REGION --project=$PROJECT_ID" "config" 120
        else
            log_info "  💨 Not found — skipping"
        fi
    fi

    # 3. Delete Cluster
    log_info "🏗️  Dismantling the cluster (this takes 5-10 min)..."
    if api_enabled "workstations.googleapis.com"; then
        if gcloud_timeout 30 gcloud workstations clusters describe "$CLUSTER" \
            --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1 || [ "$DRY_RUN" = true ]; then
            
            gcloud_timeout 900 gcloud workstations clusters delete "$CLUSTER" \
                --region="$REGION" --project="$PROJECT_ID" --quiet
            
            log_info "  ✅ Done"
            wait_deleted "gcloud workstations clusters describe $CLUSTER --region=$REGION --project=$PROJECT_ID" "cluster" 900
        else
            log_info "  💨 Not found — skipping"
        fi
    fi

    # 4. Delete Artifact Registry
    log_info "📦 Emptying the registry..."
    if api_enabled "artifactregistry.googleapis.com"; then
        if gcloud_timeout 30 gcloud artifacts repositories describe "$AR_REPO" \
            --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1 || [ "$DRY_RUN" = true ]; then
            
            gcloud_timeout 120 gcloud artifacts repositories delete "$AR_REPO" \
                --location="$REGION" --project="$PROJECT_ID" --quiet
            
            log_info "  ✅ Done"
            wait_deleted "gcloud artifacts repositories describe $AR_REPO --location=$REGION --project=$PROJECT_ID" "registry" 120
        else
            log_info "  💨 Not found — skipping"
        fi
    fi

    # 5. Delete Cloud NAT
    log_info "🥛 Removing the NAT..."
    if api_enabled "compute.googleapis.com"; then
        if gcloud_timeout 30 gcloud compute routers nats describe ws-nat \
            --router=ws-router --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1 || [ "$DRY_RUN" = true ]; then
            
            gcloud_timeout 120 gcloud compute routers nats delete ws-nat \
                --router=ws-router --region="$REGION" \
                --project="$PROJECT_ID" --quiet
            
            log_info "  ✅ Done"
            wait_deleted "gcloud compute routers nats describe ws-nat --router=ws-router --region=$REGION --project=$PROJECT_ID" "NAT" 60
        else
            log_info "  💨 Not found — skipping"
        fi
    fi

    # 6. Delete Cloud Router
    log_info "📡 Removing the router..."
    if api_enabled "compute.googleapis.com"; then
        if gcloud_timeout 30 gcloud compute routers describe ws-router \
            --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1 || [ "$DRY_RUN" = true ]; then
            
            gcloud_timeout 120 gcloud compute routers delete ws-router \
                --region="$REGION" --project="$PROJECT_ID" --quiet
            
            log_info "  ✅ Done"
            wait_deleted "gcloud compute routers describe ws-router --region=$REGION --project=$PROJECT_ID" "router" 60
        else
            log_info "  💨 Not found — skipping"
        fi
    fi

    # 7. Delete Cloud Scheduler
    log_info "⏰ Turning off the alarm clocks (scheduler)..."
    if api_enabled "cloudscheduler.googleapis.com" || [ "$DRY_RUN" = true ]; then
        for JOB in ws-daily-start ws-weekday-start ws-weekday-stop; do
            if gcloud_timeout 15 gcloud scheduler jobs describe "$JOB" \
                --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1 || [ "$DRY_RUN" = true ]; then
                
                gcloud_timeout 30 gcloud scheduler jobs delete "$JOB" \
                    --location="$REGION" --project="$PROJECT_ID" --quiet
                
                log_info "  ✅ Deleted $JOB"
            fi
        done
    fi

    # 9. Cancel Builds
    log_info "🚫 Cancelling active brews..."
    if api_enabled "cloudbuild.googleapis.com" || [ "$DRY_RUN" = true ]; then
        RUNNING_BUILDS=$(gcloud builds list --project="$PROJECT_ID" --region="$REGION" \
            --filter="status=WORKING OR status=QUEUED" --format="value(id)" 2>/dev/null || true)
        if [ -n "$RUNNING_BUILDS" ] || [ "$DRY_RUN" = true ]; then
            [ "$DRY_RUN" = true ] && RUNNING_BUILDS="DRY-RUN-BUILD-ID"
            for BUILD_ID in $RUNNING_BUILDS; do
                gcloud_timeout 30 gcloud builds cancel "$BUILD_ID" --project="$PROJECT_ID" --region="$REGION" --quiet
                log_info "  ✅ Cancelled $BUILD_ID"
            done
        else
            log_info "  💨 No active brews"
        fi
    fi

    echo ""
    echo -e "${BLUE}=============================================${NC}"
    echo " ✨ All clean! The shop is closed."
    echo -e "${BLUE}=============================================${NC}"
    echo ""
    echo " To order again: bash scripts/workstation.sh setup -p $PROJECT_ID"
    echo -e "${BLUE}=============================================${NC}"

    notify_webhook "$WEBHOOK_URL" "✨ Cleanup Complete" "Project: ${PROJECT_ID}" "The shop is closed and clean."
fi

