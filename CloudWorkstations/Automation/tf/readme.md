# Google Cloud Workstations Terraform Configuration
This Terraform configuration file can be used to create a Google Cloud Workstations cluster and deploy a workstation.

## Prerequisites
To use this configuration file, you will need the following:
* A Google Cloud project
* The Terraform CLI installed
* The Google Cloud provider for Terraform installed

## Usage
To use this configuration file, follow these steps:
* Create a new Google Cloud project.
* Install the Terraform CLI.
* Install the Google Cloud provider for Terraform.
* Clone this repository to your local machine.
* Change directory to the tf directory.
* Initialize Terraform.
* Apply the Terraform configuration.
* Once the Terraform configuration has been applied, you will have a Google Cloud Workstations cluster and a workstation deployed.

## Configuration
The Terraform configuration file is divided into several sections. The following is a brief overview of each section:
* provider - This section defines the Google Cloud provider that will be used to create the resources.
* resource - This section defines the resources that will be created.
* output - This section defines the outputs that will be produced by the Terraform configuration.

## Examples
The following are some examples of how you can use the Terraform configuration file:
* To create a Google Cloud Workstations cluster with a single workstation, you can use the following command:


```hcl
terraform apply -var name=coffee-station -var billing_account=017C65-6AC5ED-18E460 -var parent="robedwards.altostrat.com/"
```
Or if you prefer to a plan 1st.

```
terraform plan -var name=coffee-station -var billing_account=017C65-6AC5ED-18E460 -var parent="robedwards.altostrat.com/"
```


To create a Google Cloud Workstations cluster with multiple workstations, you can use the following command:
```
#terraform apply -var project_id=PROJECT_ID -var cluster_name=CLUSTER_NAME -var workstation_names=WORKSTATION_NAMES
```

# Troubleshooting
If you encounter any problems with the Terraform configuration file, you can refer to the following resources:

The Terraform documentation
The Google Cloud Workstations documentation
The Google Cloud provider for Terraform documentation

# Contributing
If you would like to contribute to this Terraform configuration file, please fork the repository and submit a pull request.

# License



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



-----------------------
Argolis - org policy Constraint constraints/compute.vmExternalIpAccess


