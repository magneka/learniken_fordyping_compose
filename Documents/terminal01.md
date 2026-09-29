# Terminal01 example

A minimal Docker Compose setup that gives you a Linux container with `gcc` and a
bind-mounted source folder, for compiling and running small C/C++ programs. It
also ships the GitHub Copilot CLI, so you can ask an AI agent for help directly
in the container's terminal.

## Files

- `Eksempler/Terminal01/Dockerfile` — `debian:bookworm-slim` base image with `gcc`,
  `g++`, `gdb`, and the GitHub Copilot CLI (`copilot`) installed. `WORKDIR` is
  `/app`, and the container's default command (`CMD`) just drops you into `bash`
  (kept alive by the compose `tty`/`stdin_open` settings below).
- `Eksempler/Terminal01/docker-compose.yml` — defines the `terminal` service, builds
  the image from the Dockerfile above, and bind-mounts `./source` into `/app` in the
  container so edits made on the host are immediately visible inside it.
- `Eksempler/Terminal01/source/hello.cpp` — a small C++ program that prints
  `"Hello, world!"` and the sum of two integers.
- `Eksempler/Terminal01/source/.vscode/` — editor config for the attached VS Code
  window (see "Debugging" below): `extensions.json` (recommended extensions),
  `tasks.json` (the `g++` build task), and `launch.json` (the `gdb` debug config).

## Dockerfile and compose file explained

