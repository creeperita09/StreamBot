# Use Debian (trixie) as the base image
FROM node:trixie

# Set the working directory
WORKDIR /home/bots/StreamBot

# Install minimal dependencies
RUN apt-get update && apt-get install -y curl ca-certificates unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install bun and add to PATH
ENV BUN_INSTALL="/usr/local/"
RUN curl -fsSL https://bun.sh/install | bash

# Install remaining dependencies and clean cache
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install the deno js runtime (for yt-dlp), pinned to a specific version for
# reproducible builds, and put it on PATH like BUN_INSTALL above.
ENV DENO_INSTALL="/usr/local/"
ARG DENO_VERSION="v2.9.0"
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y "${DENO_VERSION}"

# Copy package.json
COPY package.json ./

# Install dependencies
RUN bun install

# Trust all packages
RUN bun pm trust --all

# Copy the rest of the application code
COPY . .

# Verify the application builds
RUN bun run build

# Specify the port number the container should expose
EXPOSE 3000

# Create videos folder
RUN mkdir -p ./videos

# Command to run the application
CMD ["bun", "run", "start"]
