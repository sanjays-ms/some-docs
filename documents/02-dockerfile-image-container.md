# Dockerfile, Image, and Container

These three concepts form the foundation of how Docker works. They are connected
in a sequential chain, where each one leads to the next:

```
Dockerfile  -->  Image  -->  Container
```

The Dockerfile is a set of instructions. Following those instructions produces an
Image. Running that Image creates a Container.

Understanding the distinction between these three is essential before working with
Docker in any meaningful way. This document explains each one in detail, how they
relate to each other, and where common points of confusion arise.

---

## Dockerfile

### What It Is

A Dockerfile is a **plain text file** that contains a sequence of instructions.
These instructions tell Docker exactly how to assemble an image. Each instruction
performs a specific action, such as selecting a base system, copying files, installing
software, or defining how the application should start.

A Dockerfile is not an image, and it is not a container. It is a blueprint -- a
written plan that describes what the image should contain.

### What a Dockerfile Typically Includes

The instructions in a Dockerfile follow a logical sequence. For a Node.js application,
that sequence might look like this:

1. **Select a base** -- Start with a pre-existing image that already includes
   Node.js and a minimal Linux system.
2. **Set a working directory** -- Define where inside the image the application
   files should live.
3. **Copy files** -- Bring the application code and configuration files into
   the image.
4. **Install dependencies** -- Run package installation commands so all required
   libraries are available.
5. **Define the startup command** -- Specify what command should execute when a
   container is created from this image.

### Key Characteristic

A Dockerfile does nothing on its own. It is a text file sitting in a project
directory. It only becomes useful when Docker is instructed to **build** it.
The build process reads the Dockerfile, executes each instruction in order, and
produces an image as the final output.

---

## Image

### What It Is

An image is the **result of building a Dockerfile**. It is a self-contained,
read-only package that includes everything described in the Dockerfile:

- A base system (typically a minimal Linux distribution with just enough tools
  for the application to function)
- The application runtime (such as Node.js, Python, or Java)
- The application source code
- All installed dependencies and libraries
- Configuration files and environment settings
- A defined command that will execute when the image is run

Once an image is built, it is frozen. It does not change. If changes are needed,
a new image must be built from a modified Dockerfile.

### Where Images Come From

Images can originate from two sources:

1. **Built locally** -- A developer writes a Dockerfile and runs the `docker build`
   command. Docker processes the instructions and produces an image stored on the
   local machine.

2. **Downloaded from a registry** -- Docker Hub is a public registry that hosts
   thousands of pre-built images. Anyone can download (pull) an image from Docker
   Hub using the `docker pull` command. When `docker run` is used with an image
   that does not exist locally, Docker automatically pulls it from Docker Hub
   before creating a container.

### Important Characteristics

- **Read-only**: An image cannot be modified after it is built. Any changes require
  building a new image.
- **Layered**: Images are built in layers, with each Dockerfile instruction creating
  a new layer. This allows Docker to cache unchanged layers and rebuild only what
  has changed, making subsequent builds faster.
- **Reusable**: A single image can be used to create any number of containers.
  Each container is an independent instance of the same image.
- **Portable**: An image built on one machine can be transferred to and run on
  any other machine with Docker installed.

### Analogy

Think of an image as a **class definition** in programming. The class defines the
structure and behavior, but it does not do anything until an instance (object) is
created from it. Similarly, an image defines everything about the application and
its environment, but it does not execute until a container is created from it.

For a non-technical analogy: an image is like a **recipe card**. The recipe describes
exactly what ingredients are needed and what steps to follow, but no food exists
until someone actually follows the recipe and cooks the dish.

---

## Container

### What It Is

A container is a **running instance of an image**. When Docker is told to run an
image, it creates an isolated environment and executes the application inside it.
That isolated, running environment is the container.

The container does not add anything beyond what the image already provides. It does
not download additional tools, install extra software, or bring its own dependencies.
Everything the container uses comes from the image. The container simply takes the
image and brings it to life.

### What Makes a Container Isolated

Each container operates in its own space, separate from the host system and from
other containers. Specifically, a container has:

