



The image is automatically built with Cloud Build every week to get the latest changes to the base Code OSS image, and the Cloud Workstations configuration is updated to use the latest tag. The processed is triggered by a Cloud Scheduler rule and images are stored in an Artifact Registry repository.

# Setup Cloud Workstations
You will find the automation to stand up a new Google Cloud Workstation project in [./Automations](./Automation/tf/)