#!/bin/bash
# =============================================================================
# 🔥 configure-automation.sh — Set up the Automated Image Updates
# =============================================================================
# 1. Directory Trigger: Rebuilds image when you change the configuration.
# 2. Scheduled Trigger: Rebuilds every Tuesday to keep things fresh.
# =============================================================================

set -euo pipefail

# Source library and config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.env"
source "${SCRIPT_DIR}/lib.sh"

PROJECT_ID=""
REGION_FLAG=""
REPO_NAME=""
REPO_OWNER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project) PROJECT_ID="$2"; shift 2 ;;
        --region)  REGION_FLAG="$2"; shift 2 ;;
        --repo-name) REPO_NAME="$2"; shift 2 ;;
        --repo-owner) REPO_OWNER="$2"; shift 2 ;;
        *) shift ;;
    esac
done

REGION="${REGION_FLAG:-$REGION}"

if [ -z "$PROJECT_ID" ]; then
    log_error "PROJECT_ID is required"
    echo "Usage: bash scripts/configure-automation.sh --project PROJECT_ID [--region REGION] [--repo-name REPO] [--repo-owner OWNER]"
    exit 1
fi

log_info "☕ Setting up triggers for: $PROJECT_ID"

# Try to auto-detect repo name
if [ -z "$REPO_NAME" ]; then
    REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ "$REPO_URL" =~ github.com[:/]([^/]+)/([^/.]+)(\.git)? ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]}"
        log_info "✅ Auto-detected GitHub configuration: ${REPO_OWNER}/${REPO_NAME}"
    fi
fi

if [ -z "$REPO_NAME" ] || [ -z "$REPO_OWNER" ]; then
    log_warn "Could not detect repo. Event-based roasting skipped."
else
    log_info "🔥 Creating the 'Update on Change' trigger..."
    # Wrap in subshell to prevent set -e from exiting if repo isn't connected
    (gcloud builds triggers create github \
        --name="${TRIGGER_ON_CHANGE_NAME}" \
        --project="$PROJECT_ID" \
        --region="$REGION" \
        --repo-owner="$REPO_OWNER" \
        --repo-name="$REPO_NAME" \
        --branch-pattern="^main$" \
        --build-config="cloudworkstations/sway/cloudbuild-image.yaml" \
        --included-files="cloudworkstations/sway/workstation-image/**" \
        --substitutions="_REGION=${REGION},_AR_REPO=${AR_REPO},_TAG=\$SHORT_SHA" \
        --description="Rebuilds image when the configuration changes" \
        --quiet) || log_warn "Could not create GitHub trigger (is the repo connected?)"
fi

log_info "⏰ Creating the 'Weekly Rebuild' trigger..."
if ! gcloud pubsub topics describe "$TOPIC_NAME" --project="$PROJECT_ID" >/dev/null 2>&1; then
    gcloud pubsub topics create "$TOPIC_NAME" --project="$PROJECT_ID"
fi

# For Pub/Sub triggers using a build-config, we must specify the repository.
# Note: This requires the repository to be connected as a 2nd-gen repository resource
# or use the full repository resource name. For now, we'll try the most compatible
# format or log a warning if it fails.
gcloud builds triggers create pubsub \
    --name="${TRIGGER_WEEKLY_NAME}" \
    --project="$PROJECT_ID" \
    --region="$REGION" \
    --topic="projects/${PROJECT_ID}/topics/${TOPIC_NAME}" \
    --repo="https://github.com/${REPO_OWNER}/${REPO_NAME}" \
    --repo-type="GITHUB" \
    --branch="main" \
    --build-config="cloudworkstations/sway/cloudbuild-image.yaml" \
    --substitutions="_REGION=${REGION},_AR_REPO=${AR_REPO},_TAG=weekly" \
    --description="Weekly Tuesday roast" \
    --quiet || log_warn "Could not create Pub/Sub trigger. You may need to connect your repository in the GCP Console first."

log_info "🍰 Scheduling the Tuesday afternoon rebuild..."
gcloud scheduler jobs create pubsub "${SCHEDULER_JOB_NAME}" \
    --project="$PROJECT_ID" \
    --location="$REGION" \
    --schedule="0 14 * * 2" \
    --time-zone="America/Los_Angeles" \
    --topic="$TOPIC_NAME" \
    --message-body='{"action": "rebuild"}' \
    --description="Rebuilds every Tuesday at 2PM" \
    --quiet 2>/dev/null || true

log_info "✨ Triggers are hot and ready!"
echo -e "${BLUE}--------------------------------------------------------${NC}"
echo " 1. Event Trigger:  ${TRIGGER_ON_CHANGE_NAME} (GitHub)"
echo " 2. Weekly Trigger: ${TRIGGER_WEEKLY_NAME} (Pub/Sub)"
echo " 3. Scheduler:  ${SCHEDULER_JOB_NAME} (Tue 2PM PT)"
echo -e "${BLUE}--------------------------------------------------------${NC}"

