# Cloud Builder: geminicli-builder

This is a custom Google Cloud Build builder image that contains the `gemini` CLI tool. It is based on the official `google-cloud-cli` image, adding Node.js and the `@google/gemini-cli` package.

## Features

- **Base Image:** `gcr.io/google.com/cloudsdktool/google-cloud-cli:latest`
- **Tools:**
  - `gcloud` (latest)
  - `node` (v20.x)
  - `npm` (latest)
  - `gemini` (preview)
  - `geminicli` (alias for `gemini`)

## Building the Image

To build and push this image to your project's Artifact Registry:

```bash
gcloud builds submit --config cloudbuild.yaml .
```

The image will be tagged as:
`europe-docker.pkg.dev/$PROJECT_ID/codey-builder-image/geminicli-builder:latest`

## Using it in Cloud Build

You can use this builder in your other Cloud Build jobs by referencing its image name.

### Example: Running a prompt

```yaml
steps:
- name: 'europe-docker.pkg.dev/$PROJECT_ID/codey-builder-image/geminicli-builder'
  args: ['Explain why I should use Gemini CLI for platform operations.']
```

### Example: Using yolo mode for automated tasks

```yaml
steps:
- name: 'europe-docker.pkg.dev/$PROJECT_ID/codey-builder-image/geminicli-builder'
  args: ['-y', 'Update the license header in all src/*.py files to Apache 2.0.']
```

### Authentication

The builder will use the Cloud Build service account's credentials. Ensure that the service account has the necessary permissions (e.g., Vertex AI User) to use Gemini.
