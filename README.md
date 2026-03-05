# Platform Operations
Building a collection of examples that platform engineering teams could leverage to help with solving user challenges on Google Cloud.

## Cloud Developer Workstations
Cloud Developer Environments (CDE) can be a useful tool to help developers get things done. The option on Google Cloud is [Cloud Workstations](https://cloud.google.com/workstations). They can help solve common challenges that sap the time of development teams: things like environment setup (onboarding, cost of high-end machines, say GPUs), security and exfiltration guardrails (control location of stored source code, securing of workstations), and productivity (accessing resources inside private networks, build times, complex artifacts). 

Two personas that emerge are:
* Admins/platform engineers (manage environments and provide access to developers including security policies and secure images)
* Developers (consumers of on-demand, pre-configured environments that can be accessed anywhere a browser is available)

Over the years the capabilities and offerings have grown on Google Cloud:
* 2016 -> Cloud Shell (Online pre-configured dev environment and terminal with basic code editor)
* 2019 -> [Cloud Code](https://cloud.google.com/code) (Plugins for IntelliJ and VSCode, automation and assistance in the IDE)
* 2020 -> [Cloud Shell Editor](https://cloud.google.com/shell) (Updated IDE with source control, debugger and emulators including enabling quick exploration of cloud services)
* 2023 -> [Cloud Workstations](https://cloud.google.com/workstations)
* 2023 -> [Project IDX](https://developers.google.com/idx) (part of a wider Google experimental new initiative aimed at bringing your entire full-stack, multiplatform app development workflow to the cloud)
* 2024 -> AI Assisted Dev 🚀 (GenAI integration into core development workflows)
* 2025 -> AI Assisted Dev 🤖 (AI agents like Jules alter the paradigm; `Gemini CLI` emerges as a key addition)
* 2026 -> AI Assisted Dev ✨ (Release of "Enterprise" version of Antigravity)

So what is the difference between Cloud Shell and Cloud Workstations?
* Cloud Shell (onboarding/learning focused)
  * Pre-configured environment
  * Focus on simple onboarding tasks
  * Integrated with GCP dev tools
  * Accessible from the browser
  * Free, requires no project
  * 5GB of persistent disk
* Cloud Workstations (enterprise grade)
  * Fully customisable environment
  * Full fledged IDE/Dev Environment (choice of IDE)
  * Integrated with GCP dev tools
  * Accessible via browser/SSH/Local IDE
  * Runs on customer owned VMs/Disks
  * Support for VPC and security policies

The following is a high-level overview of remote development in GCP using Cloud Shell and Cloud IDE (note: our legacy Cloud Shell and GitPod examples have been archived; please refer to the `CloudWorkstations` folder for modern implementations):
![](Remote-Developer-Environment.jpg)

### Google Cloud Workstations
Configuration examples and demos are in the [CloudWorkstations](CloudWorkstations/) folder.

### Other Experiments
* **Cloud Build Codey:** Located in the `cloud_build_codey/` folder. Note that this is an early deprecated version. The latest development for this experiment has moved to [GitLab](https://gitlab.com/robedwards/coffee-and-codey.git).
