FROM mcr.microsoft.com/devcontainers/python:1-3.11-bullseye

LABEL org.opencontainers.image.source=https://github.com/jnoelvictorino/teaching
LABEL org.opencontainers.image.description="Dev Container for teaching Repository"
LABEL org.opencontainers.image.licenses=Apache-2.0

# Set working directory
WORKDIR /workspaces/teaching

# Set git safe.directory for root (build context)
RUN git config --global --add safe.directory "/workspaces/teaching"

# Copy and install apt packages
COPY packages.txt /tmp/packages.txt
RUN apt-get update \
  && xargs apt-get install -y < /tmp/packages.txt \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Poetry with system Python
RUN /usr/local/bin/python3.11 -m pip install poetry

# Copy only dependency files early for build cache
COPY pyproject.toml poetry.lock ./

# Configure Poetry to install packages globally (to system Python)
RUN poetry config virtualenvs.create false

# Install Python dependencies globally
RUN poetry lock && poetry install --no-root --no-interaction

# Create SSH and GPG directories for volume mounts
RUN mkdir -p /home/vscode/.ssh /home/vscode/.gnupg \
  && chmod 700 /home/vscode/.ssh /home/vscode/.gnupg \
  && chown -R vscode:vscode /home/vscode/.ssh /home/vscode/.gnupg

# Use non-root user for VS Code session
USER vscode

# Set Poetry config (for vscode user)
RUN poetry config virtualenvs.create false

# Set git safe.directory for vscode user
RUN git config --global --add safe.directory "/workspaces/teaching"
