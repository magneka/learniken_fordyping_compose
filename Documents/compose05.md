# Compose05 example

A Go REST API (`go-api`) backed by SQL Server (`db`), with a one-shot init container
(`db-init`) that creates the database/table and seeds data. The API source is
bind-mounted into the container so you can build, run, and debug it live with the
VS Code Go extension.

## Files

- `Eksempler/Compose05/.env` — environment variables used for variable substitution
  in `docker-compose.yml` and for `select.sh`/`select.bat`.
- `Eksempler/Compose05/Dockerfile` — Go build image for the `go-api` service.
- `Eksempler/Compose05/docker-compose.yml` — the three services: `db`, `db-init`,
  `go-api`.
- `Eksempler/Compose05/mssql/init/init.sql` — creates the database/table and seeds
  sample customer rows; run once by `db-init`.
- `Eksempler/Compose05/go_api/source/` — the Go module (`main.go`, `go.mod`,
  `go.sum`) and its `.vscode/` folder, bind-mounted into the `go-api` container.
- `Eksempler/Compose05/go_api/api.http` — sample HTTP requests (list/create/get/
  delete customer) against the running API.
- `Eksempler/Compose05/select.sh` / `select.bat` — runs `SELECT * FROM customer;`
  against the `db` container via `sqlcmd`, for a quick sanity check from the host.

## .env

```
DB_DATABASE=cust
DB_USERNAME=sa
DB_PASSWORD=Password123!
```

Loaded automatically by Compose (it sits next to `docker-compose.yml`) and used to
substitute `${DB_DATABASE}`, `${DB_USERNAME}`, `${DB_PASSWORD}` in the compose file.
`select.sh`/`select.bat` also `source`/read it directly to build the `sqlcmd`
connection without repeating the password.

## Dockerfile

```dockerfile
FROM golang:latest

WORKDIR /app

RUN go install github.com/go-delve/delve/cmd/dlv@latest

COPY go_api/source/go.mod ./
RUN go mod tidy

COPY go_api/source/ .

CMD ["tail", "-f", "/dev/null"]
```

- **`FROM golang:latest`** — full Go SDK image (not the slim/alpine variant), so
  `go build`, `go vet`, etc. all work out of the box.
- **`WORKDIR /app`** — working directory for the rest of the build and for the
  bind-mounted source at runtime.
