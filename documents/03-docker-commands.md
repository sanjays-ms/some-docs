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

## Quick Reference

| Command            | Purpose                                                     |
|--------------------|-------------------------------------------------------------|
| docker run         | Create a new container from an image and run it              |
| docker start       | Restart an existing stopped container                        |
| docker ps          | List containers that are currently running                   |
| docker ps -a       | List all containers (running, stopped, and created)          |
| docker images      | List all images stored on the local machine                  |
| docker --version   | Display the installed Docker version                         |
| docker info        | Display detailed Docker system information                   |
