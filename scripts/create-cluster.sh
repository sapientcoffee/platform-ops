#!/usr/bin/env bash
#==============================================================================
# Title:                
# Description:          x
# Author:          		Rob Edwards (@sapientcoffee)
# Date:                 
# Version:              0.1
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
        -d @$filename \
    https://workstations.googleapis.com/v1alpha1/projects/${project}/locations/${region}/workstationClusters?workstation_cluster_id=${clusterid}
    info Your cluster is being created. This script will terminate once it is available.
    
    while (curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1alpha1/projects/${project}/locations/${region}/workstationClusters/${clusterid} | grep -q reconciling)
    do
        info " ... Still building ..."
        sleep 120
    done
        success "Your cluster is ready"

}

environment(){
    info "Project: $project";
    info "Region: $region";
    info "Filename: $filename";
    info "Clusterid: $clusterid";
}

main "$@"

