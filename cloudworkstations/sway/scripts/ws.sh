#!/bin/bash
# =============================================================================
# Cloud Workstation — Setup & Teardown
# =============================================================================
# Single script for both setup and teardown of a GPU Cloud Workstation.
#
# Usage:
#   bash scripts/ws.sh setup    -p PROJECT_ID [-w WEBHOOK] [-e EMAIL]
#   bash scripts/ws.sh teardown -p PROJECT_ID [-w WEBHOOK] [-e EMAIL] [-y]
#
# Requirements:
#   - gcloud CLI authenticated with Owner role on the target project
#   - NVIDIA T4 GPU quota in us-central1 (at least 1)
# =============================================================================

set -euo pipefail

REGION="us-central1"
# Auto-detect repo URL from git remote (falls back to placeholder if not in a git repo)
SCRIPT_DIR_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL=$(git -C "$SCRIPT_DIR_ROOT" remote get-url origin 2>/dev/null || echo "https://github.com/sapientcoffee/platform-ops.git")
CLUSTER="workstation-cluster"
CONFIG="ws-config"
WORKSTATION="dev-workstation"
AR_REPO="workstation-images"

usage() {
    echo "Usage:"
    echo "  bash scripts/ws.sh setup    -p PROJECT_ID [-w WEBHOOK_URL] [-e EMAIL]"
    echo "  bash scripts/ws.sh teardown -p PROJECT_ID [-w WEBHOOK_URL] [-e EMAIL] [-y]"
    echo ""
    echo "Commands:"
    echo "  setup      Create a GPU Cloud Workstation (runs in Cloud Build)"
    echo "  teardown   Delete all Cloud Workstation resources"
    echo ""
    echo "Required:"
    echo "  -p, --project PROJECT_ID    GCP project ID"
    echo ""
    echo "Optional:"
    echo "  --profile PROFILE           Install profile: minimal, dev, ai, full (default: full)"
    echo "  --modules MODULES           Comma-separated modules for custom profile"
    echo "  -w, --webhook URL           Google Chat / Slack webhook for notifications"
    echo "  -e, --email EMAIL           Email address for notifications"
    echo "  -y, --yes                   Skip confirmation (teardown only)"
    exit 1
}

# --- Parse command ---
COMMAND="${1:-}"
if [ -z "$COMMAND" ] || [[ "$COMMAND" == -* ]]; then
    echo "ERROR: First argument must be 'setup' or 'teardown'"
    echo ""
    usage
fi
shift

if [ "$COMMAND" != "setup" ] && [ "$COMMAND" != "teardown" ]; then
    echo "ERROR: Unknown command '$COMMAND'. Use 'setup' or 'teardown'."
    echo ""
    usage
fi

# --- Parse flags ---
PROJECT_ID=""
WEBHOOK_URL=""
EMAIL=""
PROFILE="full"
CUSTOM_MODULES=""
SKIP_CONFIRM=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--project)  PROJECT_ID="$2"; shift 2 ;;
        --profile)     PROFILE="$2"; shift 2 ;;
        --modules)     CUSTOM_MODULES="$2"; PROFILE="custom"; shift 2 ;;
        -w|--webhook)  WEBHOOK_URL="$2"; shift 2 ;;
        -e|--email)    EMAIL="$2"; shift 2 ;;
        -y|--yes)      SKIP_CONFIRM=true; shift ;;
        -h|--help)     usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# Validate profile
case "$PROFILE" in
    minimal|dev|ai|full|custom) ;;
    *) echo "ERROR: Invalid profile '$PROFILE'. Must be: minimal, dev, ai, full"; exit 1 ;;
esac

if [ "$PROFILE" = "custom" ] && [ -z "$CUSTOM_MODULES" ]; then
    echo "ERROR: --modules is required when using custom profile"
    exit 1
fi

if [ -z "$PROJECT_ID" ]; then
    echo "ERROR: --project is required"
    usage
fi

log() { echo "[$(date '+%H:%M:%S')] $1"; }

notify_webhook() {
    [ -z "$WEBHOOK_URL" ] && return 0
    local title="$1" subtitle="$2" body="$3"
    curl -s -X POST "$WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "{
            \"cards\": [{
                \"header\": {\"title\": \"${title}\", \"subtitle\": \"${subtitle}\"},
                \"sections\": [{\"widgets\": [{\"textParagraph\": {\"text\": \"${body}\"}}]}]
            }]
        }" >/dev/null 2>&1 || true
}

