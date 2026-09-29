FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ gdb curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://gh.io/copilot-install | bash
WORKDIR /app
CMD ["bash"]
