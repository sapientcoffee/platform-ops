
FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest
ARG TERRAFORM_VERSION=1.6.3

# Install tooling
## terraform
RUN wget --progress=dot:mega https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN \
	# Unzip
	unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
	# Move to local bin
	mv terraform /usr/local/bin/ && \
	# Make it executable
	chmod +x /usr/local/bin/terraform && \
	# Check that it's installed
	terraform --version && \
	echo "installed terraform"

## Kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && echo "installed kustomize"


## Firebase CLI
RUN curl -sL https://firebase.tools | bash && echo "installed firebase CLI"

## gcloud addons
RUN sudo apt-get install google-cloud-sdk-terraform-tools && echo "installed gcloud terrafrom tools" 
RUN sudo apt-get install google-cloud-sdk-config-connector && echo "installed gcloud config-connector"

## zsh
RUN apt install -y zsh && echo "installed zsh"

# Install Code OSS Plugins (from open-vsx.org)
RUN wget https://open-vsx.org/api/hashicorp/terraform/linux-x64/2.28.2/file/hashicorp.terraform-2.28.2@linux-x64.vsix  && \
unzip hashicorp.terraform-2.28.2@linux-x64.vsix "extension/*" &&\
mv extension /opt/code-oss/extensions/terraform

# Customisation of terminal (zsh, themes and layout)
RUN mkdir -p /sapientcoffee/settings /sapientcoffee/scripts 

## Copy profile (zsh) settings and also powerline config to the install script locations
COPY CloudWorkstations/settings.json CloudWorkstations/p10k.zsh CloudWorkstations/zshrc /sapientcoffee/settings/

## Copy Customisation Scripts
COPY CloudWorkstations/200_custom.sh /etc/workstation-startup.d/200_custom.sh
COPY CloudWorkstations/200_custom.sh /sapientcoffee/scripts/200_custom.sh

## Copy profile setup script
COPY CloudWorkstations/setup.sh /sapientcoffee/scripts/setup.sh

## Make executable and also do a time stamp to confirm the time it was created for rudimentary versioning 
RUN chmod +x /etc/workstation-startup.d/200_custom.sh /sapientcoffee/scripts/200_custom.sh /sapientcoffee/scripts/setup.sh && \
	date >/sapientcoffee/scripts/version



