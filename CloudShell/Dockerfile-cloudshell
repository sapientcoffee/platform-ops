FROM gcr.io/cloudshell-images/cloudshell:latest

# Install                                                                                                            
USER root

RUN \
	# Update
	apt-get update -y && \
	
################################
# Install Firebase
################################
RUN curl -sL https://firebase.tools | bash

# Give back control
USER root