### Dockerfile

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ gdb curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://gh.io/copilot-install | bash
WORKDIR /app
CMD ["bash"]
```

- **`FROM debian:bookworm-slim`** — base image: a minimal Debian 12 ("bookworm")
  build. "Slim" strips docs/manuals/extra packages to keep the image small; it does
  **not** include a compiler by default.
- **`RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ gdb curl ca-certificates && rm -rf /var/lib/apt/lists/*`**
  — a single `RUN` layer that:
  - `apt-get update` refreshes the package index (required before any install,
    since the base image has none cached).
  - `apt-get install -y --no-install-recommends gcc g++ gdb curl ca-certificates`
    installs the GNU C compiler, the C++ compiler/standard library, the GDB
    debugger, and `curl`/`ca-certificates` (needed to fetch the Copilot CLI
    install script over HTTPS below) non-interactively (`-y`), skipping
    suggested-but-not-required packages (`--no-install-recommends`) to avoid
    pulling in extra bloat.
  - `rm -rf /var/lib/apt/lists/*` deletes the downloaded package index afterward.
    This is chained with `&&` in the *same* `RUN` so it lands in the same image
    layer — if it were a separate `RUN`, the index files would already be baked
    into an earlier layer and deleting them later wouldn't shrink the image.
- **`RUN curl -fsSL https://gh.io/copilot-install | bash`** — downloads and runs
  GitHub's official install script for the standalone GitHub Copilot CLI
  (`copilot`). Since this `RUN` executes as root during the build, the script
  installs the binary into `/usr/local/bin` (already on `PATH`) without needing
  `sudo`. No Node.js is required — this is the prebuilt-binary install path,
  as opposed to `npm install -g @github/copilot`.
- **`WORKDIR /app`** — creates `/app` (if missing) and sets it as the default
  working directory for subsequent instructions and for anything run in the
  container. This is also the mount target used by compose.
- **`CMD ["bash"]`** — the default command when the container starts, using exec
  form (no shell wrapper). Just drops you into an interactive Bash shell. `CMD` is
  a default that can be overridden per `docker run`/`exec`, unlike `ENTRYPOINT`.

### docker-compose.yml

```yaml
name: terminal01
services:
  terminal:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: terminal01
    stdin_open: true
    tty: true
    volumes:
      - ./source:/app
```

- **`name: terminal01`** — sets the Compose project name explicitly. This prefixes
  auto-generated resource names (networks, default volumes) instead of defaulting
  to the folder name.
- **`services.terminal`** — defines one service/container named `terminal` (the key
  used for `docker compose exec terminal ...`).
- **`build.context: .`** — the build context is the `Terminal01` folder itself
  (where the compose file lives), i.e. everything in that folder is sent to the
  Docker daemon as the build context.
- **`build.dockerfile: Dockerfile`** — explicitly names the Dockerfile to use
  (redundant here since `Dockerfile` is already the default, but explicit for
  clarity).
- **`container_name: terminal01`** — fixes the container's name to `terminal01`
  instead of Compose's auto-generated `<project>-<service>-<n>` name, so
  `docker exec`/attach targets are predictable.
- **`stdin_open: true`** — keeps STDIN open (Docker's `-i` equivalent), letting the
  container accept interactive input.
- **`tty: true`** — allocates a pseudo-TTY (Docker's `-t` equivalent). Combined
  with `stdin_open`, this is what makes `CMD ["bash"]` behave like an interactive
  shell and, crucially, keeps the container alive (bash doesn't exit immediately)
  so you can `exec`/attach into it later.
- **`volumes: - ./source:/app`** — bind-mounts the host folder `Terminal01/source`
  onto `/app` inside the container (the `WORKDIR`). Files created/edited on the
  host appear instantly in the container and vice versa, with no image rebuild
  needed to pick up source changes.

## Running it

From the repo root:

```bash
# build the image and start the container in the background
docker compose -f Eksempler/Terminal01/docker-compose.yml up -d --build

# open an interactive shell inside the running container
docker compose -f Eksempler/Terminal01/docker-compose.yml exec terminal bash
```

Inside the container, `/app` is the mounted `source` folder:

```bash
cd /app
ls              # hello.cpp
```

`hello.cpp` is C++, and the image already includes `g++`, so you can compile and run
it directly:

```bash
g++ hello.cpp -o hello
./hello
```

The GitHub Copilot CLI is also available as `copilot`. The first time you run it
you'll need to authenticate (via the `/login` slash command, or a personal access
token in `GH_TOKEN`/`GITHUB_TOKEN` — see the
[official docs](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli)):

```bash
copilot
```

Stop and remove the container when done:

```bash
docker compose -f Eksempler/Terminal01/docker-compose.yml down
```

## Debugging

The image already includes `g++` and `gdb`, and debugging is done by attaching
VS Code directly to the already-running `terminal01` container (started via
`docker compose up -d` above) rather than by driving `gdb` from the command line.

### 1. Install extensions

The `source/.vscode/extensions.json` file already recommends these — VS Code
prompts to install them once you open `/app` as a folder:

```json
{
    "recommendations": [
        "ms-vscode.cpptools",
        "github.copilot-chat"
    ]
}
```

- **C/C++** (`ms-vscode.cpptools`) — provides the debugger integration.
- **GitHub Copilot Chat** (`github.copilot-chat`) — lets you ask Copilot for help
  directly in the editor, complementing the `copilot` CLI already installed in the
  container.

You'll also need the **Dev Containers** extension
(`ms-vscode-remote.remote-containers`) on the *host* side, since that's what lets
VS Code attach to a running container in the first place.

### 2. Attach to the running container

1. Command Palette → **Dev Containers: Attach to Running Container...**
2. Select `terminal01`.
3. A new VS Code window opens with its extension host running inside the
   container. Open `/app` as the folder and accept the extension
   recommendations prompt (C/C++ and Copilot Chat install separately from your
   host-side extensions, since they run inside the container).

### 3. Debug it

`source/.vscode/tasks.json` and `launch.json` already exist, so there's nothing to
create. They were generated by cpptools' "build and debug active file" flow and
target whichever `.cpp` file is currently open:

```json
// tasks.json
{
    "label": "C/C++: g++ build active file",
    "command": "/usr/bin/g++",
    "args": ["-fdiagnostics-color=always", "-g", "${file}", "-o", "${fileDirname}/${fileBasenameNoExtension}"]
}
```

```json
// launch.json
{
    "name": "C/C++: g++ build and debug active file",
    "type": "cppdbg",
    "program": "${fileDirname}/${fileBasenameNoExtension}",
    "MIMode": "gdb",
    "miDebuggerPath": "/usr/bin/gdb",
    "preLaunchTask": "C/C++: g++ build active file"
}
```

- `${file}` / `${fileDirname}` / `${fileBasenameNoExtension}` all resolve to the
  file open in the active editor tab, so this works for `hello.cpp` without
  hardcoding its name.
- `-g` compiles with debug symbols; `preLaunchTask` runs the build automatically
  before launching `gdb`.

Open `hello.cpp`, set a breakpoint, and press **F5**. VS Code builds the binary
inside the container and stops at your breakpoint with normal variable
inspection, stepping, and call-stack views.

Because `./source` is bind-mounted, edits made on the host (or in the attached
window) are immediately visible on both sides — no image rebuild needed between
debug sessions, only a re-run of the build task.
