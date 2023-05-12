# LEGACY METHOD THAT WAS USED DURING PREVIEW AND DEV STAGES

```
export PROJECT="coffee-break-rob"
export REGION="europe-west1"
export CLUSTER="workstations-cluster"
export WORKSTATION="custom-image"
```

```
gcloud config set compute/region ${REGION}
```

NOTE: In private preview at the moment

## Cluster Creation

```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -d @cloud-workstations-cluster.json \
"https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters?workstation_cluster_id=${CLUSTER}"

```

Takes 15 -20 min - check with 
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
"https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}"

```

```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -d @cloud-workstations-cluster.json \
 -X PATCH https://workstations.googleapis.com/v1beta/projects/coffee-break-rob/locations/europe-west2/workstationClusters/playing
```

## Platform Admin

### Default (Base Image)
#### Create
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -d @cloud-workstations-config-default.json \
"https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs?workstation_config_id=default"
```

#### Status Check
Creating the config should take a minute or less. You can check on it by running the following command:
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
"https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs/default"
```

#### Update
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -d @cloud-workstations-config-default.json \
 -X PATCH https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs?workstation_config_id=default
```

#### List
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -X GET https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs
```

#### Delete
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -X DELETE https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs/default
```

### Custom Image - VS Code

#### Create
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -d @cloud-workstations-custom-config.json \
"https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs?workstation_config_id=${WORKSTATION}"
```


#### Status Check
Creating the config should take a minute or less. You can check on it by running the following command:
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
"https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs/${WORKSTATION}"
```


#### Update
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -d @cloud-workstations-custom-config.json \
 -X PATCH https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs?workstation_config_id=${WORKSTATION}
```

#### List
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -X GET https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs
```

#### Delete
```
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
 -H "Content-Type: application/json" \
 -X DELETE https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER}/workstationConfigs/${WORKSTATION}
```


## Access

https://shell.cloud.google.com/workstations?project=$PROJECT