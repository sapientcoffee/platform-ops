# 🎨 Personalizing Your Roast: Customizing Your Cloud Environment

Welcome to the **Barista's Laboratory**! 🎨 We all know the thrill of dialling in that perfect environment—it's like finding the exact grind setting for a fresh bag of Ethiopian beans. This guide covers how we take a standard Cloud Workstation and transform it into a high-performance, personalized coding machine.

---

## 🚀 Step 1: The Base Recipe (Dockerfile)

Every great brew starts with quality beans. We use the Google-maintained **Code OSS** image as our base and then spice it up with our essential tools.

### 🛠️ Adding the Essentials
We've optimized our `Dockerfile` to install everything in one smooth pour (layer). We include:
*   **Terraform & Kustomize**: For infrastructure as code.
*   **Firebase CLI**: For full-stack magic.
*   **YADM**: Our secret ingredient for dotfile management.
*   **Zsh, Tmux, Neovim**: The triple-shot of terminal productivity.

### 🧩 VS Code Plugins
We bake our favourite extensions directly into the image from [Open VSX](https://open-vsx.org/). This ensures that the moment your workstation boots, you have:
*   HashiCorp Terraform support.
*   Java, Maven, and JUnit testing tools.
*   Dart & Flutter development environments.

---

## 💥 Step 2: The Morning Ritual (Initialization Script)

A great barista has a consistent routine. Our `200_custom.sh` script runs every time a workstation is created or restarted, ensuring your environment is always perfectly balanced.

### 🐚 The YADM Magic
Instead of manually copying dotfiles, we use **YADM** (Yet Another Dotfile Manager) to clone your personal configuration directly from GitHub:

```bash
runuser user -c 'yadm clone https://github.com/sapientcoffee/dotfiles.git'
```

This brings in your:
*   🚀 **Starship** prompt for a beautiful terminal.
*   ⌨️ **Neovim (Lazy.nvim)** config for elite editing.
*   🪟 **Tmux** setup for session management.

### ⚙️ Machine vs. User Settings
Cloud Workstations handle settings in three layers:
1.  🌟 **Machine Settings**: Applied globally to the VM. We copy our `settings.json` to `$HOME/.codeoss-cloudworkstations/data/Machine/`.
2.  🌟 **User Settings**: Persistent settings that follow you across instances.
3.  🌟 **Workspace Settings**: Project-specific settings found in `.vscode/settings.json`.

---

## 🔐 Handling the Secret Sauce

We never commit "spices" (API keys or tokens) to the main repository. Instead, our `setup.sh` script is designed to append sensitive configurations (like NVM paths) to a local `~/.secrets` file. 

This file is:
*   **Sourced automatically** by our Zsh configuration.
*   **Ignored by Git** via YADM.
*   **Perfect** for storing your private tokens and keys locally on the workstation.

---

## ☕ Keep Brewing!

Want to help us refine the roast? Feel free to fork the repo or submit a PR with your favorite plugins or terminal tweaks. Let's keep the coding excitement (and the caffeine) flowing! 🚀💻✨
