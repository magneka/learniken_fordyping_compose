# Docker Compose Syntax

## CLI commands

- `docker compose up` — create and start all services.
- `docker compose up -d` — same, but detached (runs in the background).
- `docker compose up --build` — rebuild images before starting.
- `docker compose down` — stop and remove containers, networks (keeps images/volumes).
- `docker compose down -v` — also remove named volumes.
- `docker compose build` — build/rebuild service images without starting them.
- `docker compose start` / `stop` — start/stop existing containers without recreating them.
- `docker compose restart` — restart running services.
- `docker compose ps` — list containers managed by the compose file.
- `docker compose logs` — show container logs.
- `docker compose logs -f` — follow (stream) logs.
- `docker compose exec <service> <cmd>` — run a command inside a running container.
- `docker compose config` — validate and print the resolved compose file.

## compose.yaml keys

- `name:` — project name (prefixes container/network names).
- `services:` — top-level map of containers to run.
- `build:` — how to build the image (`context`, `dockerfile`).
- `image:` — use an existing image instead of building.
- `container_name:` — fixed name for the container (instead of auto-generated).
- `ports:` — host:container port mappings, e.g. `"8085:8080"`.
- `environment:` — environment variables passed into the container.
- `env_file:` — load environment variables from a `.env` file.
- `volumes:` — mount host paths or named volumes into the container.
- `depends_on:` — start order between services.
- `networks:` — attach the service to custom networks.
- `restart:` — restart policy, e.g. `no`, `always`, `on-failure`.

## Ways of using volumes

- **Named volume** — Docker-managed storage, persists after `down` (removed only with `down -v`).
  ```yaml
  services:
    db:
      volumes:
        - dbdata:/var/lib/data
  volumes:
    dbdata:
  ```
- **Bind mount** — maps a host path directly into the container; good for local dev (live code reload).
  ```yaml
  services:
    api:
      volumes:
        - ./source:/app
  ```
- **Anonymous volume** — no name, no host path; Docker generates one. Rarely used on purpose, mostly created implicitly.
  ```yaml
  services:
    api:
      volumes:
        - /app/bin
  ```
- **Read-only mount** — append `:ro` to prevent the container from writing to the mounted path.
  ```yaml
  services:
    api:
      volumes:
        - ./config:/app/config:ro
  ```
- **Short vs long syntax** — the `host:container[:mode]` form above is shorthand; the long form allows extra options:
  ```yaml
  services:
    api:
      volumes:
        - type: bind
          source: ./source
          target: /app
          read_only: true
  ```

## Using .env files and environment variables

- **Root `.env` file** — a file named `.env` next to `compose.yaml` is loaded automatically and can substitute variables inside the compose file itself (e.g. `${TAG}`, `${PORT}`).
  ```
  # .env
  PORT=8085
  TAG=1.0
  ```
  ```yaml
  services:
    api:
      image: myapi:${TAG}
      ports:
        - "${PORT}:8080"
  ```
- **`environment:`** — set container environment variables directly, or reference host/compose variables.
  ```yaml
  services:
    api:
      environment:
        - ASPNETCORE_ENVIRONMENT=Development
        - ConnectionStrings__Default=${DB_CONNECTION}
  ```
- **`env_file:`** — load a whole file of `KEY=VALUE` pairs into the container's environment (separate from the root `.env` used for variable substitution).
  ```yaml
  services:
    api:
      env_file:
        - .env.api
  ```
- **Default values** — use `${VAR:-default}` in the compose file so it still works if the variable isn't set.
  ```yaml
  services:
    api:
      ports:
        - "${PORT:-8080}:8080"
  ```
- **Precedence** — `environment:` (or a shell-exported variable) overrides values loaded via `env_file:`, which overrides variables baked into the image.

## Mapping folders

- **Build context** — `build.context` points at the folder containing the Dockerfile (and everything sent to the Docker daemon during build); `build.dockerfile` names the file if it isn't `Dockerfile`.
  ```yaml
  services:
    api:
      build:
        context: ./source/CustomerApi
        dockerfile: Dockerfile
  ```
- **Runtime folder mapping (bind mount)** — `volumes:` maps a host folder into the running container at a given path, using `./relative/path:/container/path`. Paths are relative to the compose file's location.
  ```yaml
  services:
    mysql:
      volumes:
        - ./databaseinit:/docker-entrypoint-initdb.d
  ```
- **Named volume folder** — instead of a host path, map a Docker-managed volume to a folder inside the container (see "Ways of using volumes" above); useful when you don't need to browse the files from the host.
  ```yaml
  services:
    mysql:
      volumes:
        - learniken_compose_mysql:/var/lib/mysql
  volumes:
    learniken_compose_mysql:
  ```
- **Multiple folder mappings** — a service can list several volume entries to map more than one folder at once.
  ```yaml
  services:
    api:
      volumes:
        - ./source:/app
        - ./logs:/app/logs
  ```
