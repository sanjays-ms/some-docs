# What is Docker?

Docker is a platform that allows developers to package applications and all of
their dependencies into standardized, portable units that can run reliably on
any system. These portable units are called **containers**.

At its core, Docker ensures that an application behaves the same way regardless
of where it runs -- whether that is a developer's laptop, a test server, or a
production environment in the cloud. It eliminates the inconsistencies that arise
when different machines have different software versions, configurations, or
operating systems.

---

## The Problem Docker Solves

Software applications depend on many things beyond just the code itself. A typical
application might require:

- A specific version of a programming language runtime (such as Node.js 20 or Python 3.12)
- Certain system libraries and packages
- Particular configuration files and environment variables
- Specific versions of third-party dependencies

When an application is developed on one machine and then moved to another, things
often break. The second machine might have a different version of the runtime, might
be missing a required library, or might have conflicting configurations. This is an
extremely common problem in software development, often referred to by the phrase:
**"It works on my machine."**

### An Example of the Problem

Consider a simple Node.js application written in TypeScript:

- Developer A has Node.js version 20 and TypeScript version 5.9 installed.
- Developer A builds the application and it works perfectly.
- Developer A sends the code to Developer B.
- Developer B has Node.js version 18 and does not have TypeScript installed at all.
- The application fails to run on Developer B's machine.

The code is identical. The machines are different. That is the problem.

### How Docker Solves It

Docker solves this by packaging the application **together with its entire environment**.
Instead of saying "here is my code, go install everything it needs," Docker says
"here is my code along with the exact runtime, the exact libraries, and the exact
configuration it requires -- all in one package."

When someone runs that Docker package, they do not need to install Node.js. They do
not need to install TypeScript. They do not need to worry about versions or
configurations. Docker handles all of it because everything is already bundled inside
the package.

The only requirement is that Docker itself is installed on the machine. After that,
any Docker package will run the same way everywhere.

---

## Containers vs Virtual Machines

Before Docker and containers became popular, one common way to solve environment
inconsistency was to use virtual machines. Both approaches achieve isolation, but
they work very differently.

### Virtual Machines

A virtual machine (VM) is essentially a **complete computer running inside another
computer**. It has its own operating system, its own allocated memory, its own virtual
hardware, and its own kernel. A piece of software called a **hypervisor** sits between
the physical hardware and the virtual machines, managing resource allocation.

Virtual machines provide very strong isolation because each VM is a fully independent
system. However, this comes at a significant cost:

- Each VM includes an entire operating system, which can be several gigabytes in size.
- VMs take minutes to boot up because they must initialize an entire OS.
- Running multiple VMs requires substantial CPU, memory, and disk resources.
- VMs are heavy to move, copy, and share.

An analogy: using a virtual machine is like renting an entire apartment just to use
the kitchen. It works, but it comes with a lot of overhead.

### Containers

A container takes a fundamentally different approach. Instead of running a full
operating system, a container **shares the host machine's operating system kernel**.
Each container gets its own isolated space for files, processes, and network, but
it does not carry the weight of an entire OS.

This makes containers:

- Extremely fast to start (typically seconds, not minutes).
- Very small in size (often megabytes instead of gigabytes).
- Efficient with system resources because they share the host kernel.
- Easy to create, destroy, move, and replicate.

An analogy: using a container is like having a private kitchen counter in a shared
kitchen. Each person gets their own workspace and tools, but nobody is carrying the
cost of an entire separate apartment.

### Side-by-Side Comparison

| Feature                  | Virtual Machine              | Container                       |
|--------------------------|------------------------------|---------------------------------|
| Startup time             | Minutes                      | Seconds                         |
| Typical size             | Gigabytes                    | Megabytes                       |
| Includes full OS         | Yes                          | No (shares host OS kernel)      |
| Isolation level          | Complete (separate kernel)   | Process-level (shared kernel)   |
| Resource usage           | Heavy                        | Lightweight                     |
| Portability              | Harder to move and share     | Very easy to move and share     |
| Density (per host)       | Fewer VMs per host           | Many containers per host        |

Both virtual machines and containers have their place. VMs are better when complete
isolation with a separate OS is required. Containers are better for packaging and
running applications efficiently.

---

## How Docker Runs on Windows

Docker was originally built for Linux. Containers rely on Linux kernel features to
provide isolation. On a Windows machine, Docker uses **WSL2** (Windows Subsystem for
Linux) to run a lightweight Linux environment behind the scenes.

When Docker Desktop is installed on Windows, it automatically sets up WSL2 and runs
the Docker engine inside it. All containers run within this Linux environment. The
user interacts with Docker through the Windows terminal as normal -- Docker and WSL2
handle the translation between Windows and Linux automatically.

This means:

- Docker commands are typed in the Windows terminal (Command Prompt, PowerShell,
  or a terminal inside VS Code).
- The containers themselves run inside the WSL2 Linux environment.
- No manual configuration of WSL2 is needed. Docker Desktop manages it.

---

## Summary

- Docker is a platform for packaging applications with their dependencies into
  portable containers.
- It solves the "it works on my machine" problem by ensuring the environment
  travels with the application.
- Containers are lighter, faster, and more efficient than virtual machines because
  they share the host operating system kernel instead of running their own.
- On Windows, Docker runs through WSL2, a lightweight Linux layer managed
  automatically by Docker Desktop.
