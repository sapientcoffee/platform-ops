
# us-central1-docker.pkg.dev/cloud-workstations-images/predefined/basic:latest
FROM us-central1-docker.pkg.dev/cloud-workstations-images/predefined/code-oss:latest


# Install                                                                                                            
USER root

# RUN apt-get -y update \
#     && apt-get install -y \
#         apt-transport-https \

RUN set -eux; \
    gcloud components update; \
    gcloud components install alpha; \
    \
    # Install Firebase
    curl -sL -o firebase_install.sh https://firebase.tools; \
    bash firebase_install.sh; \
    rm firebase_install.sh

# bashrc config
RUN echo 'alias tf=terraform' >> ~/.bashrc
RUN echo 'alias ll="ls -lrt"' >> ~/.bashrc

# Give back control
USER root


# VS Code Extensions from https://open-vsx.org/
ARG JAVA_DEBUG_VER=0.58.5
ARG JAVA_DEP_VER=0.27.0
ARG REDHAT_JAVA_VER=1.54.2026030508
ARG MAVEN_VER=0.45.1
ARG JAVA_TEST_VER=0.44.0
ARG DART_VER=3.131.20260304
ARG FLUTTER_VER=3.131.20260303

RUN set -eux; \
    VSIX_FILE1="vscjava.vscode-java-debug-${JAVA_DEBUG_VER}.vsix"; \
    wget "https://open-vsx.org/api/vscjava/vscode-java-debug/${JAVA_DEBUG_VER}/file/${VSIX_FILE1}" && \
    unzip "${VSIX_FILE1}" "extension/*" && \
    mv extension /opt/code-oss/extensions/java-debug && \
    rm "${VSIX_FILE1}"; \
    \
    VSIX_FILE2="vscjava.vscode-java-dependency-${JAVA_DEP_VER}.vsix"; \
    wget "https://open-vsx.org/api/vscjava/vscode-java-dependency/${JAVA_DEP_VER}/file/${VSIX_FILE2}" && \
    unzip "${VSIX_FILE2}" "extension/*" && \
    mv extension /opt/code-oss/extensions/java-dependency && \
    rm "${VSIX_FILE2}"; \
    \
    VSIX_FILE3="redhat.java-${REDHAT_JAVA_VER}.vsix"; \
    wget "https://open-vsx.org/api/redhat/java/${REDHAT_JAVA_VER}/file/${VSIX_FILE3}" && \
    unzip "${VSIX_FILE3}" "extension/*" && \
    mv extension /opt/code-oss/extensions/redhat-java && \
    rm "${VSIX_FILE3}"; \
    \
    VSIX_FILE4="vscjava.vscode-maven-${MAVEN_VER}.vsix"; \
    wget "https://open-vsx.org/api/vscjava/vscode-maven/${MAVEN_VER}/file/${VSIX_FILE4}" && \
    unzip "${VSIX_FILE4}" "extension/*" && \
    mv extension /opt/code-oss/extensions/java-maven && \
    rm "${VSIX_FILE4}"; \
    \
    VSIX_FILE5="vscjava.vscode-java-test-${JAVA_TEST_VER}.vsix"; \
    wget "https://open-vsx.org/api/vscjava/vscode-java-test/${JAVA_TEST_VER}/file/${VSIX_FILE5}" && \
    unzip "${VSIX_FILE5}" "extension/*" && \
    mv extension /opt/code-oss/extensions/java-test && \
    rm "${VSIX_FILE5}"; \
    \
    VSIX_FILE6="Dart-Code.dart-code-${DART_VER}.vsix"; \
    wget "https://open-vsx.org/api/Dart-Code/dart-code/${DART_VER}/file/${VSIX_FILE6}" && \
    unzip "${VSIX_FILE6}" "extension/*" && \
    mv extension /opt/code-oss/extensions/dart && \
    rm "${VSIX_FILE6}"; \
    \
    VSIX_FILE7="Dart-Code.flutter-${FLUTTER_VER}.vsix"; \
    wget "https://open-vsx.org/api/Dart-Code/flutter/${FLUTTER_VER}/file/${VSIX_FILE7}" && \
    unzip "${VSIX_FILE7}" "extension/*" && \
    mv extension /opt/code-oss/extensions/flutter && \
    rm "${VSIX_FILE7}"

# User scripts
# COPY settings.json /home/user/.config/Code/User/settings.json
COPY settings.sh /etc/workstation-startup.d/

RUN apt-get clean
