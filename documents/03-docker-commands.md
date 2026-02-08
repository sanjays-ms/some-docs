# Docker Commands Reference

This document provides a detailed reference for fundamental Docker commands.
Each command is explained with its purpose, usage syntax, practical examples,
and sample output to illustrate what to expect when running it.

---

## docker run

### Purpose

The `docker run` command creates a **new container** from a specified image and
starts it. It is the primary way to launch applications in Docker.

If the specified image is not available on the local machine, Docker automatically
downloads (pulls) it from Docker Hub before creating the container.

### Syntax

```
docker run [options] <image_name>
```

### Behavior

- Every execution of `docker run` creates a **brand new container**, even if a
  container from the same image already exists on the system.
- It does not check for or reuse previously created containers.
- The container will run until the application inside it finishes executing, at
  which point the container enters the "Exited" state.
- The container is not automatically deleted after it stops. It remains on the
  system in a stopped state until explicitly removed.

### Example: Running a Simple Image

```
docker run hello-world
```

### Sample Output (Image Not Yet Downloaded)

When the image does not exist on the local machine, Docker pulls it first:

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete
Digest: sha256:d211f485f2dd1dee407a80973c8f129f00d54604d2c90732e8e320e5038a0348
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
```

The first few lines confirm that Docker searched locally, did not find the image,
and downloaded it from Docker Hub. After the download completed, Docker created
a container, ran the application inside it, and displayed the output.

### Sample Output (Image Already Downloaded)

When the image already exists on the local machine, Docker skips the download:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

The output is the same application message, but without the download step. Docker
found the image locally, created a new container from it, and ran it immediately.

### Important Note

Running `docker run hello-world` three times would create three separate containers,
each with its own Container ID and name. The image is used as a template each time,
but the resulting containers are independent of each other.

---

## docker images

### Purpose

The `docker images` command lists all images currently stored on the local machine.
This includes images that were built locally from Dockerfiles as well as images that
were downloaded (pulled) from Docker Hub or other registries.

### Syntax

```
docker images
```

### Sample Output

```
IMAGE                ID             DISK USAGE   CONTENT SIZE
alpine:latest        a8560b36e8b8       12.1MB       3.64MB
hello-world:latest   05813aedc15f       25.9kB       9.52kB
node:20-alpine       f73fa81bcec5       3.38GB        770MB
```

### Column Descriptions

| Column         | Description                                                  |
|----------------|--------------------------------------------------------------|
| IMAGE          | The name and tag of the image. The tag identifies a specific |
|                | version. "latest" is the default tag assigned when no        |
|                | specific version is requested.                               |
| ID             | A unique identifier (hash) for the image. This can be used   |
|                | in place of the image name in commands.                      |
| DISK USAGE     | The total space the image occupies on the local disk.        |
| CONTENT SIZE   | The compressed size of the image content as downloaded.      |

### Notes

- Images remain on the local machine until explicitly removed using `docker rmi`.
- The same image will not be downloaded again if it already exists locally (unless
  a newer version is available and explicitly pulled).
- Images that are currently being used by one or more containers (running or stopped)
  are marked as "In Use" and cannot be removed until those containers are deleted.

---

## docker ps

### Purpose

The `docker ps` command lists **only the containers that are currently running**.
Containers that have stopped (exited) are not shown.
ps - stands for processes

### Syntax

```
docker ps
```

### Sample Output

```
CONTAINER ID   IMAGE                           COMMAND                  CREATED        STATUS       PORTS     NAMES
f12f02badaee   moby/buildkit:buildx-stable-1   "buildkitd --allow-i…"   6 months ago   Up 3 hours             buildx_buildkit_frosty_edison0
```

In this example, only one container is running -- a background BuildKit service that
Docker Desktop manages automatically. If a hello-world container had been run earlier,
it would not appear here because hello-world exits immediately after printing its
message.

### When to Use

Use `docker ps` to check which containers are actively running at the current moment.
This is useful for verifying that a server or long-running application is still up,
or for checking whether a container needs to be stopped.

---

## docker ps -a

### Purpose

The `docker ps -a` command lists **all containers** on the system, regardless of
their current state. This includes containers that are running, stopped, or created
but never started. The `-a` flag stands for "all."

### Syntax

```
docker ps -a
```

### Sample Output

```
CONTAINER ID   IMAGE                           COMMAND      CREATED          STATUS                      PORTS     NAMES
49a2849431b0   hello-world                     "/hello"     2 minutes ago    Exited (0) 2 minutes ago              clever_thompson
ed1e9d43a3a8   hello-world                     "/hello"     4 minutes ago    Exited (0) 4 minutes ago              tender_tu
f12f02badaee   moby/buildkit:buildx-stable-1   "buildkitd…" 6 months ago    Up 3 hours                            buildx_buildkit_frosty_edison0
```

This output shows three containers: two hello-world containers that have finished
running and one BuildKit container that is still active.

### Column Descriptions

| Column         | Description                                                  |
|----------------|--------------------------------------------------------------|
| CONTAINER ID   | A unique identifier for the container. This can be used to   |
|                | reference the container in other commands (such as start,    |
|                | stop, or remove).                                            |
| IMAGE          | The image that the container was created from.               |
| COMMAND        | The command that was executed inside the container when it    |
|                | started. Long commands are truncated in the display.         |
| CREATED        | How long ago the container was created.                      |
| STATUS         | The current state of the container. Common values:           |
|                | - "Up X hours" -- the container is running.                  |
|                | - "Exited (0)" -- the container stopped successfully.        |
|                |   Exit code 0 means no errors occurred.                      |
|                | - "Exited (1)" or any non-zero code -- the container stopped |
|                |   due to an error. The number indicates the type of error.   |
|                | - "Created" -- the container exists but was never started.   |
| PORTS          | Any network port mappings between the container and the host.|
|                | Empty if no ports are exposed.                               |
| NAMES          | The name of the container. Docker assigns a random name      |
|                | (such as "clever_thompson" or "tender_tu") if no name is     |
|                | specified by the user when creating the container.           |

### Difference Between docker ps and docker ps -a

| Command      | What It Shows                                              |
|--------------|------------------------------------------------------------|
| docker ps    | Only containers that are currently running                  |
| docker ps -a | All containers: running, stopped, and created-but-not-started |

---

## docker start

### Purpose

The `docker start` command restarts a **previously stopped container** without
creating a new one. This is the key difference from `docker run`, which always
creates a brand new container.

When a container stops, it does not disappear. It remains on the system with all
of its state preserved. The `docker start` command brings that existing container
back to life.

### Syntax

```
docker start <container_name_or_id>
```

The container can be referenced by either its name or its Container ID. Both are
shown in the output of `docker ps -a`.

### Example: Restarting a Stopped Container by Name

```
docker start clever_thompson
```

This restarts the container named "clever_thompson" rather than creating a new one.
The container runs the same image and the same command it was originally created with.

### Example: Restarting a Stopped Container by ID

```
docker start 49a2849431b0
```

This does the same thing, using the Container ID instead of the name.

### When to Use

Use `docker start` when a container already exists and simply needs to be restarted.
Common scenarios include:

- A container that was intentionally stopped and needs to resume.
- A container that crashed and needs to be restarted.
- Avoiding the creation of duplicate containers from the same image.

### docker run vs docker start

This is an important distinction to understand clearly:

| Command       | Behavior                                                    |
|---------------|-------------------------------------------------------------|
| docker run    | Always creates a **new container** from an image and runs it. |
|               | Running it five times produces five separate containers.     |
| docker start  | Restarts an **existing container** that was previously stopped.|
|               | No new container is created. The same container resumes.     |

### Example Scenario

1. Run `docker run hello-world` -- Docker creates Container A and runs it.
   Container A prints the message and stops.
2. Run `docker run hello-world` again -- Docker creates Container B (a new,
   separate container) and runs it. Container B prints the message and stops.
3. Run `docker start Container_A` -- Docker restarts the original Container A.
   No new container is created. Container A prints the message again and stops.

After these three steps, there are two containers on the system (A and B), not three.

---

## docker --version

### Purpose

Displays the version of Docker installed on the system. Useful for verifying that
Docker is installed and for checking compatibility with specific features.

### Syntax

```
docker --version
```

### Sample Output

```
Docker version 29.2.0, build 0b9d198
```

This confirms Docker version 29.2.0 is installed. The build hash (0b9d198) identifies
the exact build of that version.

---

## docker info

### Purpose

Displays a comprehensive summary of the Docker installation and system configuration.
This includes the server version, the number of containers and images on the system,
installed plugins, storage driver information, operating system details, and resource
allocation (CPUs, memory).

### Syntax

```
docker info
```

### When to Use

Use `docker info` to:

- Verify that the Docker engine is running and responsive.
- Check system resource allocation (CPUs, memory available to Docker).
- See how many containers and images exist on the system.
- Identify installed plugins (such as Compose, Buildx, or Scout).
- Confirm the underlying operating system and kernel version.

### Sample Output (Abbreviated)

```
Server:
 Containers: 5
  Running: 1
  Paused: 0
  Stopped: 4
 Images: 7
 Server Version: 29.2.0
 Kernel Version: 5.15.167.4-microsoft-standard-WSL2
 Operating System: Docker Desktop
 CPUs: 16
 Total Memory: 31.32GiB
