# Use a pinned version of the Google Cloud SDK base image
FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:559.0.0-debian_component_based

# Install Node.js (needed for gemini-cli)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install @google/gemini-cli globally
RUN npm install -g @google/gemini-cli@preview

# Pre-create the .gemini directory with open permissions to avoid ENOENT errors in non-root environments
RUN mkdir -p /builder/home/.gemini && chmod -R 777 /builder/home

# Set HOME to /builder/home so gemini-cli uses it for configuration
ENV HOME=/builder/home

# Default entrypoint is gemini
ENTRYPOINT ["gemini"]
