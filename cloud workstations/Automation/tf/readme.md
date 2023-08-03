# Work in Progress
# Google Cloud Workstations

The following is a sandbox for rapid experimentation and demo'ing of Google Cloud Workstations.

## Terraform 
The initial setup leverages terraform to;
<!-- * Create a new project -->
* Create workstation cluster (~20 min to spinup)
* Create basic workstaion configuration
  * Code OSS (Base Editor)
  * 
* Deploy a workstaion (powered off)


Argolis - org policy Constraint constraints/compute.vmExternalIpAccess


Customise the workstation
Machine Settings: Settings that apply globally when you connect to a Cloud Workstations virtual instance and that appear on your workstation in the $HOME/.codeoss-cloudworkstations/settings.json file.

User Settings: Settings that apply globally when you connect to a Cloud Workstations virtual instance and that persist in browser storage for each workstation instance.

Workspace Settings: Settings stored inside a workspace that only apply when opening that workspace. These settings appear with your workspace files in the $WORKSPACE_ROOT/.vscode/settings.json file.

"User" level settings which are written to browser indexed db storage per origin, "Host" level settings are stored on the VM under $HOME/.codeoss-workstations/data/Machine/settings.json, and "Workspace" settings are stored under $WORKSPACE_ROOT/.vscode/settings.json. Overridden settings are resolved in the aforementioned order (User, Machine, Workspace), so If users wish to configure settings at image startup time they should be able to just write them to $HOME/.codeoss-workstations/data/Machine/settings.json.
$HOME/.codeoss-cloudworkstations instead of /.codeoss-workstations