```

This tells us Docker has 5 containers (1 running, 4 stopped), 7 images, is running
on Docker Desktop through WSL2, and has access to 16 CPUs and roughly 31 GB of memory.

---

## docker build

### Purpose

The `docker build` command reads a Dockerfile, executes each instruction in order,
and produces an image. This is the command that transforms a Dockerfile (a text file
with instructions) into a usable image that can be run as a container.

### Syntax

```
docker build [options] <build_context>
```

The most common form is:

```
docker build -t <image_name> .
```

### Build Context

The **build context** is the directory path provided at the end of the `docker build`
command. In most cases, this is `.` (a single dot), which represents the current
working directory.

The build context serves two purposes:

1. **Locating the Dockerfile (when `-f` is not used):** If no `-f` flag is provided,
   Docker looks for a file named exactly `Dockerfile` (capital D, no file extension)
   inside the build context directory. If it does not find one, the build fails.

2. **Defining the files available to COPY instructions:** The build context determines
   which files from the host machine can be copied into the image. When a Dockerfile
   contains `COPY . .`, the first `.` refers to "everything in the build context."
   Docker sends the entire build context directory (minus files excluded by
   `.dockerignore`) to the Docker engine before the build begins.

The build context **always** defines the pool of files available to COPY, regardless
of whether `-f` is used. However, it only helps locate the Dockerfile when `-f` is
not specified.

| Situation                      | Build context locates Dockerfile? | Build context defines COPY files? |
|--------------------------------|-----------------------------------|-----------------------------------|
| `-f` flag is **not** used      | Yes                               | Yes                               |
| `-f` flag **is** used          | No (the `-f` flag handles this)   | Yes                               |

### Example: Building from the Current Directory

```
docker build -t my-app .
```

This tells Docker:
- `-t my-app` -- Name the resulting image "my-app."
- `.` -- Use the current directory as the build context. Look for a `Dockerfile`
  in this directory and make all files in this directory available to COPY.

Docker then:
1. Checks the current directory for a file named `Dockerfile`.
2. Sends all files in the current directory (excluding those in `.dockerignore`)
   to the Docker engine.
3. Reads the Dockerfile and executes each instruction in order.
4. Produces an image named `my-app:latest`.

### Sample Output (Successful Build)

```
[+] Building 25.3s (10/10) FINISHED
 => [internal] load build definition from Dockerfile                       0.0s
 => => transferring dockerfile: 532B                                       0.0s
 => [internal] load .dockerignore                                          0.0s
 => => transferring context: 95B                                           0.0s
 => [internal] load metadata for docker.io/library/node:24.13.0-trixie-slim  1.2s
 => [1/5] FROM docker.io/library/node:24.13.0-trixie-slim@sha256:abc123   8.4s
 => [internal] load build context                                          0.0s
 => => transferring context: 1.23kB                                        0.0s
 => [2/5] WORKDIR /app                                                     0.1s
 => [3/5] COPY . .                                                         0.0s
 => [4/5] RUN npm install                                                 10.2s
 => [5/5] RUN npm run build                                                3.1s
 => exporting to image                                                     2.3s
 => => naming to docker.io/library/my-app:latest                           0.0s
