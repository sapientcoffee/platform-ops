# 🪐 Cloud Workstations - JupyterLab

This directory contains the custom container configuration for running JupyterLab on Google Cloud Workstations.

This setup is built on top of the official Google Cloud Workstations base image, meaning it inherits all the required components for SSH tunneling, persistent home directories, and VPC-SC compatibility. 

## 📦 What's Included

* **Base:** `us-central1-docker.pkg.dev/cloud-workstations-images/predefined/base:latest`
* **Python 3**
* **JupyterLab** (Running securely behind Identity-Aware Proxy)
* **PyTorch** (with CUDA support bundled)

## 🚀 Deployment Instructions

To use this image in your Cloud Workstations environment, you need to build the Docker image, push it to your Google Cloud Artifact Registry, and update your Workstation Configuration.

### 1. Build and Push the Image

Using Google Cloud Build (recommended):

```bash
export PROJECT_ID="coffee-and-codey"
export REGION="us-central1"
export REPO="jupyter-workstation"
export IMAGE_NAME="jupyter-image:latest"

gcloud builds submit \
    --region=${REGION} \
    --tag ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME} \
    .
```

Alternatively, build and push locally using Docker:

```bash
# Build the image
docker build -t ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME} .

# Authenticate Docker to Artifact Registry
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Push the image
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}
```

### 2. Update Workstation Configuration

Once the image is in Artifact Registry, update your Cloud Workstations Configuration to use it.

**Via Google Cloud Console:**
1. Navigate to **Cloud Workstations** > **Workstation Configurations**.
2. Select your configuration and click **Edit**.
3. Under **Environment**, select **Custom container image**.
4. Enter the path to your newly pushed image (e.g., `${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE_NAME}`).
5. Save the configuration.

**Via gcloud CLI:**
*(Note: As of this writing, some custom container updates may require the REST API or Terraform, depending on your setup. Refer to your local `/Automation/tf` scripts for Terraform-based updates).*

## 💡 How It Works (The "Magic")

1. **Port 80 to 8080 Routing:** Cloud Workstations uses an internal Envoy proxy that routes traffic from a secure external URL (on port 80/443) to port `8080` inside the container. Our Dockerfile explicitly configures JupyterLab to serve on port `8080` to meet this requirement.
2. **Authentication:** The Workstation's Identity-Aware Proxy (IAP) handles user authentication and authorization before the traffic even reaches the container. Because of this, we disable Jupyter's internal token/password authentication (`--ServerApp.token=''`) for a seamless login experience.
3. **Persistence:** The base image automatically mounts the workstation's persistent disk to `/home/user`. Anything saved in this directory survives workstation restarts.

## 🧪 Usage

1. Start your workstation from the Google Cloud Console or using the `gcloud workstations start` command.
2. Click the **Launch** button to open the workstation in your browser.
3. You will be greeted directly by the JupyterLab interface, fully authenticated and ready to go!
