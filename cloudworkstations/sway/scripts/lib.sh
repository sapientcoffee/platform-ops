#!/bin/bash
# =============================================================================
# ☕ Cloud Workstation Utility Library
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step Tracking
CURRENT_STEP=0
TOTAL_STEPS=${TOTAL_STEPS:-10}

# Error Handling
trap 'log_error "Error occurred on line $LINENO. Exiting."' ERR

log_info() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠️  WARN:${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ❌ ERROR:${NC} $1" >&2
}

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  ☕ Step $CURRENT_STEP/$TOTAL_STEPS: $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Dry Run Wrapper
DRY_RUN=${DRY_RUN:-false}
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} $@"
    else
        "$@"
    fi
}

notify_webhook() {
    local webhook_url="$1"
    local title="$2"
    local subtitle="$3"
    local body="$4"

    [ -z "$webhook_url" ] && return 0
    
    curl -s -X POST "$webhook_url" \
        -H 'Content-Type: application/json' \
        -d "{
            \"cards\": [{
                \"header\": { \"title\": \"${title}\", \"subtitle\": \"${subtitle}\" },
                \"sections\": [{ \"widgets\": [{ \"textParagraph\": {\"text\": \"${body}\"} }] }]
            }]
        }" >/dev/null 2>&1 || true
}

retry() {
    local max_attempts=$1 delay=$2; shift 2
    for attempt in $(seq 1 "$max_attempts"); do
        if "$@"; then return 0; fi
        [ "$attempt" -lt "$max_attempts" ] && { log_warn "Retry $attempt/$max_attempts..."; sleep "$delay"; }
    done
    return 1
}

check_dependencies() {
    local deps=("$@")
    log_info "🧐 Checking dependencies..."
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command '$cmd' is not installed."
            exit 1
        fi
    done
    log_info "  ✅ All dependencies found."
}

check_gpu_quota() {
    local project="$1"
    local region="$2"
    local accelerator="$3"
    
    log_info "🔍 Checking GPU quota in $region..."
    # Simplified check: list quotas and grep for the accelerator type
    # In a real scenario, we'd parse the JSON to see if 'limit' > 'usage'
    local quota_info=$(gcloud compute regions describe "$region" --project="$project" --format="json(quotas)")
    if echo "$quota_info" | grep -q "$accelerator"; then
        log_info "  ✅ Found quota for $accelerator in $region"
    else
        log_warn "Could not confirm $accelerator quota in $region. Deployment might fail later."
    fi
}
