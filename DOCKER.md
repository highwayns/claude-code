# Docker Setup for Claude Code

This guide explains how to run Claude Code in a Docker container.

## Quick Start

### Using Docker Compose (Recommended)

1. **Set up environment variables:**

   Create a `.env` file in the project root:
   ```bash
   ANTHROPIC_API_KEY=your_api_key_here
   PROJECT_DIR=/path/to/your/project
   TZ=America/Los_Angeles
   ```

2. **Run Claude Code:**
   ```bash
   docker-compose run --rm claude-code
   ```

### Using Docker CLI

1. **Build the image:**
   ```bash
   docker build -t claude-code:latest .
   ```

2. **Run Claude Code:**
   ```bash
   docker run -it --rm \
     -v $(pwd):/workspace \
     -e ANTHROPIC_API_KEY=your_api_key_here \
     claude-code:latest
   ```

## Build Arguments

You can customize the build with the following arguments:

- `CLAUDE_CODE_VERSION`: Specify the Claude Code version (default: `latest`)
  ```bash
  docker build --build-arg CLAUDE_CODE_VERSION=1.0.0 -t claude-code:1.0.0 .
  ```

- `TZ`: Set the timezone (default: `UTC`)
  ```bash
  docker build --build-arg TZ=America/New_York -t claude-code:latest .
  ```

## Usage Examples

### Interactive Shell with Claude Code

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v claude-config:/home/claude/.claude \
  -e ANTHROPIC_API_KEY=your_api_key_here \
  claude-code:latest \
  /bin/bash
```

Then inside the container, you can run:
```bash
claude
```

### Run Claude Code Directly

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=your_api_key_here \
  claude-code:latest
```

### Execute Specific Claude Command

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANTHROPIC_API_KEY=your_api_key_here \
  claude-code:latest \
  claude --help
```

## Volume Mounts

The Docker setup uses several volumes:

1. **Project Directory (`/workspace`)**: Your code/project files
   ```bash
   -v $(pwd):/workspace
   ```

2. **Claude Configuration (`/home/claude/.claude`)**: Persists Claude settings
   ```bash
   -v claude-config:/home/claude/.claude
   ```

3. **Bash History (optional)**: Persists command history
   ```bash
   -v claude-history:/home/claude/.bash_history
   ```

## Environment Variables

Required:
- `ANTHROPIC_API_KEY`: Your Anthropic API key

Optional:
- `CLAUDE_CONFIG_DIR`: Claude configuration directory (default: `/home/claude/.claude`)
- `NODE_OPTIONS`: Node.js runtime options (default: `--max-old-space-size=4096`)
- `TZ`: Timezone (default: `UTC`)
- `EDITOR`: Default text editor (default: `nano`)

## Advanced Configuration

### Using with Docker Compose for Development

Create a `docker-compose.override.yml` for local development:

```yaml
version: '3.8'

services:
  claude-code:
    build:
      args:
        CLAUDE_CODE_VERSION: latest
    volumes:
      - ./:/workspace
      - claude-config:/home/claude/.claude
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - CLAUDE_CONFIG_DIR=/home/claude/.claude
    entrypoint: /bin/bash
    stdin_open: true
    tty: true
```

### Multi-stage Build for Smaller Images

For production deployments, you can modify the Dockerfile to use multi-stage builds:

```dockerfile
# Example: Add build stage if needed
FROM node:20-slim AS builder
# ... build steps ...

FROM node:20-slim
# ... copy from builder ...
```

## Troubleshooting

### Permission Issues

If you encounter permission issues:
```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -u $(id -u):$(id -g) \
  -e ANTHROPIC_API_KEY=your_api_key_here \
  claude-code:latest
```

### API Key Not Found

Ensure your `ANTHROPIC_API_KEY` is set:
```bash
echo $ANTHROPIC_API_KEY
```

If not set, export it:
```bash
export ANTHROPIC_API_KEY=your_api_key_here
```

### Container Exits Immediately

Add `-it` flags for interactive mode:
```bash
docker run -it --rm claude-code:latest
```

## Cleaning Up

Remove all Claude Code containers and volumes:
```bash
docker-compose down -v
docker rmi claude-code:latest
```

Remove only stopped containers:
```bash
docker container prune
```

## Security Considerations

1. **Never commit `.env` files** containing API keys
2. **Use Docker secrets** for production deployments
3. **Run as non-root user** (already configured in Dockerfile)
4. **Scan images regularly** for vulnerabilities:
   ```bash
   docker scan claude-code:latest
   ```

## Production Deployment

For production environments, consider:

1. Use specific version tags instead of `latest`
2. Implement proper secret management (e.g., Docker secrets, HashiCorp Vault)
3. Set up health checks and monitoring
4. Use read-only root filesystem where possible
5. Implement resource limits:
   ```yaml
   services:
     claude-code:
       deploy:
         resources:
           limits:
             cpus: '2'
             memory: 4G
           reservations:
             cpus: '1'
             memory: 2G
   ```

## Additional Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
