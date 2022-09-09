#!/usr/bin/env bash
#==============================================================================
# Description:          x
# Notes:                
#                       
# Limitations/issues:
#==============================================================================

# use set -e instead of #!/bin/bash -e in case we're
# called with `bash ~/bin/scriptname`
set -e # bail out early if any command fails
set -u # fail if we hit unset variables
set -o pipefail # fail if any component of any pipe fails


# Set some output colours for feedback during setup
info () {
    printf " [ \033[00;34m..\033[0m ] $1\n"
}

user () {
    printf "\r [ \033[0;33m?\033[0m ] $1 "
}

success () {
    printf "\r\033[2K [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
    printf "\r\033[2K [\033[0;31mFAIL\033[0m] $1 \n"
    echo ''
    exit
}

main() {

    info "The following are the environment settings ..."
    environment

    curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -d @${FILENAME} \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT_ID}/locations/${REGION}/workstationClusters?workstation_cluster_id=${CLUSTERID}
    info Your cluster is being created. This script will terminate once it is available.
    
    while (curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT_ID}/locations/${REGION}/workstationClusters/${CLUSTERID} | grep -q reconciling)
    do
        info " Still building ..."
        sleep 120
    done
        success "Your cluster is ready"

}

environment(){
    printenv
    info "Project: ${PROJECT_ID}";
    info "Region: ${REGION}";
    info "Filename: ${FILENAME}";
    info "Clusterid: ${CLUSTERID}";
}

main "$@"

