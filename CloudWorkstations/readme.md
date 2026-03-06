# 🏗️ Google Cloud Workstations: The Roastery

Welcome to the heart of the operation! 🏗️ This directory contains everything you need to brew, automate, and customize your premium **Google Cloud Workstations**. Whether you're a Master Roaster (Admin) or a Barista (Developer), you'll find the right tools here to serve up a world-class coding experience.

---

## 📋 The Menu (Directory Structure)

Explore our specialized blends:

*   **[Automation/](./Automation/)**: The high-capacity roasting machine. Terraform configurations to stand up entire workstation clusters and projects from scratch.
*   **[cloud-oss-image/](./cloud-oss-image/)**: Experimental micro-roasts. Early tests for creating and customizing the IDE environment.
*   **[DEPRECATED/](./DEPRECATED/)**: Legacy beans. Historical examples from the pre-GA days.
*   **[Dockerfile](./Dockerfile)**: The secret recipe. Defines the custom container image with all your essential tools and plugins.
*   **[200_custom.sh](./200_custom.sh)**: The morning ritual. A startup script that configures your environment (now with **YADM** dotfile support!).
*   **[settings.json](./settings.json)**: The perfect grind. Custom Code OSS settings for a consistent IDE look and feel.

---

## ☕ Brewing Guide (Getting Started)

### 👑 The Master Roaster (Admin Persona)

#### 1. Create a Cluster
A workstation cluster is your "espresso machine"—it holds all your configurations and defines the VPC where the magic happens.

Define your `cluster.json`:
```json
{
  "network": "projects/your-project/global/networks/default",
  "subnetwork": "projects/your-project/regions/us-central1/subnetworks/default"
}
```

Fire up the machine:
```bash
export PROJECT=your-project
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "Content-Type: application/json" \
     -d @cluster.json \
     "https://workstations.googleapis.com/v1beta/projects/${PROJECT}/locations/us-central1/workstationClusters?workstation_cluster_id=my-cluster"
```

#### 2. Create a Workstation Configuration
This is your "recipe" for the individual workstations.

```bash
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "Content-Type: application/json" \
     -d @config.json \
     "https://workstations.googleapis.com/v1beta/projects/${PROJECT}/locations/us-central1/workstationClusters/my-cluster/workstationConfigs?workstation_config_id=my-config"
```

---

### 🛠️ The Platform Engineer (Maintainer Persona)

Maintaining the organization's base image is key to a consistent flavor.

```bash
# Submit a new roast to Artifact Registry
gcloud builds submit --region=us-central1 --tag us-west2-docker.pkg.dev/PROJECT_ID/repo/image:tag1
```

---

### 💻 The Barista (Developer Persona)

#### SSH Access (The Private Tasting Room)
Need to get close to the metal? Create a secure tunnel:

```bash
gcloud alpha workstations start-tcp-tunnel \
    --project=${PROJECT} --region=us-central1 \
    --cluster=my-cluster --config=my-config \
    my-workstation 22 --local-host-port=:2222
```

Then simply: `ssh user@localhost -p 2222`

---

## 🔄 CI/CD Workflow: The Automatic Grinder

We use **Google Cloud Build** to ensure your beans are always fresh.

### 🚀 Automation & Triggers
Our pipeline lives in the GCP project `coffee-plantation`.

| Event | Action | Outcome |
| :--- | :--- | :--- |
| **Commit to Branch / PR** | *No automatic action* | Verification builds are currently manual. |
| **Merge to `main`** | Triggers Cloud Build | Rebuilds the custom Code OSS image and pushes to Artifact Registry. |

### 🛠️ Build Process (`cloudbuild-workstations.yaml`)
Using **Kaniko** for a clean, daemon-less build:
1.  **Context**: Builds relative to the `CloudWorkstations/` directory.
2.  **Caching**: Layer caching enabled (24h) for lightning-fast updates.
3.  **Storage**: Pushed to `europe-docker.pkg.dev/coffee-plantation/workstation/codeoss:latest`.

---

## 🎨 Customization: Personalize Your Cup

Want to tweak your environment? Check out the **[Customization Guide](./custom.md)** to learn about:
*   **Machine Settings**: Global VM settings stored in `$HOME/.codeoss-cloudworkstations/settings.json`.
*   **YADM Dotfiles**: How we pull your personal config from GitHub on every start.
*   **Starship & Zsh**: Serving up a beautiful, informative terminal.

---

Built with ❤️ and ☕. Keep brewing!