notify_email() {
    [ -z "$EMAIL" ] || [ -z "$EMAIL_FUNCTION_URL" ] && return 0
    local subject="$1" body="$2"
    curl -s -X POST "$EMAIL_FUNCTION_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: bearer $(gcloud auth print-identity-token 2>/dev/null || echo '')" \
        -d "{\"to\": \"${EMAIL}\", \"subject\": \"${subject}\", \"body\": \"${body}\"}" \
        >/dev/null 2>&1 || true
}

notify_all() {
    local title="$1" subtitle="$2" body="$3"
    notify_webhook "$title" "$subtitle" "$body"
    notify_email "$title — $subtitle" "$body"
}

# =========================================================================
# PRE-FLIGHT CHECKS (shared by setup and teardown)
# =========================================================================
echo "============================================="
echo " Cloud Workstation — ${COMMAND^^}"
echo " Project: $PROJECT_ID"
echo " Region:  $REGION"
echo " Profile: $PROFILE"
[ -n "$CUSTOM_MODULES" ] && echo " Modules: $CUSTOM_MODULES"
[ -n "$WEBHOOK_URL" ] && echo " Webhook: enabled"
[ -n "$EMAIL" ] && echo " Email:   $EMAIL"
echo "============================================="
echo ""

log "Validating authentication..."
ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || true)
if [ -z "$ACCOUNT" ]; then
    echo "ERROR: No active gcloud account. Run: gcloud auth login"
    exit 1
fi
log "  Authenticated as: $ACCOUNT"

log "Validating project..."
if ! gcloud projects describe "$PROJECT_ID" >/dev/null 2>&1; then
    echo "ERROR: Project '$PROJECT_ID' not found or you don't have access."
    exit 1
fi
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
log "  Project number: $PROJECT_NUMBER"

EMAIL_FUNCTION_URL=""

# =========================================================================
# SETUP
# =========================================================================
if [ "$COMMAND" = "setup" ]; then

    # --- Ensure default VPC network exists ---
    log "Checking default VPC network..."
    if gcloud compute networks describe default --project="$PROJECT_ID" >/dev/null 2>&1; then
        log "  Default network exists"
    else
        log "  Creating default network..."
        gcloud compute networks create default \
            --subnet-mode=auto --project="$PROJECT_ID" --quiet 2>&1 | head -3
        log "  Default network created"
    fi

    # --- Deploy email notification function (if --email provided) ---
    if [ -n "$EMAIL" ]; then
        log "Deploying email notification function..."
        gcloud services enable cloudfunctions.googleapis.com run.googleapis.com \
            --project="$PROJECT_ID" --quiet 2>/dev/null

        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        FUNC_DIR="${SCRIPT_DIR}/email-notify"

        if [ -d "$FUNC_DIR" ]; then
            if gcloud functions deploy ws-email-notify \
                --gen2 \
                --runtime=python312 \
                --region="$REGION" \
                --source="$FUNC_DIR" \
                --entry-point=notify \
                --trigger-http \
                --allow-unauthenticated \
                --project="$PROJECT_ID" \
                --quiet 2>&1 | tail -3; then
                EMAIL_FUNCTION_URL=$(gcloud functions describe ws-email-notify \
                    --gen2 --region="$REGION" --project="$PROJECT_ID" \
                    --format="value(serviceConfig.uri)" 2>/dev/null || echo "")
                if [ -n "$EMAIL_FUNCTION_URL" ]; then
                    log "  Email function deployed: $EMAIL_FUNCTION_URL"
                    notify_email "Cloud Workstation — Test" "Email notifications are working for project ${PROJECT_ID}."
                    log "  Test email sent to $EMAIL"
                else
                    log "  WARNING: Could not get function URL — email notifications disabled"
                fi
            else
                log "  WARNING: Email function deployment failed — webhook only"
            fi
        else
            log "  WARNING: email-notify/ directory not found at $FUNC_DIR — email notifications disabled"
        fi
    fi

    # --- Enable Cloud Build API ---
    log "Enabling Cloud Build API..."
    gcloud services enable cloudbuild.googleapis.com --project="$PROJECT_ID" --quiet 2>/dev/null

    # --- Grant required IAM roles to build service accounts ---
    # Newer GCP projects use the Compute Engine default SA for Cloud Build.
    # Grant Owner + Logs Writer to both the legacy Cloud Build SA and Compute SA.
    log "Configuring build service account permissions..."
    CB_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
    COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

    for SA in "$CB_SA" "$COMPUTE_SA"; do
        for ROLE in "roles/owner" "roles/logging.logWriter"; do
            if gcloud projects get-iam-policy "$PROJECT_ID" --format=json 2>/dev/null | \
                grep -q "$SA.*$(basename "$ROLE")" 2>/dev/null; then
                true  # already has role
            else
                gcloud projects add-iam-policy-binding "$PROJECT_ID" \
                    --member="serviceAccount:${SA}" \
                    --role="$ROLE" \
                    --condition=None \
                    --quiet --format=none 2>&1 || true
            fi
        done
    done
    log "  Service account permissions configured"

    # --- Submit Cloud Build job ---
    echo ""
    log "Submitting Cloud Build job..."
    echo ""
    echo "  This will create your complete Cloud Workstation:"
    echo "    APIs, Artifact Registry, Docker image, Cloud NAT,"
    echo "    Workstation cluster + config, Nix, fonts, ZSH,"
    echo "    Starship, dev tools, Cloud Scheduler"
    echo ""
    echo "  You can safely close this terminal after submission."
    echo ""

    # Write webhook URL to a temp file to avoid shell escaping issues with & chars
    TMPDIR=$(mktemp -d)
    trap "rm -rf '$TMPDIR'" EXIT

    cat > "${TMPDIR}/cloudbuild.yaml" << 'BUILDEOF'
