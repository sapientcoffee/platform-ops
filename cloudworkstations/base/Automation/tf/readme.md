# 🏗️ High-Capacity Roasting: Terraform Automation

Welcome to the **Master Roaster's Control Panel**! 🏗️ This directory contains the Terraform configurations required to stand up a high-performance Google Cloud Workstations environment from scratch. 

Think of this as the blueprints for building your own industrial-scale coffee roastery.

---

## ☕ Prerequisites (The Raw Ingredients)

Before you start roasting, ensure you have:
*   A Google Cloud Project (The building).
*   The Terraform CLI installed (The assembly tool).
*   Google Cloud Provider for Terraform (The connection to the power grid).

---

## 🚀 Brewing Instructions (Usage)

To get your workstation cluster percolating, follow these steps:

1.  **Prep the beans**: Change your directory to this `tf/` folder.
2.  **Initialize the machine**:
    ```bash
    terraform init
    ```
3.  **The Master Plan**: Preview what's about to be built:
    ```bash
    terraform plan -var name=coffee-station -var billing_account=YOUR_ID -var parent="YOUR_ORG_OR_FOLDER"
    ```
4.  **Fire it up**: Apply the configuration to build your cluster:
    ```bash
    terraform apply -var name=coffee-station -var billing_account=YOUR_ID -var parent="YOUR_ORG_OR_FOLDER"
    ```

---

## 📂 The Machine Components (Configuration)

*   **Provider**: Defines our connection to the Google Cloud "power grid."
*   **Resources**: The actual "espresso machines" (clusters, configs, and workstations).
*   **Outputs**: Your receipt—provides the Project IDs and connection details once the build is complete.

---

## 🛠️ Troubleshooting & Support

Having trouble getting the machine to start? Check these resources:
*   [Terraform Documentation](https://www.terraform.io/docs)
*   [Google Cloud Workstations Docs](https://cloud.google.com/workstations/docs/)

---

## 🧪 Work in Progress: The Sandbox

This is currently a sandbox for rapid experimentation. We are fine-tuning the following:
*   Automatically creating a new project for every workstation cluster.
*   Deploying pre-powered-off workstations to keep costs as low as a cup of decaf!

---
*Built for scale, roasted to perfection.* ☕✨
