# Cloud Workstations

The home for Cloud Workstation templates and automation examples. 


## Directory Structure
The CloudWorkstations directory contains the following files and directories:

* README.md: This file provides some level of documentaion (you are reading it now)
* [DEPRECATED/](./DEPRECATED/): This directory contains legacy examples, mainly from pre-GA and early access to the product.
* [Automations/](./Automation/): This directory contains the automation to stand up a new Google Cloud Workstation project (still WIP and not been looked at for a while).
* [cloud-oss-image/](./cloud-oss-image/): This director contains some early experimentation for creating a custom image and also customisating the IDE.
* [cloudbuild-worksations-cluster.yaml](./cloudbuild-workstation-cluster.yaml): An experimental Cloud Build manifest for updating cluster config based on a trigger watching repo changes.
* [cloudbuild-worksations.yaml](./cloudbuild-workstations.yaml): Cloud Build Manifest to build the Workstation image and store in Artifact Registry (things are hardcoded at the moment). Can be used in conjunction with a trigger that will automatically update the Workstation container image upon changes to the repo.
* [custom.sh](./custom.sh): Script that is loaded into the Workstation image that is run at creation time to customise the configuration.
* [Dockerfile](./Dockerfile): Defintion to create the workstation container image.
* [p10k.zsh](./p10k.zsh): Terminal prompt configuration that is imported into the container image and transfered to the home directory via custom.sh to customse zsh with [powerlevel10K](https://github.com/romkatv/powerlevel10k) theme.
* [settings.json](./settings.json): The Code OSS settings to customise the look at feel of the IDE interface (e.g. dark theme, enable DuetAI etc.). Transfered to the workstation container imange and the copied to the correct location by custom.sh at deplyment time.
* [zshrc](./zshrc): Zsh configuration that is transfered to the workstation container imange and the copied to the correct location by custom.sh at deplyment time.


## Getting Started
To get started with Cloud Workstations, you can:
* Visit the [Cloud Workstations documentation](https://cloud.google.com/workstations/docs/).
* Clone the CloudWorkstations repository to your local machine.
* <insert instructions here>

### Admin Persona

#### Create a cluster
A workstation cluster holds all the workstations and workstation configs, it also defines which VPC your workstations will be created in. 
* create a file called cluster.json* describing the cluster you want to create 

```json
{
  "network": "projects/your-project/global/networks/default",
  "subnetwork": "projects/your-project/regions/us-central1/subnetworks/default"
}
```

```bash
export PROJECT=your-project #This is the project id
```

```bash
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -d @cluster.json \
"https://workstations.googleapis.com/v1beta/projects/${PROJECT}/locations/us-central1/workstationClusters?workstation_cluster_id=my-cluster"
```

Check its running

```bash
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
"https://workstations.googleapis.com/v1beta/projects/${PROJECT}/locations/us-central1/workstationClusters/my-cluster"

```
#### Create a workstation

config.json
```json
{
  "idleTimeout": "7200s",
  "host": {
    "gce_instance": {
      "machine_type": "e2-standard-8",
      "pool_size": 1
    }
  },
  "persistentDirectories": [
    {
      "mountPath": "/home",
      "gcePd": {
        "sizeGb": 200,
        "fsType": "ext4"
      }
    }
  ]
}
```

Create the config
```bash
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -d @config.json \
"https://workstations.googleapis.com/v1beta/projects/${PROJECT}/locations/us-central1/workstationClusters/my-cluster/workstationConfigs?workstation_config_id=my-config"

```

Check its running -> `reconciling: true` is a good sign
```bash
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
"https://workstations.googleapis.com/v1beta/projects/${PROJECT}/locations/us-central1/workstationClusters/my-cluster/workstationConfigs/my-config"

```

### Customisation 
To customise the workstation image and config follow [here](./custom.md).

### xyz Persona

build container image

test image

`docker run -p 8080:80 gcr.io/cloud-workstations-external/mycustomimage:latest`


### Developer Persona

#### SSH Access

Create a tunnel 
```bash
gcloud alpha workstations start-tcp-tunnel --project=${PROJECT} --region=us-central1 --cluster=my-cluster --config=my-config my-workstation 22 --local-host-port=:2222

```

`ssh user@localhost -p 2222` or `ssh user@127.0.0.1 -p 2222`

`gcloud workstations ssh`

"Remote - SSH" Plugin on local IDE


## Contributing
If you would like to contribute to the CloudWorkstations repository, you can:

* Fork the repository to your own GitHub account.
* Make changes to the code.
* Submit a pull request to the CloudWorkstations repository.



# Notes
Customise the workstation
Machine Settings: Settings that apply globally when you connect to a Cloud Workstations virtual instance and that appear on your workstation in the $HOME/.codeoss-cloudworkstations/settings.json file.

User Settings: Settings that apply globally when you connect to a Cloud Workstations virtual instance and that persist in browser storage for each workstation instance.

Workspace Settings: Settings stored inside a workspace that only apply when opening that workspace. These settings appear with your workspace files in the $WORKSPACE_ROOT/.vscode/settings.json file.

"User" level settings which are written to browser indexed db storage per origin, "Host" level settings are stored on the VM under $HOME/.codeoss-workstations/data/Machine/settings.json, and "Workspace" settings are stored under $WORKSPACE_ROOT/.vscode/settings.json. Overridden settings are resolved in the aforementioned order (User, Machine, Workspace), so If users wish to configure settings at image startup time they should be able to just write them to $HOME/.codeoss-workstations/data/Machine/settings.json.
$HOME/.codeoss-cloudworkstations instead of /.codeoss-workstations




The image is automatically built with Cloud Build every week to get the latest changes to the base Code OSS image, and the Cloud Workstations configuration is updated to use the latest tag. The processed is triggered by a Cloud Scheduler rule and images are stored in an Artifact Registry repository.

# Setup Cloud Workstations
You will find the automation to stand up a new Google Cloud Workstation project in [./Automations](./Automation/tf/)