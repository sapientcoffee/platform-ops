
FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest
ARG TERRAFORM_VERSION=1.14.6

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
RUN curl -s -o install_kustomize.sh "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" && bash install_kustomize.sh && rm install_kustomize.sh && echo "installed kustomize"

RUN apt-get -y install nodejs

## Firebase CLI
RUN curl -sL -o firebase_install.sh https://firebase.tools && bash firebase_install.sh && rm firebase_install.sh && echo "installed firebase CLI"
# RUN npm install -D genkit-cli

RUN apt update
## zsh
RUN apt install -y zsh && echo "installed zsh"

# Install Code OSS Plugins (from open-vsx.org)
ARG TF_EXT_VERSION=2.39.0
RUN VSIX_FILE="hashicorp.terraform-${TF_EXT_VERSION}@linux-x64.vsix" && \
    wget "https://open-vsx.org/api/hashicorp/terraform/linux-x64/${TF_EXT_VERSION}/file/${VSIX_FILE}" && \
    unzip "${VSIX_FILE}" "extension/*" && \
    mv extension /opt/code-oss/extensions/terraform && \
    rm "${VSIX_FILE}"

# Customisation of terminal (zsh, themes and layout)
RUN mkdir -p /sapientcoffee/settings /sapientcoffee/scripts 

## Copy profile (zsh) settings and also powerline config to the install script locations
COPY settings.json p10k.zsh zshrc /sapientcoffee/settings/

## Copy Customisation Scripts
COPY 200_custom.sh /etc/workstation-startup.d/200_custom.sh
COPY 200_custom.sh /sapientcoffee/scripts/200_custom.sh

## Copy profile setup script
COPY setup.sh /sapientcoffee/scripts/setup.sh

## Make executable and also do a time stamp to confirm the time it was created for rudimentary versioning 
RUN chmod +x /etc/workstation-startup.d/200_custom.sh /sapientcoffee/scripts/200_custom.sh /sapientcoffee/scripts/setup.sh && \
	date >/sapientcoffee/scripts/version



