# Dockerfile Instructions Reference

A Dockerfile is a plain text file that contains a sequence of instructions. Docker
reads these instructions from top to bottom and executes each one in order to build
an image. Every instruction performs a specific task -- selecting a base, copying
files, running commands, or defining runtime behavior.

This document provides a detailed reference for the most commonly used Dockerfile
instructions. Each instruction includes its purpose, syntax, detailed explanation,
practical examples, and important notes.

---

## FROM

### Purpose

Selects the **base image** that the new image will be built on top of. Every
Dockerfile must begin with a FROM instruction. The base image provides the
foundation -- typically a minimal operating system and, in many cases, a
pre-installed runtime (such as Node.js, Python, or Java).

### Syntax

```dockerfile
FROM <image_name>
FROM <image_name>:<tag>
```

- `<image_name>` -- The name of the image to use as the base.
- `<tag>` -- An optional version identifier. If omitted, Docker defaults to
  the `latest` tag.

### How It Works

When Docker encounters the FROM instruction, it checks the local machine for the
specified image. If the image is not found locally, Docker downloads it from a
registry (Docker Hub by default). All subsequent instructions in the Dockerfile
build on top of this base image.

### Examples

**Using the default (latest) tag:**

```dockerfile
FROM node
```

This pulls the latest full Node.js image. It includes a complete Debian Linux
system and is typically around 1 GB in size. It works but is larger than necessary
for most applications.

**Specifying an exact version and variant:**

```dockerfile
FROM node:24.13.0-trixie-slim
```

This pulls a very specific image:
- `node` -- The official Node.js image.
- `24.13.0` -- Node.js version 24.13.0 specifically.
- `trixie` -- Based on Debian 13 (Trixie).
- `slim` -- A reduced-size variant with unnecessary packages removed.

**Using a minimal Alpine-based image:**

```dockerfile
FROM node:20-alpine
```

Alpine Linux is an extremely small distribution (around 5 MB base). The resulting
Node.js image is roughly 50 MB compared to 1 GB for the full Debian variant.

**Using a non-Node.js base:**

```dockerfile
FROM python:3.12-slim
```

Base images exist for nearly every major runtime and language.

### Common Image Variants

| Variant      | Description                                              | Size     |
|--------------|----------------------------------------------------------|----------|
| node         | Full Debian-based image with many pre-installed tools    | ~1 GB    |
| node:slim    | Debian-based but with unnecessary packages removed       | ~200 MB  |
| node:alpine  | Based on Alpine Linux, extremely minimal                 | ~50 MB   |

### Important Notes

- Every Dockerfile must start with FROM. There is no exception.
- Specifying an exact version tag (e.g., `24.13.0`) is strongly recommended for
  production use. Using `latest` means the base image could change between builds,
  which may introduce unexpected behavior.
- Smaller base images result in smaller final images, which are faster to transfer,
  faster to deploy, and use less disk space.

---

## WORKDIR

### Purpose

Sets the **working directory** inside the image for all subsequent instructions.
Any COPY, RUN, CMD, or other instructions that follow will execute relative to this
directory. If the directory does not exist, Docker creates it automatically.

### Syntax

```dockerfile
WORKDIR <path>
```

- `<path>` -- An absolute path inside the image where work should take place.

### How It Works

WORKDIR is equivalent to running `cd <path>` inside the image. Once set, every
instruction that follows operates from that directory. This keeps the image
organized by placing application files in a dedicated location rather than
scattering them in the root directory.

### Examples

**Setting a standard application directory:**

```dockerfile
WORKDIR /app
```

All subsequent commands will operate inside `/app`. If `/app` does not exist,
Docker creates it.

**Setting a nested directory:**

```dockerfile
WORKDIR /home/user/application
```

Docker creates the entire directory path if any part of it does not exist.

**Multiple WORKDIR instructions:**

```dockerfile
WORKDIR /app
COPY . .
WORKDIR /app/config
RUN cat settings.json
```

The first WORKDIR sets the directory to `/app`. The second changes it to
`/app/config`. The RUN command executes from `/app/config`.

### What Happens Without WORKDIR

If WORKDIR is not specified, the working directory defaults to `/` (the root of
the file system). This means files would be copied directly into the root
directory, which is disorganized and can conflict with system files. Always
setting a WORKDIR is considered good practice.

### Important Notes

- WORKDIR should be set before any COPY or RUN instructions that depend on
  file locations.
- The directory is created automatically if it does not exist. There is no need
  to run `mkdir` beforehand.
- Using an absolute path (starting with `/`) is recommended to avoid ambiguity.

---

## COPY

### Purpose

Copies files and directories **from the host machine into the image**. This is
how application source code, configuration files, and other assets get placed
inside the image during the build process.

### Syntax

```dockerfile
COPY <source> <destination>
```

- `<source>` -- A path relative to the **build context** (the directory from which
  `docker build` is run). This refers to files on the host machine.
- `<destination>` -- A path inside the image. If a WORKDIR has been set, relative
  paths are resolved from the WORKDIR.

### How It Works

When Docker encounters a COPY instruction, it takes the specified files from the
host machine and places them inside the image at the specified location. The files
become a permanent part of the image.

Files listed in the `.dockerignore` file are automatically excluded from the copy
operation, even if the source pattern would otherwise include them.

### Examples

**Copy everything into the working directory:**

```dockerfile
WORKDIR /app
COPY . .
```

The first `.` means "everything in the build context on the host machine."
The second `.` means "the current working directory inside the image" (which is
`/app` because of WORKDIR). So this copies all project files into `/app`.

**Copy everything into an explicit directory:**

```dockerfile
COPY . /app/
```

This achieves the same result as the example above but uses an absolute path
instead of relying on WORKDIR.

**Copy a specific file:**

```dockerfile
COPY package.json /app/package.json
```

Copies only `package.json` from the host into `/app/` inside the image.

**Copy multiple specific files:**

```dockerfile
COPY package.json package-lock.json /app/
```

Copies both `package.json` and `package-lock.json` into `/app/`.

**Copy a directory:**

```dockerfile
COPY src/ /app/src/
```

Copies the entire `src` directory and its contents into `/app/src/` inside
the image.

### Important Notes

- COPY only works with files inside the build context. It cannot access files
  outside the directory where `docker build` is run.
- Use `.dockerignore` to prevent unnecessary files (such as `node_modules`,
  `.git`, build outputs) from being copied into the image.
- Each COPY instruction creates a new layer in the image. Docker caches layers,
  so if the copied files have not changed, Docker reuses the cached layer on
  subsequent builds (making the build faster).

---

## RUN

### Purpose

Executes a **command during the image build process**. RUN is used to install
software, compile code, create directories, download files, or perform any other
action needed to prepare the image. The results of the command become a permanent
part of the image.

### Syntax

**Shell form (command is passed to a shell):**

```dockerfile
RUN <command>
```

**Exec form (command is executed directly):**

```dockerfile
RUN ["executable", "argument1", "argument2"]
```

Shell form is more common for RUN because it supports shell features like
variable expansion, piping, and chaining commands.

### How It Works

When Docker encounters a RUN instruction during the build, it executes the
specified command inside a temporary container created from the current state
of the image. The changes made by that command (installed packages, compiled
files, created directories) are saved as a new layer in the image.

RUN is a **build-time** instruction. It executes when the image is being built,
not when a container is started from the image.

### Examples

**Install dependencies:**

```dockerfile
RUN npm install
```

Runs `npm install` inside the image during the build. This reads `package.json`
and `package-lock.json` and installs all listed dependencies into `node_modules`.

**Compile TypeScript:**

```dockerfile
RUN npm run build
```

Runs the `build` script defined in `package.json`. In this project, that script
runs `npx tsc`, which compiles TypeScript files into JavaScript.

