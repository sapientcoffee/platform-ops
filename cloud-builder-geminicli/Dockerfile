# Use the Google Cloud SDK base image
FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:latest

# Install Node.js (needed for gemini-cli)
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install @google/gemini-cli globally
RUN npm install -g @google/gemini-cli@preview

# Create a symlink for 'geminicli' as well, since it's a common alias/expectation
RUN ln -s /usr/local/bin/gemini /usr/local/bin/geminicli

# Default entrypoint is gemini
ENTRYPOINT ["gemini"]