- **Its own file system**: Files inside the container are separate from the host
  machine's files. Changes made inside the container do not affect the host.
- **Its own network interface**: The container has its own IP address and network
  stack. It cannot access the host network or other containers unless explicitly
  configured to do so.
- **Its own process space**: Processes running inside the container are invisible
  to the host and to other containers.

This isolation is what makes containers safe and predictable. An application inside
a container behaves the same way regardless of what else is running on the host.

### Container Lifecycle

A container moves through several states during its existence:

1. **Created** -- The container has been set up from an image but has not started
   running yet. It exists but is inactive.

2. **Running** -- The container is actively executing the application defined in the
   image. It is using system resources (CPU, memory) and can produce output, accept
   connections, or perform work.

3. **Exited** -- The application inside the container has finished executing (either
   successfully or due to an error), and the container has stopped. An exited
   container still exists on the system. It retains its file system state and logs
   but is no longer consuming CPU resources.

4. **Removed** -- The container has been explicitly deleted. It no longer exists on
   the system and cannot be restarted. Removing a container does not affect the
   image it was created from.

### Multiple Containers from One Image

A single image can be used to create many containers. Each container is completely
independent. For example, running the same web server image three times would create
three separate containers, each with its own network address, its own file system,
and its own process space. Changes made in one container do not affect the others.

This is similar to how multiple documents can be printed from the same PDF file.
Each printed copy is independent -- writing on one copy does not change the others,
and none of them alter the original PDF.

---

## How They Work Together

The following example illustrates the complete flow using a Node.js TypeScript
application:

### Step 1: Write a Dockerfile

A developer creates a Dockerfile in the project directory. The Dockerfile contains
instructions such as:

- Use a base image that includes Node.js
- Copy the project's source code and configuration files
- Install dependencies using npm
- Compile TypeScript to JavaScript
- Define the command to start the application

### Step 2: Build the Image

The developer runs the `docker build` command. Docker reads the Dockerfile, executes
each instruction in sequence, and produces an image. The image now contains Node.js,
the compiled JavaScript code, all installed dependencies, and the startup command --
everything needed to run the application.

### Step 3: Run the Image

The developer runs the `docker run` command, specifying the image. Docker creates a
container from that image. Inside the container, Node.js starts, the application
executes, and the output appears. The container is isolated from the host system.

```
Dockerfile              Image                   Container
(written instructions)  (built package)         (running application)
       |                      |                        |
       |   docker build       |    docker run          |
       |--------------------->|----------------------->|
```

---

## Common Point of Confusion: Does a Container Include an Operating System?

This is a frequent source of confusion. The short answer is: **not a full one**.

A Docker image typically starts from a **base image** that includes a minimal set
of Linux utilities -- things like a basic file system, a shell, and core system
libraries. This is far from a complete operating system. There is no graphical
interface, no desktop environment, no package of pre-installed applications. It is
the bare minimum needed for the application to function.

To illustrate the difference:

- A full Linux operating system installation (such as Ubuntu Desktop) is typically
  **2 to 4 gigabytes** and includes thousands of packages.
- A minimal Docker base image (such as Alpine Linux) is roughly **5 megabytes**
  and includes only the most essential system tools.

The container does not run its own kernel. It shares the kernel of the host machine
(or in the case of Docker on Windows, the kernel of the WSL2 Linux environment).
The base image provides just enough user-space tools for the application and its
dependencies to operate.

Think of it this way:

- A full operating system is like a fully furnished house with every room equipped.
- A Docker base image is like a single empty room with electricity and running water
  -- just enough infrastructure for someone to set up and do their work.

---

## Summary

| Concept    | What It Is                                          | Created By       |
|------------|-----------------------------------------------------|------------------|
| Dockerfile | A text file containing build instructions           | Written by hand  |
| Image      | A read-only package built from a Dockerfile         | docker build     |
| Container  | An isolated, running instance of an image           | docker run       |

- The Dockerfile is the plan.
- The Image is the packaged result of that plan.
- The Container is that package, running and executing the application.
- A container has no dependencies of its own. Everything comes from the image.
- Multiple containers can be created from a single image, each running independently.
