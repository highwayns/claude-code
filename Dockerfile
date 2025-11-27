# Production Dockerfile for Claude Code
FROM node:20-slim

# Set timezone (can be overridden at build time)
ARG TZ=UTC
ENV TZ="$TZ"

# Set Claude Code version (defaults to latest)
ARG CLAUDE_CODE_VERSION=latest

# Install essential system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    less \
    ca-certificates \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for running Claude Code
RUN useradd -m -s /bin/bash claude && \
    mkdir -p /workspace /home/claude/.claude && \
    chown -R claude:claude /workspace /home/claude/.claude

# Set up npm global directory
ENV NPM_CONFIG_PREFIX=/home/claude/.npm-global
ENV PATH=$PATH:/home/claude/.npm-global/bin

# Switch to non-root user
USER claude
WORKDIR /workspace

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Set default editor
ENV EDITOR=nano
ENV VISUAL=nano

# Set Claude config directory
ENV CLAUDE_CONFIG_DIR=/home/claude/.claude

# Health check to verify Claude Code is installed
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD which claude || exit 1

# Default command to run Claude Code
ENTRYPOINT ["claude"]
CMD ["--help"]
