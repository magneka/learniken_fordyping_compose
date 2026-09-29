FROM golang:latest

WORKDIR /app

RUN go install github.com/go-delve/delve/cmd/dlv@latest

COPY go_api/source/go.mod ./
RUN go mod tidy

COPY go_api/source/ .

CMD ["tail", "-f", "/dev/null"]