```

Each line corresponds to a step in the Dockerfile:
- **[1/5] FROM** -- Pulling or using the base image.
- **[2/5] WORKDIR** -- Setting the working directory.
- **[3/5] COPY** -- Copying project files into the image.
- **[4/5] RUN npm install** -- Installing dependencies.
- **[5/5] RUN npm run build** -- Compiling TypeScript.
- **exporting to image** -- Finalizing and saving the image.

If any step fails, the build stops immediately and prints an error message. A
successful build completes all steps without errors.

### Sample Output (Failed Build)

If the Dockerfile contains an error (for example, a RUN command that fails), the
output would look like:

```
[+] Building 12.1s (9/10) ERROR
 => [4/5] RUN npm install                                                 10.2s
 => ERROR [5/5] RUN npm run build                                          1.9s
------
 > [5/5] RUN npm run build:
 > error TS6053: File 'app.ts' not found.
------
ERROR: failed to solve: process "/bin/sh -c npm run build" did not complete successfully: exit code: 2
```

The error message indicates which step failed and why. In this example, the
TypeScript compiler could not find `app.ts`, causing the build to fail at step 5.

---

## docker build -t (Tagging an Image)

### Purpose

The `-t` flag (short for "tag") assigns a **name** to the image being built. Without
it, the image is only identified by a randomly generated Image ID (a long hash),
which is difficult to reference and manage.

### Syntax

```
docker build -t <name> .
docker build -t <name>:<tag> .
```

- `<name>` -- The name to assign to the image.
- `<tag>` -- An optional version label. If omitted, Docker defaults to `latest`.

### Examples

**Build with just a name (tag defaults to "latest"):**

```
docker build -t my-app .
```

The resulting image is named `my-app:latest`.

**Build with a name and a specific version tag:**

```
docker build -t my-app:1.0 .
```

The resulting image is named `my-app:1.0`. This is useful for keeping track of
different versions of the same application.

**Build with multiple tags:**

```
docker build -t my-app:1.0 -t my-app:latest .
```

The same image gets two tags: `my-app:1.0` and `my-app:latest`. Both point to
the exact same image. This is commonly done so that `latest` always refers to
the most recent version.

### With -t vs Without -t

| Scenario     | Image identifier in `docker images`          | Easy to reference? |
|--------------|----------------------------------------------|--------------------|
| With `-t`    | `my-app:latest`                              | Yes                |
| Without `-t` | `<none>:<none>` (only the Image ID is shown) | No                 |

When viewing containers created from an unnamed image, the IMAGE column in
`docker ps -a` shows only the Image ID hash instead of a readable name:

```
CONTAINER ID   IMAGE          NAMES
ffe521c05ead   ad28b069f374   funny_yalow
```

Compared to a named image:

```
CONTAINER ID   IMAGE          NAMES
49a2849431b0   my-app         clever_thompson
```

The `-t` flag is technically optional, but in practice it should always be used.
There is no benefit to having unnamed images.

---

## docker build -f (Specifying a Dockerfile)

### Purpose

The `-f` flag (short for "file") tells Docker to use a **specific Dockerfile**
instead of looking for the default file named `Dockerfile`. This is necessary when
a project contains multiple Dockerfiles for different purposes.

### Syntax

```
docker build -t <name> -f <dockerfile_path> <build_context>
```

- `<dockerfile_path>` -- The path to the Dockerfile to use. This can be a filename
  in the current directory or a path to a file in a different location.
- `<build_context>` -- The directory to use as the build context (still required).

### When This is Needed

Projects sometimes have multiple Dockerfiles for different environments or purposes:

```
project/
  Dockerfile           (default -- used for production)
  Dockerfile.dev       (development configuration with extra debugging tools)
  Dockerfile.prod      (optimized production build)
  Dockerfile.test      (includes testing frameworks)
