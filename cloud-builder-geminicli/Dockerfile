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

# Use a custom home directory to avoid conflicts with Cloud Build's managed /builder/home volume
RUN mkdir -p /gemini-home && chmod 777 /gemini-home
ENV HOME=/gemini-home

# Default entrypoint is gemini
ENTRYPOINT ["gemini"]
