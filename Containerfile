FROM docker.io/node:lts-slim

# Install Bun
COPY --from=docker.io/oven/bun:slim /usr/local/bin/bun /usr/local/bin/
RUN bun --version

# Test bun install (this should fail on GitHub Actions ubuntu-24.04 without --network=host)
WORKDIR /app
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile
