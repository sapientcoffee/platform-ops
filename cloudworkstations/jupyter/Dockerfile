FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/base:latest

USER root
RUN apt-get update && apt-get install -y python3-pip && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages \
    jupyterlab \
    torch \
    torchvision \
    torchaudio

# The Cloud Workstations base image ignores the Docker CMD.
# Instead, it executes scripts in /etc/workstation-startup.d/
RUN echo '#!/bin/bash\n\
# Run Jupyter as the standard user in the background on port 80\n\
runuser user -c "nohup jupyter lab --ip=0.0.0.0 --port=80 --no-browser --ServerApp.token= --ServerApp.password= --ServerApp.allow_origin=* > /tmp/jupyter.log 2>&1 &"\n\
' > /etc/workstation-startup.d/100_jupyter.sh && \
    chmod +x /etc/workstation-startup.d/100_jupyter.sh

# Switch to standard user (UID 1000) for interactive terminal sessions
USER 1000
WORKDIR /home/user
