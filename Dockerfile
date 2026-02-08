# =============================================================================
# Dockerfile for the dockerTest project
#
# This file contains the instructions Docker uses to build an image for the
# application. Each instruction is executed in order during the build process.
# The result is a self-contained image that can be run as a container on any
# machine with Docker installed.
# =============================================================================

# ---------------------------------------------------------------------------
# FROM -- Select the base image
#
# Every Dockerfile must start with a FROM instruction. It defines the starting
# point for the image -- a pre-existing image that already has certain tools
# installed.
#
# "node:24.13.0-trixie-slim" means:
#   - node        : The official Node.js image from Docker Hub.
#   - 24.13.0     : The specific Node.js version.
#   - trixie      : Based on Debian 13 (Trixie) Linux distribution.
#   - slim        : A smaller variant of Debian with unnecessary packages
#                   removed to reduce image size.
# ---------------------------------------------------------------------------
FROM node:24.13.0-trixie-slim

# ---------------------------------------------------------------------------
# WORKDIR -- Set the working directory inside the image
#
# All commands that follow (COPY, RUN, CMD) will execute relative to this
# directory. If the directory does not exist, Docker creates it automatically.
#
# This is equivalent to running "cd /app" inside the image. Without this,
# files would be placed in the root directory (/), which is messy and
# considered bad practice.
# ---------------------------------------------------------------------------
WORKDIR /app

# ---------------------------------------------------------------------------
# COPY -- Copy files from the host machine into the image
#
# Syntax: COPY <source> <destination>
#   - <source>      : Path on the host machine (relative to the build context,
#                     which is the directory where the docker build command
#                     is run).
#   - <destination> : Path inside the image (relative to WORKDIR if not
#                     absolute).
#
# "COPY . ." means:
#   - First dot  : Copy everything from the current directory on the host.
#   - Second dot : Place it in the current working directory inside the image
#                  (which is /app, as set by WORKDIR above).
#
# Files listed in .dockerignore are automatically excluded from the copy.
# This prevents unnecessary files (node_modules, dist, .git, etc.) from
# being included in the image.
# ---------------------------------------------------------------------------
COPY . .

# ---------------------------------------------------------------------------
# RUN -- Execute a command during the image build process
#
# RUN commands are executed at build time, not when the container starts.
# Each RUN instruction creates a new layer in the image.
#
# "npm install" reads package.json and package-lock.json, then downloads
# and installs all dependencies (in this case, TypeScript) into the
# node_modules directory inside the image.
# ---------------------------------------------------------------------------
RUN npm install

# ---------------------------------------------------------------------------
# RUN -- Compile TypeScript to JavaScript
#
# "npm run build" executes the "build" script defined in package.json,
# which runs "npx tsc". This compiles app.ts into JavaScript and places
# the output in the dist/ directory (as configured in tsconfig.json).
#
# This step must come after "npm install" because the TypeScript compiler
# is installed as a dependency. Without it, the build would fail.
# ---------------------------------------------------------------------------
RUN npm run build

# ---------------------------------------------------------------------------
# CMD -- Define the default command to run when a container starts
#
# Unlike RUN (which executes at build time), CMD executes at runtime --
# when a container is created from this image.
#
# "npm run executeApp" runs the "executeApp" script from package.json,
# which executes "node ./dist/app.js" -- the compiled JavaScript file.
#
# The command is written in "exec form" (JSON array) rather than "shell form"
# (plain string). Exec form is preferred because:
#   - It runs the command directly without wrapping it in a shell.
#   - It ensures signals (like stop/terminate) are passed correctly
#     to the application process.
#
# There can only be one CMD instruction per Dockerfile. If multiple CMD
# instructions are present, only the last one takes effect.
# ---------------------------------------------------------------------------
CMD [ "npm", "run", "executeApp" ]