
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
RUN curl -sL -o firebase_install.sh https://firebase.tools && bash firebase_install.sh && rm firebase_install.sh

# bashrc config
RUN echo 'alias tf=terraform' >> ~/.bashrc
RUN echo 'alias ll="ls -lrt"' >> ~/.bashrc

# Give back control
USER root


# VS Code Extensions from https://open-vsx.org/
ARG JAVA_DEBUG_VER=0.58.5
RUN VSIX_FILE="vscjava.vscode-java-debug-${JAVA_DEBUG_VER}.vsix" && \
    wget "https://open-vsx.org/api/vscjava/vscode-java-debug/${JAVA_DEBUG_VER}/file/${VSIX_FILE}" && \
    unzip "${VSIX_FILE}" "extension/*" && \
    mv extension /opt/code-oss/extensions/java-debug && \
    rm "${VSIX_FILE}"
 
ARG JAVA_DEP_VER=0.27.0
RUN VSIX_FILE="vscjava.vscode-java-dependency-${JAVA_DEP_VER}.vsix" && \
    wget "https://open-vsx.org/api/vscjava/vscode-java-dependency/${JAVA_DEP_VER}/file/${VSIX_FILE}" && \
    unzip "${VSIX_FILE}" "extension/*" && \
    mv extension /opt/code-oss/extensions/java-dependency && \
    rm "${VSIX_FILE}"
 
ARG REDHAT_JAVA_VER=1.54.2026030508
RUN VSIX_FILE="redhat.java-${REDHAT_JAVA_VER}.vsix" && \
    wget "https://open-vsx.org/api/redhat/java/${REDHAT_JAVA_VER}/file/${VSIX_FILE}" && \
    unzip "${VSIX_FILE}" "extension/*" && \
    mv extension /opt/code-oss/extensions/redhat-java && \
    rm "${VSIX_FILE}"
 
ARG MAVEN_VER=0.45.1
RUN VSIX_FILE="vscjava.vscode-maven-${MAVEN_VER}.vsix" && \
    wget "https://open-vsx.org/api/vscjava/vscode-maven/${MAVEN_VER}/file/${VSIX_FILE}" && \
    unzip "${VSIX_FILE}" "extension/*" && \
    mv extension /opt/code-oss/extensions/java-maven && \
    rm "${VSIX_FILE}"
 
ARG JAVA_TEST_VER=0.44.0
RUN VSIX_FILE="vscjava.vscode-java-test-${JAVA_TEST_VER}.vsix" && \
    wget "https://open-vsx.org/api/vscjava/vscode-java-test/${JAVA_TEST_VER}/file/${VSIX_FILE}" && \
    unzip "${VSIX_FILE}" "extension/*" && \
    mv extension /opt/code-oss/extensions/java-test && \
    rm "${VSIX_FILE}"

ARG DART_VER=3.131.20260304
RUN VSIX_FILE="Dart-Code.dart-code-${DART_VER}.vsix" && \
    wget "https://open-vsx.org/api/Dart-Code/dart-code/${DART_VER}/file/${VSIX_FILE}" && \
    unzip "${VSIX_FILE}" "extension/*" && \
    mv extension /opt/code-oss/extensions/dart && \
    rm "${VSIX_FILE}"

ARG FLUTTER_VER=3.131.20260303
RUN VSIX_FILE="Dart-Code.flutter-${FLUTTER_VER}.vsix" && \
    wget "https://open-vsx.org/api/Dart-Code/flutter/${FLUTTER_VER}/file/${VSIX_FILE}" && \
    unzip "${VSIX_FILE}" "extension/*" && \
    mv extension /opt/code-oss/extensions/flutter && \
    rm "${VSIX_FILE}"

# User scripts
# COPY settings.json /home/user/.config/Code/User/settings.json
COPY settings.sh /etc/workstation-startup.d/

RUN apt-get clean
