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

## Contributing
If you would like to contribute to the CloudWorkstations repository, you can:

* Fork the repository to your own GitHub account.
* Make changes to the code.
* Submit a pull request to the CloudWorkstations repository.







The image is automatically built with Cloud Build every week to get the latest changes to the base Code OSS image, and the Cloud Workstations configuration is updated to use the latest tag. The processed is triggered by a Cloud Scheduler rule and images are stored in an Artifact Registry repository.

# Setup Cloud Workstations
You will find the automation to stand up a new Google Cloud Workstation project in [./Automations](./Automation/tf/)