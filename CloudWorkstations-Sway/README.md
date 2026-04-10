# Cloud Workstation

GPU-powered Cloud Workstation in GCP with Sway desktop, Nix package manager, and a full dev environment — accessible from any browser via noVNC.

## Quick Start

1. Fork and clone this repo
2. Run `bash scripts/ws.sh setup -p YOUR_PROJECT_ID`

## Setup

### Prerequisites

1. A GCP project where you have **Owner** role
2. **NVIDIA T4 GPU quota** in `us-west1` (at least 1) — [check/request quota here](https://console.cloud.google.com/iam-admin/quotas?metric=NVIDIA_T4_GPUS)
3. **Cloud Shell** (recommended) or any terminal with `gcloud` CLI

### Step 1: Authenticate

Open [Cloud Shell](https://shell.cloud.google.com) and run:

```bash
gcloud auth login
```

### Step 2: Clone and run setup

```bash
git clone https://github.com/your-github-username/cloud-workstations.git
cd cloud-workstations
bash scripts/ws.sh setup -p YOUR_PROJECT_ID
```

Replace `YOUR_PROJECT_ID` with your GCP project ID. The repo URL is auto-detected from your git remote — no configuration needed.

**You can close your terminal immediately after the script prints the build ID.** All work runs inside Cloud Build and will continue independently.

### Step 3 (optional): Get notified when it's done

#### Google Chat webhook

1. Open [Google Chat](https://chat.google.com) → Create a Space → Space name → **Apps & integrations** → **Manage webhooks** → Copy URL

```bash
bash scripts/ws.sh setup -p YOUR_PROJECT_ID -w "YOUR_WEBHOOK_URL"
```

#### Email

```bash
bash scripts/ws.sh setup -p YOUR_PROJECT_ID -e "you@example.com"
```

#### Both

```bash
bash scripts/ws.sh setup -p YOUR_PROJECT_ID -w "YOUR_WEBHOOK_URL" -e "you@example.com"
```

You'll receive notifications when:
- Build starts (with link to Cloud Console)
- Docker image is built
- Workstation is running
- Setup completes (with workstation URL) or fails (with error details)

### Track progress

The setup script prints a Cloud Console link. You can also stream logs:

```bash
gcloud builds log BUILD_ID --stream --project=YOUR_PROJECT_ID --region=us-west1
```

### Install Profiles

Choose a profile to control what gets installed:

| Profile | What's Included | Build Time |
|---------|----------------|------------|
| `minimal` | Sway desktop, ZSH, Chrome, Antigravity, dev tools | ~14 min |
| `dev` | minimal + tmux + Claude Code | ~25 min |
| `ai` | dev + AI IDEs + AI CLI tools | ~35 min |
| `full` | Everything including Go, Rust, Python, Ruby | ~55 min |

```bash
# Default (full profile)
bash scripts/ws.sh setup -p YOUR_PROJECT_ID

# Minimal profile (fastest)
bash scripts/ws.sh setup -p YOUR_PROJECT_ID --profile minimal

# AI profile (IDEs + AI tools, no languages)
bash scripts/ws.sh setup -p YOUR_PROJECT_ID --profile ai

# Custom modules
bash scripts/ws.sh setup -p YOUR_PROJECT_ID --profile custom --modules "ides,ai-tools"
```

The `~/.ws-modules` config file records which modules are enabled. Boot scripts and tests automatically adapt to the selected profile.

## After Setup

### Start your workstation

The setup script stops the workstation at the end to save costs. Start it when you're ready:

```bash
gcloud workstations start dev-workstation \
  --config=ws-config \
  --cluster=workstation-cluster \
  --region=us-west1 \
  --project=YOUR_PROJECT_ID
```

### Connect via browser

Get the workstation URL:

```bash
gcloud workstations describe dev-workstation \
  --config=ws-config \
  --cluster=workstation-cluster \
  --region=us-west1 \
  --project=YOUR_PROJECT_ID \
  --format="value(host)"
```

Open `https://<host>` in your browser. The noVNC desktop loads automatically with 4 pre-launched workspaces.

### Weekday auto-start/stop

Cloud Scheduler jobs manage the workstation automatically:
- **Start**: Weekdays (Mon-Fri) at **6:00 AM Pacific**
- **Stop**: Weekdays (Mon-Fri) at **9:00 PM Pacific**
- Workstations stay off on weekends to save costs.

## What's Included

| Component | Details |
|-----------|---------|
| **Machine** | n1-standard-16 (60GB RAM) + NVIDIA Tesla T4 GPU (16GB VRAM) |
| **Storage** | 500GB persistent SSD (all data survives reboots) |
| **Desktop** | Sway (Wayland) with Tokyo Night theme, accessed via noVNC in browser |
| **Terminal** | foot terminal, ZSH + Starship prompt, Operator Mono Book font (size 18), tmux with Tokyo Night theme |
| **Fonts** | Operator Mono, CascadiaCode, CaskaydiaCove Nerd Font, FiraCodeiScript |
| **Browsers** | Google Chrome, Chromium |
| **IDEs** | VS Code, Cursor, Windsurf, Zed, IntelliJ IDEA, Neovim (custom config) |
| **AI Tools** | Claude Code, Gemini CLI, Codex CLI, OpenCode, Aider, Cody CLI, pi-coding-agent, GitHub Copilot CLI |
| **Languages** | Go (latest), Rust (via rustup), Python 3.12 (via pyenv), Ruby 3.3 (via rbenv), Node.js 22 (via Nix) |
| **Apps** | Antigravity, tmux, ripgrep, fd, jq, ffmpeg, wofi, thunar, clipman |
| **Networking** | Tailscale VPN (opt-in via `~/.env`) |
| **Auto-start** | Cloud Scheduler starts workstation weekdays at 6AM PT, stops at 9PM PT |
| **Boot apps** | 4 workspaces auto-launch: terminal, Chrome, Antigravity, terminal |
| **Profiles** | Composable install: minimal (14 min), dev, ai, full (55 min) — `--profile` flag |
| **Boot tests** | 80+ automated tests run on every boot — results at `~/logs/boot-test-results.txt` |
| **Packages** | Managed via Nix Home Manager on persistent disk |

## Keyboard Shortcuts

All shortcuts use `CTRL+SHIFT` as the modifier (works through noVNC in browser).

| Shortcut | Action |
|----------|--------|
| `CTRL+SHIFT+Enter` | New terminal (foot) |
| `CTRL+SHIFT+T` | New terminal (foot) |
| `CTRL+SHIFT+B` | Chrome browser |
| `CTRL+SHIFT+N` | Antigravity |
| `CTRL+SHIFT+Y` | VS Code |
| `CTRL+SHIFT+W` | Windsurf |
| `CTRL+SHIFT+M` | IntelliJ IDEA |
| `CTRL+SHIFT+R` | App launcher (wofi) |
| `CTRL+SHIFT+A` | Clipboard history (clipman) |
| `CTRL+SHIFT+S` | Snippet picker |
| `CTRL+SHIFT+E` | File manager (thunar) |
| `CTRL+SHIFT+D` | Toggle floating window |
| `CTRL+SHIFT+Q` | Close window |
| `CTRL+SHIFT+F` | Toggle fullscreen |
| `CTRL+SHIFT+U/I/O/P` | Switch to workspace 1/2/3/4 |
| `CTRL+SHIFT+H/J/K/L` | Switch to workspace 5/6/7/8 |
| `CTRL+SHIFT+Alt+U/I/O/P` | Move window to workspace 1/2/3/4 |
| `CTRL+SHIFT+Alt+H/J/K/L` | Move window to workspace 5/6/7/8 |
| `CTRL+SHIFT+Arrow keys` | Focus window left/right/up/down |
| `CTRL+SHIFT+,/.` | Grow/shrink window width |
| `CTRL+SHIFT+-/=` | Shrink/grow window height |
| `CTRL+SHIFT+Escape` | Exit Sway (with confirmation) |

## Language Version Management

Languages are managed by native version managers for easy multi-version support:

| Language | Manager | Switch Versions |
|----------|---------|----------------|
| Go | Direct install | Download from go.dev |
| Rust | rustup | `rustup install nightly` |
| Python | pyenv | `pyenv install 3.11 && pyenv global 3.11` |
| Ruby | rbenv | `rbenv install 3.2.0 && rbenv global 3.2.0` |
| Node.js | Nix | Managed via Home Manager |

## tmux + Claude Code Aliases

The workstation includes crash-resistant tmux sessions pre-configured for Claude Code:

| Alias | Description |
|-------|-------------|
| `t1` through `t10` | Launch Claude Code in named tmux sessions (`claude-1` through `claude-10`) |
| `cc` | Alias for `t1` (quick start) |
| `tdbg` | Launch Claude Code in a debug tmux session with server-level logging to `~/logs/tmux/` |

Sessions use `claude-tmux`, a wrapper that auto-launches `claude --dangerously-skip-permissions` inside tmux. If the session already exists, it reattaches. tmux is configured with Tokyo Night theme, mouse support, true color, and vi copy mode.

## Tailscale VPN (Optional)

Tailscale provides secure SSH access to your workstation without port forwarding or VPNs.

To enable, add these to `~/.env` on your workstation:

```bash
TAILSCALE_AUTHKEY=tskey-auth-xxxxx   # From https://login.tailscale.com/admin/settings/keys
USER_PASSWORD=your-ssh-password       # Optional: sets SSH password for the 'user' account
```

On the next boot, the workstation will:
1. Auto-install Tailscale (if the binary is missing from the ephemeral root disk)
2. Start the Tailscale daemon
3. Authenticate with your auth key
4. Enable Tailscale SSH
5. Set the SSH password (if `USER_PASSWORD` is defined)

You can then SSH via `ssh user@<workstation-tailscale-hostname>`.

## Boot Tests

Every boot runs 80+ automated tests to verify the workstation is healthy. Results are saved to:

- `~/logs/boot-test-results.txt` — full PASS/FAIL/WARN details
- `~/logs/boot-test-summary.txt` — one-line summary (e.g., `PASS: 77 | FAIL: 0 | WARN: 3`)

Tests cover: Nix, GPU, Sway, fonts, shell, AI tools, IDEs, languages, keybindings, clipboard, snippets, and more.

## Re-running Setup

The setup is fully **idempotent**. If it fails or you want to update, just run it again:

```bash
bash scripts/ws.sh setup -p YOUR_PROJECT_ID
```

Existing resources are detected and skipped. Only missing components are created.

## Teardown / Cleanup

To delete **all** resources created by setup (workstation, cluster, images, NAT, scheduler):

```bash
bash scripts/ws.sh teardown -p YOUR_PROJECT_ID
```

Add `-y` to skip the confirmation prompt. Add `-w` / `-e` for notifications.

This is useful for:
- Testing setup from scratch
- Cleaning up a project you no longer need
- Freeing GPU quota for another project

After teardown, you can re-run `setup.sh` to recreate everything.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "No GPU quota" | [Request NVIDIA_T4_GPUS quota](https://console.cloud.google.com/iam-admin/quotas) in us-west1 (at least 1) |
| Build fails mid-way | Re-run `ws.sh setup` — it picks up where it left off (idempotent) |
| Can't connect via noVNC | Ensure workstation is started, wait 30s for Sway + wayvnc to boot |
| Apps not on workspaces | Wait 15-20s after boot for auto-launch to complete |
| Cloud Shell disconnected | No problem — Cloud Build continues independently. Check progress in Cloud Console |
| IDE keybinding not working | Check `~/logs/boot-test-results.txt` for related FAIL entries |
| Claude Code not working | Ensure `~/.env` has your API keys — it's sourced automatically on boot |
| Boot test failures | Run `cat ~/logs/boot-test-results.txt` to see full PASS/FAIL details |
