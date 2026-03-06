# Cloud Builder: gemini-builder

This is a custom Google Cloud Build builder image that contains the `gemini` CLI tool. It is based on the official `google-cloud-cli` image, adding Node.js and the `@google/gemini-cli` package.

## Features

- **Base Image:** `gcr.io/google.com/cloudsdktool/google-cloud-cli:559.0.0-debian_component_based`
- **Tools:**
  - `gcloud` (559.0.0)
  - `node` (v20.x)
  - `npm` (latest)
  - `gemini` (preview)

## Building the Image

To build and push this image to your project's Artifact Registry:

```bash
gcloud builds submit --config cloudbuild.yaml .
```

The image will be tagged as:
`us-docker.pkg.dev/coffee-plantation/cloud-build-builder/gemini-builder:latest`

## Using it in Cloud Build

You can use this builder in your other Cloud Build jobs by referencing its image name.

### Example: Running a prompt

```yaml
steps:
- name: 'us-docker.pkg.dev/coffee-plantation/cloud-build-builder/gemini-builder'
  args: ['Explain why I should use Gemini CLI for platform operations.']
```

### Example: Using yolo mode for automated tasks

```yaml
steps:
- name: 'us-docker.pkg.dev/coffee-plantation/cloud-build-builder/gemini-builder'
  args: ['-y', 'Update the license header in all src/*.py files to Apache 2.0.']
```

### Authentication

The builder will use the Cloud Build service account's credentials. To use the tool in a non-interactive environment like Cloud Build, you should specify the authentication backend using environment variables:

- `GOOGLE_GENAI_USE_VERTEXAI=true`: Recommended for most Cloud Build jobs. Ensure the Cloud Build service account (e.g., `PROJECT_NUMBER@cloudbuild.gserviceaccount.com`) has the **Vertex AI User** role (`roles/aiplatform.user`) in the target project.
- `GOOGLE_GENAI_USE_GCA=true`: Uses Gemini Cloud Assist backend.

### Required Environment Variables

When using Vertex AI, you must provide the project and location:
- `GOOGLE_CLOUD_PROJECT`: The project ID where Vertex AI API is enabled.
- `GOOGLE_CLOUD_LOCATION`: The region (e.g., `us-central1`).
- `GEMINI_MODEL`: (Optional) The model to use (e.g., `gemini-3.1-pro-preview`). Defaults to the CLI's internal default if not set.

## Troubleshooting

### ModelNotFoundError

If you see `ModelNotFoundError`, it means the specific model name is either incorrect for the chosen region or your project doesn't have access to it.

1.  **Verify Model Name:** Check the [Vertex AI Model Garden](https://console.cloud.google.com/vertex-ai/model-garden) in the Google Cloud Console to find the exact model ID available in your region.
2.  **Enable Model:** Some preview models (like `gemini-3.1-pro-preview`) may require you to "Enable" or "Agree to terms" in the Model Garden before they can be used via API.
3.  **Check Region:** Ensure the `GOOGLE_CLOUD_LOCATION` matches a region where the model is deployed.

Example test with a model ID found in the console:

```bash
gcloud builds submit --project=coffee-plantation --config=<(echo '
steps:
- name: "us-docker.pkg.dev/coffee-plantation/cloud-build-builder/gemini-builder:latest"
  env: [
    "GOOGLE_GENAI_USE_VERTEXAI=true",
    "GOOGLE_CLOUD_PROJECT=coffee-plantation",
    "GOOGLE_CLOUD_LOCATION=us-central1"
  ]
  args: ["-m", "gemini-1.5-flash-001", "Explain Cloud Build in one sentence."]
')
```