- **`RUN go install github.com/go-delve/delve/cmd/dlv@latest`** — installs
  [Delve](https://github.com/go-delve/delve), the Go debugger, into the image so
  the VS Code Go extension can debug the process from inside the container.
- **`COPY go_api/source/go.mod ./` + `RUN go mod tidy`** — copies just the module
  file first and resolves dependencies, so this (slow) layer is cached and only
  re-runs when `go.mod`/`go.sum` actually change.
- **`COPY go_api/source/ .`** — copies the rest of the source into the image. This
  copy is only a fallback/initial snapshot — at runtime the compose bind mount
  (below) overlays `/app` with the live host folder instead.
- **`CMD ["tail", "-f", "/dev/null"]`** — the image doesn't run the API itself.
  This command does nothing but keeps the container alive indefinitely, so you can
  attach to it and start/debug the Go program interactively from VS Code instead of
  the image auto-starting (and immediately exiting after) a prebuilt binary.

## docker-compose.yml

```yaml
name: learniken_compose_05

services:
  db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: learniken_compose_05_db
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_SA_PASSWORD: ${DB_PASSWORD}
    ports:
      - "1433:1433"
    volumes:
      - db_data:/var/opt/mssql
    healthcheck:
      test: ["CMD", "/opt/mssql-tools18/bin/sqlcmd", "-C", "-S", "localhost", "-U", "sa", "-P", "${DB_PASSWORD}", "-Q", "SELECT 1"]
      interval: 10s
      timeout: 5s
      retries: 10

  db-init:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: learniken_compose_05_db_init
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./mssql/init:/init
    entrypoint: ["/opt/mssql-tools18/bin/sqlcmd", "-C", "-S", "db", "-U", "sa", "-P", "${DB_PASSWORD}", "-v", "DBNAME=${DB_DATABASE}", "-i", "/init/init.sql"]

  go-api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: learniken_compose_05_go_api
    environment:
      DB_HOST: db
      DB_DATABASE: ${DB_DATABASE}
      DB_USERNAME: ${DB_USERNAME}
      DB_PASSWORD: ${DB_PASSWORD}
    ports:
      - "8089:8080"
      - "2345:2345"
    volumes:
      - ./go_api/source:/app
      - /app/bin
    stdin_open: true
    tty: true
    depends_on:
      db-init:
        condition: service_completed_successfully

volumes:
  db_data:
```

- **`name: learniken_compose_05`** — the Compose project name, prefixing container
  names, the default network, and the `db_data` volume.
- **`db`** — the SQL Server instance:
  - `ACCEPT_EULA` / `MSSQL_SA_PASSWORD` — required env vars for the official
    mssql image to start and set the `sa` password.
  - `ports: "1433:1433"` — exposes SQL Server to the host too (e.g. for a GUI
    client), not just to other containers.
  - `volumes: db_data:/var/opt/mssql` — named volume so database files persist
    across `down`/`up` (removed only with `down -v`).
  - `healthcheck` — periodically runs a trivial `sqlcmd` query so Compose can tell
    when the server is actually ready to accept connections, not just that the
    container process has started.
- **`db-init`** — a one-shot container that reuses the same SQL Server image purely
  for its `sqlcmd` client:
  - `depends_on: db: condition: service_healthy` — waits for `db`'s healthcheck to
    pass before starting, so the database is really up before running SQL.
  - `volumes: ./mssql/init:/init` — mounts the local `init.sql` into the container
    so `sqlcmd` can read it.
  - `entrypoint: [...]` — overrides the image's default entrypoint to run
    `sqlcmd -i /init/init.sql` against the `db` service (`-S db` resolves via
    Compose's internal DNS), passing `DBNAME` in as a `sqlcmd` scripting variable
    (`-v DBNAME=...`) referenced in `init.sql` as `$(DBNAME)`. The container exits
    once the script finishes.
- **`go-api`** — the API container:
  - `build.context: .` / `build.dockerfile: Dockerfile` — builds from the
    Dockerfile above, with the `Compose05` folder as context (hence `COPY
    go_api/source/...` paths inside the Dockerfile).
  - `environment` — `DB_HOST: db` lets the Go app connect to the `db` service by
    its Compose service name; the rest come from `.env`.
  - `ports: "8089:8080"` — the API listens on `:8080` inside the container
    (see `main.go`), reachable on the host at `http://localhost:8089`.
  - `ports: "2345:2345"` — Delve's default debug port, exposed to the host in case
    you want to attach a remote debugger from outside the container instead of
    attaching VS Code to the container itself (see "Debugging" below).
  - `volumes: ./go_api/source:/app` — bind-mounts the Go source over the image's
    copy, so edits on the host are immediately visible in the container.
  - `volumes: /app/bin` — an anonymous volume for `/app/bin`. This keeps the
    compiled binary (built by the `go: build` VS Code task, output to
    `${workspaceFolder}/bin/go_api`) inside the container's own filesystem layer
    instead of being hidden/overwritten by the bind mount above, and stops build
    output from leaking back onto the host.
  - `stdin_open` / `tty` — keeps the container's shell usable interactively and,
    combined with the Dockerfile's `tail -f /dev/null`, keeps it running so you can
    attach to it at any time.
  - `depends_on: db-init: condition: service_completed_successfully` — only starts
    `go-api` after `db-init` has finished successfully, guaranteeing the schema and
    seed data exist before the API tries to query them.

## Building and running

From the repo root:

```bash
# build images and start db, db-init, then go-api, in the background
docker compose -f Eksempler/Compose05/docker-compose.yml up -d --build
```

This brings up `db`, waits for its healthcheck, runs `db-init` to create the
schema/seed data, then starts `go-api` (which just idles via `tail -f /dev/null`
until you build/debug the program from VS Code — see below).

Quick sanity check that the seed data is there, without needing a SQL client:

```bash
./Eksempler/Compose05/select.sh      # macOS/Linux
Eksempler\Compose05\select.bat       # Windows
```

Try the API once it's actually running (see "Building and running in VS Code"
below to start it) with `Eksempler/Compose05/go_api/api.http` (needs the VS Code
REST Client / "Rest Client"-style `.http` support), or with `curl`:

```bash
curl http://localhost:8089/customers
```

Stop everything:

```bash
docker compose -f Eksempler/Compose05/docker-compose.yml down
```

## Building and running in VS Code

The `go-api` container only idles by default — the Go program itself is built and
started from inside VS Code once you're attached to the container (see
"Attaching to the running container" below). From the attached window, with
`/app` open as the folder:

- **Run the build task** — Command Palette → **Tasks: Run Build Task** (or
  `Cmd+Shift+B`/`Ctrl+Shift+B`) runs `go: build`, compiling `main.go` to
  `bin/go_api`.
- **Debug it** — press **F5** (see "The .vscode files" and "Debugging" below);
  this runs the build task first, then launches the compiled binary under Delve.
- **Run it without debugging** — `go run .` in the integrated terminal, or execute
  `./bin/go_api` after building.

## The .vscode files

These live in `go_api/source/.vscode/` and only take effect once that folder is
open as the workspace — normally after attaching to the running container (see
below), since that's where the Go toolchain and Delve are actually installed.

- **`extensions.json`** — recommended extensions for this folder. Currently empty
  (`recommendations: []`); the Go extension (`golang.go`) is expected to already be
  installed in the attached container context.
- **`settings.json`** — folder-scoped editor settings:
  - `go.useLanguageServer: true` — use `gopls` for IntelliSense/navigation.
  - `go.lintTool: golangci-lint` — linter used by the Go extension.
  - `go.formatTool: gofmt` — formatter run on save/format.
  - `go.toolsManagement.autoUpdate: true` — let the extension keep its helper
    tools (like `gopls`) up to date automatically.
- **`tasks.json`** — two shell tasks:
  - `go: build` (default build task) — runs
    `go build -o ${workspaceFolder}/bin/go_api ${workspaceFolder}`, with the `$go`
    problem matcher so compiler errors show up as VS Code diagnostics.
  - `go: vet` — runs `go vet ./...` to catch suspicious code without compiling.
- **`launch.json`** — one debug configuration, `Debug go_api`:
  - `type: go` / `request: launch` / `mode: auto` — the Go extension picks the
    right underlying Delve mode automatically for a normal program launch.
  - `program: ${workspaceFolder}` — debug the package in the workspace root
    (`main.go`).
  - `preLaunchTask: go: build` — always rebuild before debugging, so breakpoints
    match the binary that actually runs.

## Attaching to the running container

Because `go-api` just idles (`tail -f /dev/null`) and the Go toolchain/Delve only
exist inside that container, both running and debugging the API happen by
attaching VS Code to the already-running container — the same approach as the
Terminal01 example.

### 1. Install extensions

- **Dev Containers** (`ms-vscode-remote.remote-containers`) — lets VS Code attach
  to a running container.
- **Go** (`golang.go`) — install it once you're attached (step 2), since it needs
  to run inside the container where the Go toolchain and Delve live.

### 2. Attach to the running container

1. Make sure the stack is up: `docker compose -f Eksempler/Compose05/docker-compose.yml up -d --build`.
2. Command Palette → **Dev Containers: Attach to Running Container...**
3. Select `learniken_compose_05_go_api` (the container name set in
   `docker-compose.yml`, *not* the `go-api` service key).
4. A new VS Code window opens with its extension host running inside the
   container. Open `/app` as the folder — this is the bind-mounted
   `go_api/source`, so `.vscode/` is picked up automatically. Install the Go
   extension in this window if prompted.

### 3. Debug it

With `/app` open in the attached window:

1. Set a breakpoint in `main.go`.
2. Press **F5** (uses the `Debug go_api` configuration from `launch.json`).
3. VS Code runs the `go: build` task, then launches `bin/go_api` under Delve
   inside the container. Execution stops at your breakpoint with normal variable
   inspection, stepping, and call-stack views — no need to touch the `2345` port
   mapping, since the debugger and the debuggee are both running inside the same
   attached container.

Because `./go_api/source` is bind-mounted, edits made on the host are immediately
visible in the attached window too — no image rebuild needed between debug
sessions, just re-run F5 (which rebuilds via `preLaunchTask`).

The `2345:2345` port mapping in `docker-compose.yml` is there for the alternative
workflow of running Delve in headless server mode inside the container (e.g.
`dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient`) and
attaching a `request: attach, mode: remote` launch config from a host-side VS
Code window instead of using Dev Containers — not required for the F5 flow above.
