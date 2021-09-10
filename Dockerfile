FROM gitpod/workspace-full:latest

ARG TERRAFORM_VERSION=1.0.5
ARG TERRAGRUNT_VERSION=0.31.10

# Install                                                                                                            
USER root

RUN \
	# Update
	apt-get update -y && \
	# Install dependencies
	apt-get install unzip wget -y

################################
# Install Terraform
################################

# Download terraform for linux
RUN wget --progress=dot:mega https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN \
	# Unzip
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	# Move to local bin
	mv terraform /usr/local/bin/ && \
	# Make it executable
	chmod +x /usr/local/bin/terraform && \
	# Check that it's installed
	terraform --version

################################
# Install Terragrunt
################################

# Download terraform for linux
RUN wget --progress=dot:mega https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64

RUN \
	# Move to local bin
	mv terragrunt_linux_amd64 /usr/local/bin/terragrunt && \
	# Make it executable
	chmod +x /usr/local/bin/terragrunt && \
	# Check that it's installed
	terragrunt --version

# Give back control
USER root
