FROM golang:latest

WORKDIR /app

RUN go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install golang.org/x/tools/gopls@latest \
    && go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest

CMD ["tail", "-f", "/dev/null"]
