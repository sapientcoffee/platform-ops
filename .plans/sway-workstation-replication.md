# Objective
Replicate the Sway/NoVNC cloud workstation configuration from `ameer00/cloud-workstations` into a new `CloudWorkstations-Sway` directory within the `platform-ops` repository. Integrate the base Docker image build with the existing Kaniko CI/CD pipeline, while maintaining the dynamic, script-based setup for Sway and Nix.

# Key Files & Context
- **Source Directory:** `tmp/cloud-workstations/`
- **Target Directory:** `CloudWorkstations-Sway/`
- **New Build Pipeline:** `CloudWorkstations-Sway/cloudbuild-sway.yaml`

# Implementation Steps

1. **Create Directory Structure:**
   - Create the `CloudWorkstations-Sway` directory at the repository root.
   - Create `CloudWorkstations-Sway/workstation-image/` and `CloudWorkstations-Sway/scripts/`.

2. **Copy Core Configuration & Scripts:**
   - Copy `tmp/cloud-workstations/workstation-image/*` into `CloudWorkstations-Sway/workstation-image/`.
   - Copy `tmp/cloud-workstations/scripts/*` into `CloudWorkstations-Sway/scripts/`.
   - Copy `tmp/cloud-workstations/README.md` into `CloudWorkstations-Sway/README.md`.

3. **Adapt Paths in Setup Scripts:**
   - In `CloudWorkstations-Sway/scripts/ws.sh`:
     Update the embedded Cloud Build YAML (around line 261) to invoke the setup script from its new path:
     `bash CloudWorkstations-Sway/scripts/cloud-build-setup.sh ...`
   - In `CloudWorkstations-Sway/scripts/cloud-build-setup.sh`:
     Update the working directory for the Docker build (around line 218):
     Change `cd "${REPO_DIR}/workstation-image"` to `cd "${REPO_DIR}/CloudWorkstations-Sway/workstation-image"`.

4. **Integrate Kaniko CI/CD Build:**
   - Create `CloudWorkstations-Sway/cloudbuild-sway.yaml` modeling after the existing `CloudWorkstations/cloudbuild-workstations.yaml`:
     ```yaml
     steps:
     # 1. 🏗️ Build & Multi-Tag: Build once, tag twice (Latest + Git SHA)
     - name: 'gcr.io/kaniko-project/executor:latest'
       args: [
         "--destination=us-central1-docker.pkg.dev/coffee-plantation/workstation/sway-novnc:latest",
         "--destination=us-central1-docker.pkg.dev/coffee-plantation/workstation/sway-novnc:$COMMIT_SHA",
         "--dockerfile=./CloudWorkstations-Sway/workstation-image/Dockerfile",
         "--context=dir:///workspace/CloudWorkstations-Sway/workstation-image",
         "--cache=true",
         "--cache-ttl=24h"]
       id: "Building & Tagging Sway Image"

     # 2. 🧪 Smoke Tests: Ensure NoVNC and Tailscale are present in the base image
     - name: 'us-central1-docker.pkg.dev/coffee-plantation/workstation/sway-novnc:$COMMIT_SHA'
       entrypoint: 'bash'
       args: 
         - '-c'
         - |
           set -e
           echo "Running Smoke Tests..."
           cat /etc/os-release
           tailscale --version
           echo "✅ Base utilities verified!"
       id: "Sanity Check - Tooling"

     # 3. 🔍 Security Scan: Check for vulnerabilities
     - name: 'aquasec/trivy:latest'
       args: ['image', '--severity', 'HIGH,CRITICAL', '--exit-code', '0', 'us-central1-docker.pkg.dev/coffee-plantation/workstation/sway-novnc:$COMMIT_SHA']
       id: "Vulnerability Scan"

     timeout: '3600s'
     logsBucket: 'gs://coffee-plantation_cloudbuild/logs'
     options:
       logging: GCS_ONLY
       logStreamingOption: STREAM_ON
     ```

# Verification & Testing
1. **Directory Inspection:** Ensure `CloudWorkstations-Sway` contains the `workstation-image/`, `scripts/`, and `cloudbuild-sway.yaml` files.
2. **Path Verification:** Check that `ws.sh` and `cloud-build-setup.sh` correctly reference `CloudWorkstations-Sway/` internally.
3. **Execution Test:** Run `bash CloudWorkstations-Sway/scripts/ws.sh setup -p <PROJECT_ID>` locally (using a test GCP project) to confirm the end-to-end dynamic setup completes successfully.
4. **CI/CD Test:** Commit changes and trigger the new `cloudbuild-sway.yaml` to ensure Kaniko successfully builds and caches the new `sway-novnc` image in Artifact Registry.