```

Without `-f`, Docker always looks for the file named `Dockerfile`. To use any of
the others, the `-f` flag is required.

### Examples

**Build using a development Dockerfile:**

```
docker build -t my-app-dev -f Dockerfile.dev .
```

Docker reads `Dockerfile.dev` instead of `Dockerfile`. The build context is still
`.` (the current directory), so COPY instructions can still access all project files.

**Build using a production Dockerfile:**

```
docker build -t my-app-prod -f Dockerfile.prod .
```

**Build using a Dockerfile in a subdirectory:**

```
docker build -t my-app -f docker/Dockerfile.prod .
```

The Dockerfile is at `docker/Dockerfile.prod`, but the build context is still `.`
(the project root). This means COPY instructions can access files from the project
root, even though the Dockerfile is in a subdirectory.

### Important Notes

- When `-f` is used, the build context (`.`) no longer determines where Docker
  looks for the Dockerfile. It is only used to define the files available to COPY.
- The `-f` flag accepts both relative and absolute paths.
- If the specified file does not exist, Docker prints an error and the build fails.

---

## Verifying a Successful Build

After running `docker build`, there are several ways to confirm the image was
created correctly.

### Method 1: Check the Build Output

A successful build completes all steps and ends with a line similar to:

```
 => exporting to image                                                     2.3s
 => => naming to docker.io/library/my-app:latest                           0.0s
