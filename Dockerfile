FROM gitpod/workspace-full:latest
# Install                                                                                                            
USER root
RUN apt-get update 
#&& apt-get install -y terraform


# Give back control
USER root
