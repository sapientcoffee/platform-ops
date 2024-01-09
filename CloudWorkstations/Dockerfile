
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
COPY CloudWorkstations/settings.json CloudWorkstations/p10k.zsh CloudWorkstations/zshrc /sapientcoffee/settings/
COPY CloudWorkstations/custom.sh /etc/workstation-startup.d/200_custom.sh
COPY CloudWorkstations/custom.sh /sapientcoffee/scripts/custom.sh
COPY CloudWorkstations/nvm.sh /etc/workstation-startup.d/201_nvm.sh
COPY CloudWorkstations/nvm.sh /sapientcoffee/scripts/nvm.sh
RUN chmod +x /etc/workstation-startup.d/200_custom.sh /sapientcoffee/scripts/custom.sh /etc/workstation-startup.d/201_nvm.sh /sapientcoffee/scripts/nvm.sh && \
	date >/sapientcoffee/scripts/version



