FROM golang:1.24.1-alpine AS builder

ARG username="appuser"
ARG unique_id=3125

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download && \
    adduser \
            --disabled-password \
            --gecos "" \
            --home "/nonexistent" \
            --shell "/sbin/nologin" \
            --no-create-home \
            --uid "${unique_id}" \
            "${username}"

COPY --chown=${username}:${username} . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o main main.go

FROM gcr.io/distroless/static-debian12 AS final

ARG username

# Set environment variables (can be overridden during runtime)
ENV PORT="8080" \
    MYSQL_USER= \
    MYSQL_PASSWORD= \
    MYSQL_HOST= \
    MYSQL_PORT= \
    MYSQL_DATABASE= \
    REDIS_HOST= \
    REDIS_USERNAME= \
    REDIS_TLS= \
    REDIS_PASSWORD=

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /app

USER root

# Copy application files with correct ownership
COPY --chown=${username}:${username} --from=builder /app/main .

# Expose the necessary port
EXPOSE ${PORT}

# Use an unprivileged user.
USER ${username}:${username}

# Command to run the application
ENTRYPOINT ["/app/main"]
