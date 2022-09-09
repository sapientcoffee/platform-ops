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

    if checkCluster true; then
        success "Cluster already exists"
        updateCluster
    elif checkCluster false
        info "Cluster does not exist"
        createCluster
    else
        fail "Something went wrong!"
    fi

}

checkCluster() {
    # Check to see if cluster already exists 
    curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1beta/projects/${PROJECT_ID}/locations/${REGION}/workstationClusters/ | grep -q ${CLUSTERID}

    return $?
}

createCluster() {
    # create the workstation cluster
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
    return
}

updateCluster() {
    # Update the workstation cluster
    curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
        -d @${SETTINGS} \
        -X PATCH https://workstations.googleapis.com//v1beta/projects/${PROJECT_ID}/locations/${REGION}/workstationClusters/${CLUSTERID}/workstationConfigs/${SETTINGS}
    info "Updating cluster"

    while (curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1beta/projects/${PROJECT_ID}/locations/${REGION}/workstationClusters/${CLUSTERID} | grep -q reconciling)
    do
        info " Still updating ..."
        sleep 15
    done
        success "Your cluster is ready"

    return


}

environment(){
    info "Project: ${PROJECT_ID}";
    info "Region: ${REGION}";
    info "Settings: ${SETTINGS}";
    info "Clusterid: ${CLUSTERID}";
}

main "$@"