```

If any step had failed, Docker would have printed an error and stopped. Reaching
the end without errors means the build succeeded.

### Method 2: List Images with docker images

Run:

```
docker images
```

The newly built image should appear in the list:

```
IMAGE             ID             DISK USAGE   CONTENT SIZE
my-app:latest     a1b2c3d4e5f6       285MB        120MB
```

If the image appears with the correct name and tag, the build was successful.

### Method 3: Run the Image

The most reliable verification is to run the image and confirm it behaves as
expected:

```
docker run my-app
```

If the application produces the correct output (in this case, "Hello Docker"),
the image was built correctly and is fully functional.

### Method 4: Inspect the Image

For more detailed information about the image, use:

```
docker inspect <image_name>
```

This prints a large JSON output containing everything about the image: its layers,
environment variables, the CMD instruction, creation date, size, and more. This is
mainly useful for debugging or advanced verification.

---

## Image Tags

### What is a Tag?

A tag is a **label** attached to an image that identifies a specific version of it.
The full name of an image follows this format:

```
<image_name>:<tag>
```

For example:
- `my-docker-app:latest` -- The image named "my-docker-app" with the tag "latest."
- `my-docker-app:1.0` -- The same image name but with a version tag of "1.0."
- `node:24.13.0-trixie-slim` -- The official Node.js image with a tag that specifies
  the exact Node.js version, the Debian distribution, and the slim variant.

### The "latest" Tag

When an image is built or pulled without specifying a tag, Docker automatically
assigns the tag `latest`. This is the default tag.

These two commands produce the exact same result:

```
docker build -t my-app .
docker build -t my-app:latest .
```

Both create an image named `my-app:latest`.

Similarly, these two run commands are identical:

```
docker run my-app
docker run my-app:latest
```

Both look for the image `my-app:latest` on the local machine.

### Common Misconception: "latest" Does Not Mean "Most Recent"

The name `latest` is misleading. It does **not** automatically point to the most
recently built version of an image. It is simply a tag name -- a label like any
other.

Consider this sequence:

```
docker build -t my-app:1.0 .
# (make code changes)
docker build -t my-app:2.0 .
```

After these two builds, there is no `my-app:latest` image. Docker created
`my-app:1.0` and `my-app:2.0`, but `latest` was never assigned because a specific
tag was provided each time. Running `docker run my-app` would fail because Docker
would look for `my-app:latest`, which does not exist.

The `latest` tag only exists if:
- A build was done without any tag: `docker build -t my-app .`
- A build explicitly used the `latest` tag: `docker build -t my-app:latest .`

### When Tags Matter

For a single version of an image (such as during learning or local development),
tags are not critical. Leaving everything as `latest` works fine.

Tags become important when managing multiple versions of the same application:

```
docker build -t my-app:1.0 .       # Version 1.0
# (update code)
docker build -t my-app:2.0 .       # Version 2.0
# (update code again)
docker build -t my-app:3.0 .       # Version 3.0
```

Now there are three distinct images. To run a specific version:

```
docker run my-app:1.0    # Runs version 1.0
docker run my-app:2.0    # Runs version 2.0
docker run my-app:3.0    # Runs version 3.0
```

### Applying Multiple Tags to One Image

An image can have more than one tag. This is commonly used to tag a specific
version and also update `latest` to point to it:

```
docker build -t my-app:3.0 -t my-app:latest .
```

This creates a single image with two tags: `my-app:3.0` and `my-app:latest`.
Both tags point to the exact same image. This way, `docker run my-app` (which
looks for `latest`) will run version 3.0.

### Tag Behavior Summary

| Command                               | Resulting image tag       |
|---------------------------------------|---------------------------|
| `docker build -t my-app .`            | `my-app:latest`           |
| `docker build -t my-app:latest .`     | `my-app:latest`           |
| `docker build -t my-app:2.0 .`        | `my-app:2.0` (no latest)  |
| `docker build -t my-app:2.0 -t my-app:latest .` | Both `my-app:2.0` and `my-app:latest` |
| `docker run my-app`                   | Looks for `my-app:latest` |
| `docker run my-app:2.0`               | Looks for `my-app:2.0`    |

---

## Running an Image and Reading the Output

### What Happens When docker run Executes

When `docker run` is used to start a container, Docker:

1. Locates the specified image on the local machine (or pulls it from Docker Hub
   if not found locally).
2. Creates a new, isolated container from that image.
3. Executes the CMD instruction defined in the Dockerfile.
4. Streams the output from the container to the terminal.
5. When the application finishes, the container exits.

### Example: Running a Custom-Built Image

```
docker run my-docker-app
```

### Sample Output

```
> executeApp
> node ./dist/app.js