**Install a system package (Debian-based images):**

```dockerfile
RUN apt-get update && apt-get install -y curl
```

Updates the package list and installs curl. The `&&` chains two commands together
so they run in sequence within the same layer.

**Create a directory:**

```dockerfile
RUN mkdir -p /app/logs
```

Creates a `logs` directory inside `/app`. The `-p` flag ensures parent directories
are created if they do not exist.

### RUN vs CMD

This is an important distinction:

| Instruction | When It Executes | Purpose                              |
|-------------|------------------|--------------------------------------|
| RUN         | Build time       | Prepare the image (install, compile) |
| CMD         | Runtime          | Start the application                |

RUN is for setting up the image. CMD is for running the application inside a
container. They serve completely different purposes.

### Important Notes

- Each RUN instruction creates a new **layer** in the image. More layers mean
  a larger image. Where possible, combine related commands into a single RUN
  instruction using `&&` to reduce the number of layers.
- RUN commands execute in the directory set by WORKDIR.
- If a RUN command fails (returns a non-zero exit code), the entire build stops
  with an error.

---

## CMD

### Purpose

Defines the **default command** that runs when a container is created from the
image. This is the application's startup instruction -- the thing that actually
executes when someone runs `docker run`.

### Syntax

**Exec form (recommended):**

```dockerfile
CMD ["executable", "argument1", "argument2"]
```

**Shell form:**

```dockerfile
CMD command argument1 argument2
```

### How It Works

CMD does not execute during the build process. It is stored as metadata in the
image. When a container is created from the image using `docker run`, Docker
reads the CMD instruction and executes it inside the container.

If the user provides a command when running the container (e.g.,
`docker run myimage /bin/bash`), the user's command overrides the CMD. This
makes CMD a default that can be replaced at runtime.

### Examples

**Running a Node.js application:**

```dockerfile
CMD ["node", "dist/app.js"]
```

When a container starts, it executes `node dist/app.js`, which runs the compiled
JavaScript file.

**Running through an npm script:**

```dockerfile
CMD ["npm", "run", "executeApp"]
```

When a container starts, it executes `npm run executeApp`, which in turn runs
`node ./dist/app.js` as defined in `package.json`.

**Running a Python application:**

```dockerfile
CMD ["python", "app.py"]
```

**Shell form example:**

```dockerfile
CMD npm run executeApp
```

This works but is less preferred. Shell form wraps the command in `/bin/sh -c`,
which means signals (like container stop requests) go to the shell process
rather than directly to the application. Exec form avoids this issue.

### Exec Form vs Shell Form

| Form       | Syntax                                | Signal Handling       |
|------------|---------------------------------------|-----------------------|
| Exec form  | CMD ["npm", "run", "executeApp"]      | Signals go directly   |
|            |                                       | to the process        |
| Shell form | CMD npm run executeApp                | Signals go to the     |
|            |                                       | shell, not the app    |

Exec form is recommended because it ensures the application receives system
signals properly (such as termination requests when stopping a container).

### Important Notes

- There can only be **one CMD instruction** per Dockerfile. If multiple CMD
  instructions are present, only the last one takes effect.
- CMD is a default. It can be overridden by the user at runtime by passing a
  command to `docker run`.
- CMD executes at runtime, not at build time. It does not affect the image
  contents.

---

## .dockerignore

### Purpose

The `.dockerignore` file is not a Dockerfile instruction, but it is closely
related to the build process. It tells Docker which files and directories to
**exclude** when copying files from the host machine into the image.

It works the same way as `.gitignore` works with Git. Any file or directory
pattern listed in `.dockerignore` is skipped during the COPY instruction.

### Location

The `.dockerignore` file must be placed in the **root of the build context**
(the same directory where the Dockerfile is located and where `docker build`
is run from).

### Syntax

Each line in the file specifies a pattern to exclude:

