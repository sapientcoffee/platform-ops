# ☕ Platform Ops: The Perfect Roast for Google Cloud

Welcome to the **Platform Ops** repository! 🌟 This is a curated collection of examples and automation designed to help platform engineering teams serve up the best developer experiences on Google Cloud. Think of this as your secret recipe book for building robust, scalable, and delightful Cloud Developer Environments (CDE).

---

## ☕ The Roasting Machine: Cloud Developer Workstations

Cloud Developer Environments are the "espresso shots" of productivity. On Google Cloud, the premium blend is [Cloud Workstations](https://cloud.google.com/workstations), now enhanced with our custom **Local Barista** orchestration.

### 🌟 Why our Cloud Workstations?
*   **Local-First Orchestration**: Deploy infrastructure and bootstrap your machine locally for full visibility and real-time feedback.
*   **GPU-Powered Desktop**: High-performance Sway (Wayland) environments with NVIDIA T4 support.
*   **Automated Freshness**: Built-in triggers to re-roast your images weekly and on every configuration change.
*   **AI-Native Toolkit**: Gemini CLI, Claude Code, and Antigravity come pre-installed and ready to serve.

---

## 📅 Tasting Notes: The Evolution of CDE on GCP

Over the years, our "roasts" have become bolder and more automated:

*   **2016** -> **Cloud Shell** 🐚 (The classic instant coffee: pre-configured and accessible).
*   **2023** -> **[Cloud Workstations](https://cloud.google.com/workstations)** 🏗️ (The professional espresso machine: secure and scalable).
*   **2024** -> **AI Assisted Dev** 🚀 (GenAI integration starts roasting in every workflow).
*   **2025** -> **The Gemini Era** 🤖 (Gemini CLI becomes the essential tool in the barista's belt).
*   **2026** -> **The Workstation Cafe** ✨ (Local orchestration and "Enterprise" Antigravity take productivity to a new dimension).

---

## 📂 What's in the Bag?

### ☕ [The Workstation Cafe (Sway & Nix)](./cloudworkstations/sway/)
Our flagship GPU environment. Features local orchestration (`workstation.sh`), Sway desktop via noVNC, and a full Nix/Home Manager package manager.

### 🏗️ [Google Cloud Workstations (Base)](./cloudworkstations/base/)
The foundation. Dockerfiles and Terraform automation for standing up standard workstation clusters with **YADM** for dotfile management.

### 🤖 [Cloud Builder: Gemini CLI](./cloud-builder-geminicli/)
A specialized Google Cloud Builder image for **Gemini CLI**, enabling AI-powered automation steps directly within your CI/CD pipelines.

### 🛰️ [Antigravity GCE Desktop](./gce/antigravity-remote-desktop/)
A high-performance dedicated VM environment optimized for GUI-intensive IDEs like Antigravity, accessible via Chrome Remote Desktop.

---

Built with ❤️ and a lot of ☕ by the Platform Ops team.
