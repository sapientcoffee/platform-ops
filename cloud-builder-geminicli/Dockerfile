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

# Create a truly world-writable config directory outside of standard paths
RUN mkdir -p /gemini-config/.gemini && \
    touch /gemini-config/.gemini/projects.json && \
    chmod -R 777 /gemini-config

# Force gemini-cli to use this directory by setting HOME
ENV HOME=/gemini-config

# Default entrypoint is gemini
ENTRYPOINT ["gemini"]
