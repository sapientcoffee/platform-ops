# Cloud Developer Workstations (Platform Team Focus)
As we move more and more to remote development environments we need to have images to drive optimal experiance. This is a collection of image build to support remote development in environments like;
* Google Cloud Workstations
* Google Cloud Shell
* GitPod
* etc.

Some are a bit dated now and more focus has been put into Google Cloud Workstations now that it has been moved to be generally available (GA).

The following is a high-level overview of remote development in GCP using Cloud Shell and Cloud IDE;
![](Remote-Developer-Environment.jpg)


## Google Cloud Workstaions
A number of now legacy configurations exist in this repo that need to be tidied up, the latest configuration and examples for demos are stored in [Cloud Workstations](/cloud%20workstations/).










# Legacy 
```
export CUSTOM_ENV_REPO_ID="europe-west2-docker.pkg.dev/coffee-with-rob/espresso-gcp"
export CUSTOM_ENV_PROJECT_ID="coffee-with-rob"
```

```
cloudshell env build-local
cloudshell env run
```


```
gcloud builds submit --tag \
    <image>:<tag1>
```

Creating a trigger for Github


```
gcloud beta builds triggers create github \
    --repo-name=REPO_NAME \
    --repo-owner=REPO_OWNER \
    --branch-pattern=BRANCH_PATTERN \ # or --tag-pattern=TAG_PATTERN
    --build-config=BUILD_CONFIG_FILE \
    --service-account=SERVICE_ACCOUNT \
    --require-approval

```


TODO
* Cloud Build with TF
* Investigate Cloud Build with KCC
* Trigger based on base conatiner image
* Trigger on apt/debendency changes
* Tutorial Page for this and it to autolaunch with click
* Have two OICS 1) Edit 2) Learn