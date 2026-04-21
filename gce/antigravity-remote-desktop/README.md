# 🛰️ Antigravity: Remote GCE Developer Desktop

Welcome to the **Next-Gen CDE** setup for Google Cloud! 🚀 While Cloud Workstations are great for containerized workflows, some high-performance GUI IDEs like **Antigravity** perform best in a dedicated VM environment.

This module provides a **"Disposable VM / Persistent Data"** architecture using Google Compute Engine.

---

## 🏗️ The Architecture: "The Persistent Home"

We solve the "how do I keep it up-to-date" problem by separating the OS from your data:

1.  **Disposable OS Boot Disk**: A 50GB Ubuntu 24.04 LTS disk. We treat this as "cattle, not pets."
2.  **Persistent Home Disk**: A separate, high-speed SSD disk (default 100GB) mounted to `/home/developer`. This stores your code, configs, and `antigravity` project data.
3.  **Automated Startup**: A shell script (`scripts/startup.sh`) that installs:
    *   **XFCE4**: A lightweight desktop environment.
    *   **Chrome Remote Desktop**: For high-performance, low-latency GUI access.
    *   **Google Chrome**: The web browser.
    *   **GitHub CLI (`gh`)**: For seamless Git workflows.
    *   **Antigravity IDE**: The flagship development environment.

We also provision a firewall rule to allow SSH access via Identity-Aware Proxy (IAP).

---

## ☕ Brewing Instructions (Usage)

### 1. Initialize Terraform
```bash
cd Automation/tf
terraform init
```

### 2. Deploy
Create a `terraform.tfvars` file or pass variables at the command line:
```bash
terraform apply -var project_id="YOUR_PROJECT_ID"
```

### 3. Connect via Chrome Remote Desktop
1.  **SSH into the VM**: 
    Use the command from the terraform output: `gcloud compute ssh antigravity-desktop --zone us-central1-a`
2.  **Generate Auth Code**: 
    On your local machine, go to [remotedesktop.google.com/headless](https://remotedesktop.google.com/headless) and copy the "Debian Linux" command.
3.  **Authorize**: 
    Paste that command into the VM's SSH terminal. It will prompt you for a 6-digit PIN.
4.  **Launch**: 
    Go to [remotedesktop.google.com/access](https://remotedesktop.google.com/access) and click on your new VM to launch your Antigravity desktop!

---

## 🔄 Maintenance & Updates

When you want to refresh the OS or update the base images:

1.  **Destroy the VM ONLY**:
    ```bash
    terraform destroy -target=google_compute_instance.developer_desktop
    ```
2.  **Re-deploy**:
    ```bash
    terraform apply
    ```

Because the `google_compute_disk.developer_home` remains intact, the new VM will automatically mount your existing home directory. You just need to re-run the 2-minute Chrome Remote Desktop authentication step, and you're back in business with a fresh OS and all your data!

---
*Built for speed, designed for persistence.* ☕🛰️