steps:
  - name: 'gcr.io/cloud-builders/git'
    args: ['clone', '${_CB_REPO_URL}', '/workspace/repo']
    id: 'clone-repo'

  - name: 'gcr.io/cloud-builders/gcloud'
    entrypoint: '/bin/bash'
    args:
      - '-c'
      - |
        echo "Current directory: $(pwd)"
        if [ -d "/workspace/repo" ]; then
          cd /workspace/repo
          echo "Listing /workspace/repo:"
          ls -F
          if [ -f "cloudworkstations/sway/scripts/cloud-build-setup.sh" ]; then
            bash cloudworkstations/sway/scripts/cloud-build-setup.sh "${PROJECT_ID}" "${_CB_REGION}" "${_CB_WEBHOOK_URL}" "${_CB_EMAIL_FUNC_URL}" "${_CB_EMAIL}" "${_CB_USER_ACCOUNT}" "${_CB_PROFILE}"
          else
            echo "ERROR: cloud-build-setup.sh not found at cloudworkstations/sway/scripts/cloud-build-setup.sh"
            ls -R cloudworkstations/sway/scripts/ || echo "scripts directory not found"
            exit 127
          fi
        else
          echo "ERROR: /workspace/repo not found"
          exit 127
        fi

    id: 'run-setup'
    waitFor: ['clone-repo']

timeout: 7200s
substitutions:
  _CB_REPO_URL: 'https://github.com/sapientcoffee/platform-ops.git'
  _CB_REGION: 'us-central1'
  _CB_WEBHOOK_URL: ''
  _CB_EMAIL_FUNC_URL: ''
  _CB_EMAIL: ''
  _CB_USER_ACCOUNT: ''
  _CB_PROFILE: 'full'
options:
  logging: CLOUD_LOGGING_ONLY
  machineType: 'E2_HIGHCPU_8'