Hello Docker
```

This output tells us:

- `> executeApp` -- npm is running the script named "executeApp" from package.json.
- `> node ./dist/app.js` -- npm shows the actual command that the script runs.
- `Hello Docker` -- The application's output. This is the `console.log` statement
  from app.ts, now compiled to dist/app.js and executed by Node.js.

The container then exits with code 0 (success) because the application finished
without errors.

### Verifying the Container After It Runs

After `docker run` completes, the container still exists in a stopped state.
Running `docker ps -a` will show it:

```
CONTAINER ID   IMAGE            COMMAND                  STATUS                     NAMES
7f8a2b3c4d5e   my-docker-app    "docker-entrypoint.s…"   Exited (0) 5 seconds ago   happy_bell
```

The STATUS column shows "Exited (0)" -- the container ran, the application
completed successfully, and the container stopped. Exit code 0 confirms no
errors occurred.

### What If the Output Shows an Error?

If the application inside the container fails, the output would show the error
message and the container would exit with a non-zero code:

```
docker run my-docker-app
```

```
> executeApp
> node ./dist/app.js

Error: Cannot find module './dist/app.js'
```

Running `docker ps -a` would then show:

```
CONTAINER ID   IMAGE            STATUS                   NAMES
7f8a2b3c4d5e   my-docker-app    Exited (1) 3 seconds ago happy_bell
```

Exit code 1 (or any non-zero number) indicates that the application encountered
an error. The error message in the terminal output explains what went wrong.

---

## Quick Reference

| Command            | Purpose                                                     |
|--------------------|-------------------------------------------------------------|
| docker build       | Build an image from a Dockerfile                             |
| docker build -t    | Build and assign a name (tag) to the image                   |
| docker build -f    | Build using a specific Dockerfile (not the default)          |
| docker run         | Create a new container from an image and run it              |
| docker start       | Restart an existing stopped container                        |
| docker ps          | List containers that are currently running                   |
| docker ps -a       | List all containers (running, stopped, and created)          |
| docker images      | List all images stored on the local machine                  |
| docker inspect     | Display detailed information about an image or container     |
| docker --version   | Display the installed Docker version                         |
| docker info        | Display detailed Docker system information                   |
