#!/usr/bin/env bash
#==============================================================================
# Description:          x
# Notes:                
#                       
# Limitations/issues:
#==============================================================================

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
        -d @${SETTINGS} \
    https://workstations.googleapis.com/v1beta/projects/${PROJECT_ID}/locations/${REGION}/workstationClusters?workstation_cluster_id=${CLUSTERID}
    info "Creating or updating Workstation Cluster ..... please hold the line (might be 15-20 min)."
    
    while (curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1beta/projects/${PROJECT_ID}/locations/${REGION}/workstationClusters/${CLUSTERID} | grep -q reconciling)
    do
        info " Still building ..."
        sleep 120
    done
        success "Your cluster is ready"

}

environment(){
    info "Project: ${PROJECT_ID}";
    info "Region: ${REGION}";
    info "Settings: ${SETTINGS}";
    info "Clusterid: ${CLUSTERID}";
}

main "$@"