```
# This is a comment
node_modules
dist
.git
.github
*.txt
documents/
```

### Pattern Examples

| Pattern         | What It Excludes                                      |
|-----------------|-------------------------------------------------------|
| node_modules    | The node_modules directory and everything inside it   |
| dist            | The dist directory and everything inside it           |
| .git            | The .git directory (version control history)          |
| *.txt           | All files ending in .txt                              |
| *.log           | All files ending in .log                              |
| documents/      | The documents directory and everything inside it      |
| **/*.test.js    | All .test.js files in any subdirectory                |
| temp*           | All files and directories starting with "temp"        |

### Why .dockerignore Matters

Without a `.dockerignore` file, COPY instructions include **everything** in the
build context. This can cause several problems:

1. **Unnecessary size** -- Copying `node_modules` (which can be hundreds of
   megabytes) into the image and then running `npm install` again is wasteful.
   The dependencies will be installed fresh inside the image anyway.

2. **Slower builds** -- More files to copy means longer build times. Docker
   sends the entire build context to the Docker engine before building. A
   large build context slows down this transfer.

3. **Security risks** -- Files like `.env` (environment variables), `.git`
   (repository history), or configuration files with credentials should never
   be included in an image.

4. **Build cache invalidation** -- If irrelevant files change (like notes or
   documentation), Docker may think the COPY layer has changed and rebuild
   subsequent layers unnecessarily.

### Example .dockerignore File

```
# Dependencies -- will be installed fresh inside the image
node_modules

# Build output -- will be generated fresh inside the image
dist

# Version control -- not needed inside the image
.git
.github

# Documentation and notes -- not needed at runtime
documents/
*.txt

# Environment files -- may contain sensitive information
.env
.env.local
```

### Important Notes

- `.dockerignore` is read automatically by Docker during the build. It does not
  need to be referenced in the Dockerfile.
- Patterns are matched against the file paths relative to the build context root.
- Comments begin with `#`.
- If a file is listed in `.dockerignore`, no COPY instruction can include it,
  regardless of the source path specified.

---

## Instruction Summary

| Instruction | When It Runs | Purpose                                           |
|-------------|--------------|---------------------------------------------------|
| FROM        | Build time   | Select the base image to build on                  |
| WORKDIR     | Build time   | Set the working directory for subsequent commands  |
| COPY        | Build time   | Copy files from the host machine into the image    |
| RUN         | Build time   | Execute a command to prepare the image             |
| CMD         | Runtime      | Define the default command to run in a container   |

### Build Time vs Runtime

- **Build time** instructions (FROM, WORKDIR, COPY, RUN) execute when the image
  is being built using `docker build`. They shape the contents of the image.

- **Runtime** instructions (CMD) execute when a container is created from the
  image using `docker run`. They define the behavior of the container.

---

## Complete Dockerfile Example with Explanation

```dockerfile
FROM node:24.13.0-trixie-slim     # Start from a Node.js base image
WORKDIR /app                       # Set working directory to /app
COPY . .                           # Copy project files into /app
RUN npm install                    # Install dependencies
RUN npm run build                  # Compile TypeScript to JavaScript
CMD ["npm", "run", "executeApp"]   # Run the application when container starts
```

When this Dockerfile is built:

1. Docker downloads the Node.js 24.13.0 slim image (if not already available).
2. Docker creates the `/app` directory inside the image.
3. Docker copies the project files (excluding those in `.dockerignore`) into `/app`.
4. Docker runs `npm install`, which installs TypeScript into `/app/node_modules`.
5. Docker runs `npm run build`, which compiles `app.ts` into `dist/app.js`.
6. Docker saves the CMD instruction as the container's startup command.

When a container is created from the resulting image:

1. Docker starts the container.
2. The CMD instruction executes: `npm run executeApp`.
3. This runs `node ./dist/app.js`, which prints "Hello Docker" to the console.
4. The application finishes, and the container exits.
