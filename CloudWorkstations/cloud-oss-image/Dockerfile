
# us-central1-docker.pkg.dev/cloud-workstations-images/predefined/basic:latest
FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest


# Install                                                                                                            
USER root

# RUN apt-get -y update \
#     && apt-get install -y \
#         apt-transport-https \

RUN gcloud components update \
     && gcloud components install alpha



################################
# Install Firebase
################################
RUN curl -sL https://firebase.tools | bash

# bashrc config
RUN echo 'alias tf=terraform' >> ~/.bashrc
RUN echo 'alias ll="ls -lrt"' >> ~/.bashrc

# Give back control
USER root


# VS Code Extensions from https://open-vsx.org/
RUN wget https://open-vsx.org/api/vscjava/vscode-java-debug/0.40.1/file/vscjava.vscode-java-debug-0.40.1.vsix && \
unzip vscjava.vscode-java-debug-0.40.1.vsix "extension/*" &&\
mv extension /opt/code-oss/extensions/java-debug
 
RUN wget https://open-vsx.org/api/vscjava/vscode-java-dependency/0.19.1/file/vscjava.vscode-java-dependency-0.19.1.vsix && \
unzip vscjava.vscode-java-dependency-0.19.1.vsix "extension/*" &&\
mv extension /opt/code-oss/extensions/java-dependency
 
RUN wget https://open-vsx.org/api/redhat/java/1.6.0/file/redhat.java-1.6.0.vsix && \
unzip redhat.java-1.6.0.vsix "extension/*" &&\
mv extension /opt/code-oss/extensions/redhat-java
 
RUN wget https://open-vsx.org/api/vscjava/vscode-maven/0.35.2/file/vscjava.vscode-maven-0.35.2.vsix && \
unzip vscjava.vscode-maven-0.35.2.vsix "extension/*" &&\
mv extension /opt/code-oss/extensions/java-maven
 
RUN wget https://open-vsx.org/api/vscjava/vscode-java-test/0.35.0/file/vscjava.vscode-java-test-0.35.0.vsix && \
unzip vscjava.vscode-java-test-0.35.0.vsix "extension/*" &&\
mv extension /opt/code-oss/extensions/java-test

RUN wget https://open-vsx.org/api/Dart-Code/dart-code/3.46.0/file/Dart-Code.dart-code-3.46.0.vsix && \
unzip vscjava.vscode-java-test-0.35.0.vsix "extension/*" &&\
mv extension /opt/code-oss/extensions/dart

RUN wget https://open-vsx.org/api/Dart-Code/flutter/3.46.0/file/Dart-Code.flutter-3.46.0.vsix && \
unzip vscjava.vscode-java-test-0.35.0.vsix "extension/*" &&\
mv extension /opt/code-oss/extensions/flutter

# User scripts
# COPY settings.json /home/user/.config/Code/User/settings.json
COPY settings.sh /etc/workstation-startup.d/

RUN apt-get clean