BUILDEOF

    # Build the substitutions array — use gcloud's --substitutions flag carefully.
    # Webhook URLs contain & and = which are safe in Cloud Build substitution values
    # but must be properly quoted when passed via shell.
    SUBS_ARGS=("_CB_REPO_URL=${REPO_URL}" "_CB_REGION=${REGION}" "_CB_USER_ACCOUNT=${ACCOUNT}" "_CB_PROFILE=${PROFILE}")
    [ -n "$WEBHOOK_URL" ] && SUBS_ARGS+=("_CB_WEBHOOK_URL=${WEBHOOK_URL}")
    [ -n "$EMAIL_FUNCTION_URL" ] && SUBS_ARGS+=("_CB_EMAIL_FUNC_URL=${EMAIL_FUNCTION_URL}" "_CB_EMAIL=${EMAIL}")


    # Join with commas
    SUBS_STR=$(IFS=,; echo "${SUBS_ARGS[*]}")

    BUILD_OUTPUT=$(gcloud builds submit \
        --config="${TMPDIR}/cloudbuild.yaml" \
        --project="$PROJECT_ID" \
        --region="$REGION" \
        --no-source \
        --substitutions="$SUBS_STR")

    BUILD_ID=$(echo "$BUILD_OUTPUT" | grep -oP 'builds/\K[a-f0-9-]+' | head -1)

    if [ -z "$BUILD_ID" ]; then
        echo "ERROR: Failed to submit build. Output:"
        echo "$BUILD_OUTPUT"
        exit 1
    fi

    CONSOLE_URL="https://console.cloud.google.com/cloud-build/builds;region=${REGION}/${BUILD_ID}?project=${PROJECT_ID}"

    notify_all "Setup Started" "Project: ${PROJECT_ID}" \
        "Build ID: <b>${BUILD_ID}</b><br>You'll be notified when it completes.<br><br><a href=\"${CONSOLE_URL}\">View Build</a>"

    echo "============================================="
    echo " Build submitted successfully!"
    echo "============================================="
    echo ""
    echo " Build ID: $BUILD_ID"
    echo ""
    echo " Track progress:"
    echo "   Console: $CONSOLE_URL"
    echo "   CLI:     gcloud builds log ${BUILD_ID} --stream --project=${PROJECT_ID} --region=${REGION}"
    echo ""
    [ -n "$WEBHOOK_URL" ] && echo " Google Chat: notifications enabled"
    [ -n "$EMAIL" ] && echo " Email: notifications to $EMAIL"
    echo ""
    echo " You can safely close this terminal now."
    echo "============================================="

