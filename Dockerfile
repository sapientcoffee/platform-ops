FROM gcr.io/cloudshell-images/cloudshell:latest

RUN \
	# Update
	apt-get update -y && \
	
################################
# Install Firebase
################################
	curl -sL https://firebase.tools | bash