# =========================================================================
# TEARDOWN
# =========================================================================
elif [ "$COMMAND" = "teardown" ]; then

    echo " This will DELETE the following resources:"
    echo "   - Workstation: $WORKSTATION"
    echo "   - Workstation Config: $CONFIG"
    echo "   - Workstation Cluster: $CLUSTER"
    echo "   - Artifact Registry: $AR_REPO (and all images)"
    echo "   - Cloud NAT: ws-nat + Cloud Router: ws-router"
    echo "   - Cloud Scheduler: ws-weekday-start, ws-weekday-stop"
    echo "   - Cloud Function: ws-email-notify (if exists)"
    echo "   - Cloud Build jobs: cancel any running/queued builds"
    echo ""

    if [ "$SKIP_CONFIRM" = false ]; then
        read -p "Are you sure? This cannot be undone. (yes/no): " CONFIRM
        if [ "$CONFIRM" != "yes" ]; then
            echo "Aborted."
            exit 0
        fi
    fi

    echo ""
    notify_all "Teardown Started" "Project: ${PROJECT_ID}" "Deleting all Cloud Workstation resources..."

    # Timeout wrapper — prevents any gcloud command from hanging indefinitely.
    # Usage: gcloud_timeout <seconds> <command...>
    # Logs a clear message on timeout instead of hanging silently.
    gcloud_timeout() {
        local secs=$1; shift
        if timeout "$secs" "$@" 2>&1; then
            return 0
        else
            local rc=$?
            # timeout returns 124 when the command is killed
            if [ $rc -eq 124 ]; then
                log "  TIMEOUT: command exceeded ${secs}s — skipping"
            fi
            return $rc
        fi
    }

    # Wait for a resource to be fully deleted (poll until describe fails)
    wait_deleted() {
        local desc_cmd="$1" name="$2" max_wait="${3:-300}"
        local elapsed=0
        while [ $elapsed -lt $max_wait ]; do
            if ! eval "$desc_cmd" >/dev/null 2>&1; then
                return 0  # Resource is gone
            fi
            log "  Waiting for $name to be deleted ($elapsed/${max_wait}s)..."
            sleep 15
            elapsed=$((elapsed + 15))
        done
        log "  WARN: $name may not be fully deleted after ${max_wait}s"
        return 1
    }

    # Check if a GCP API is enabled before attempting operations that depend on it
    api_enabled() {
        timeout 15 gcloud services list --enabled --project="$PROJECT_ID" \
            --format="value(name)" 2>/dev/null | grep -q "$1"
    }

    # 1. Delete Workstation
    log "Deleting workstation..."
    if api_enabled "workstations.googleapis.com"; then
        if gcloud_timeout 30 gcloud workstations describe "$WORKSTATION" \
            --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" \
            --project="$PROJECT_ID" >/dev/null 2>&1; then
            gcloud_timeout 120 gcloud workstations stop "$WORKSTATION" \
                --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" \
                --project="$PROJECT_ID" --quiet 2>/dev/null || true
            gcloud_timeout 120 gcloud workstations delete "$WORKSTATION" \
                --config="$CONFIG" --cluster="$CLUSTER" --region="$REGION" \
                --project="$PROJECT_ID" --quiet || log "  WARN: delete may have timed out"
            log "  Deleted"
            wait_deleted "gcloud_timeout 15 gcloud workstations describe $WORKSTATION --config=$CONFIG --cluster=$CLUSTER --region=$REGION --project=$PROJECT_ID" "workstation" 120
        else
            log "  Not found — skipping"
        fi
    else
        log "  Workstations API not enabled — skipping"
    fi

    # 2. Delete Config
    log "Deleting config..."
    if api_enabled "workstations.googleapis.com"; then
        if gcloud_timeout 30 gcloud workstations configs describe "$CONFIG" \
            --cluster="$CLUSTER" --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
            gcloud_timeout 120 gcloud workstations configs delete "$CONFIG" \
                --cluster="$CLUSTER" --region="$REGION" \
                --project="$PROJECT_ID" --quiet || log "  WARN: delete may have timed out"
            log "  Deleted"
            wait_deleted "gcloud_timeout 15 gcloud workstations configs describe $CONFIG --cluster=$CLUSTER --region=$REGION --project=$PROJECT_ID" "config" 120
        else
            log "  Not found — skipping"
        fi
    else
        log "  Workstations API not enabled — skipping"
    fi

    # 3. Delete Cluster (can take 5-10 minutes)
    log "Deleting cluster (5-10 minutes)..."
    if api_enabled "workstations.googleapis.com"; then
        if gcloud_timeout 30 gcloud workstations clusters describe "$CLUSTER" \
            --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
            gcloud_timeout 900 gcloud workstations clusters delete "$CLUSTER" \
                --region="$REGION" --project="$PROJECT_ID" --quiet || log "  WARN: delete may have timed out"
            log "  Deleted"
            wait_deleted "gcloud_timeout 15 gcloud workstations clusters describe $CLUSTER --region=$REGION --project=$PROJECT_ID" "cluster" 900
        else
            log "  Not found — skipping"
        fi
    else
        log "  Workstations API not enabled — skipping"
    fi

    # 4. Delete Artifact Registry
    log "Deleting Artifact Registry..."
    if api_enabled "artifactregistry.googleapis.com"; then
        if gcloud_timeout 30 gcloud artifacts repositories describe "$AR_REPO" \
            --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
            gcloud_timeout 120 gcloud artifacts repositories delete "$AR_REPO" \
                --location="$REGION" --project="$PROJECT_ID" --quiet || log "  WARN: delete may have timed out"
            log "  Deleted"
            wait_deleted "gcloud_timeout 15 gcloud artifacts repositories describe $AR_REPO --location=$REGION --project=$PROJECT_ID" "Artifact Registry" 120
        else
            log "  Not found — skipping"
        fi
    else
        log "  Artifact Registry API not enabled — skipping"
    fi

    # 5. Delete Cloud NAT
    log "Deleting Cloud NAT..."
    if api_enabled "compute.googleapis.com"; then
        if gcloud_timeout 30 gcloud compute routers nats describe ws-nat \
            --router=ws-router --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
            gcloud_timeout 120 gcloud compute routers nats delete ws-nat \
                --router=ws-router --region="$REGION" \
                --project="$PROJECT_ID" --quiet || log "  WARN: delete may have timed out"
            log "  Deleted"
            wait_deleted "gcloud_timeout 15 gcloud compute routers nats describe ws-nat --router=ws-router --region=$REGION --project=$PROJECT_ID" "Cloud NAT" 60
        else
            log "  Not found — skipping"
        fi
    else
        log "  Compute API not enabled — skipping"
    fi

    # 6. Delete Cloud Router
    log "Deleting Cloud Router..."
    if api_enabled "compute.googleapis.com"; then
        if gcloud_timeout 30 gcloud compute routers describe ws-router \
            --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
            gcloud_timeout 120 gcloud compute routers delete ws-router \
                --region="$REGION" --project="$PROJECT_ID" --quiet || log "  WARN: delete may have timed out"
            log "  Deleted"
            wait_deleted "gcloud_timeout 15 gcloud compute routers describe ws-router --region=$REGION --project=$PROJECT_ID" "Cloud Router" 60
        else
            log "  Not found — skipping"
        fi
    else
        log "  Compute API not enabled — skipping"
    fi

    # 7. Delete Cloud Scheduler jobs
    log "Deleting Cloud Scheduler jobs..."
    if api_enabled "cloudscheduler.googleapis.com"; then
        for JOB in ws-daily-start ws-weekday-start ws-weekday-stop; do
            if gcloud_timeout 15 gcloud scheduler jobs describe "$JOB" \
                --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
                gcloud_timeout 30 gcloud scheduler jobs delete "$JOB" \
                    --location="$REGION" --project="$PROJECT_ID" --quiet || log "  WARN: $JOB delete may have timed out"
                log "  Deleted $JOB"
            fi
        done
        log "  Done"
        for JOB in ws-weekday-start ws-weekday-stop; do
            if gcloud_timeout 15 gcloud scheduler jobs describe "$JOB" --location="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
                log "  WARN: $JOB still exists after delete"
            fi
        done
    else
        log "  Cloud Scheduler API not enabled — skipping"
    fi

    # 8. Delete email notification function
    log "Deleting email function..."
    if api_enabled "cloudfunctions.googleapis.com"; then
        if gcloud_timeout 30 gcloud functions describe ws-email-notify \
            --gen2 --region="$REGION" --project="$PROJECT_ID" >/dev/null 2>&1; then
            gcloud_timeout 120 gcloud functions delete ws-email-notify \
                --gen2 --region="$REGION" --project="$PROJECT_ID" --quiet || log "  WARN: delete may have timed out"
            log "  Deleted"
            wait_deleted "gcloud_timeout 15 gcloud functions describe ws-email-notify --gen2 --region=$REGION --project=$PROJECT_ID" "Cloud Function" 120
        else
            log "  Not found — skipping"
        fi
    else
        log "  Cloud Functions API not enabled — skipping"
    fi

    # 9. Cancel all running/queued Cloud Builds
    log "Cancelling running Cloud Build jobs..."
    if api_enabled "cloudbuild.googleapis.com"; then
        RUNNING_BUILDS=$(gcloud builds list --project="$PROJECT_ID" --region="$REGION" \
            --filter="status=WORKING OR status=QUEUED" --format="value(id)" 2>/dev/null)
        if [ -n "$RUNNING_BUILDS" ]; then
            for BUILD_ID in $RUNNING_BUILDS; do
                gcloud builds cancel "$BUILD_ID" --project="$PROJECT_ID" --region="$REGION" 2>/dev/null || true
                log "  Cancelled $BUILD_ID"
            done
            # Verify no builds still running
            sleep 5
            REMAINING=$(gcloud builds list --project="$PROJECT_ID" --region="$REGION" \
                --filter="status=WORKING OR status=QUEUED" --format="value(id)" 2>/dev/null | wc -l)
            if [ "$REMAINING" -eq 0 ]; then
                log "  All builds cancelled"
            else
                log "  WARN: $REMAINING builds still running"
            fi
        else
            log "  No running builds"
        fi
    else
        log "  Cloud Build API not enabled — skipping"
    fi

    echo ""
    echo "============================================="
    echo " Teardown complete!"
    echo "============================================="
    echo ""
    echo " All Cloud Workstation resources deleted."
    echo " To set up again: bash scripts/ws.sh setup -p $PROJECT_ID"
    echo "============================================="

    notify_all "Teardown Complete" "Project: ${PROJECT_ID}" "All Cloud Workstation resources deleted."
fi

fi
