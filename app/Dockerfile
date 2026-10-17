# syntax=docker/dockerfile:1
# Production image, used from session 1 onwards. Compare it with Dockerfile.naive in the session 1 lab.
# Session 10 pins both base images by digest so production builds exactly what was tested.
ARG BUILD_IMAGE=cgr.dev/chainguard/go:latest
ARG RUNTIME_IMAGE=cgr.dev/chainguard/static:latest

# Build stage: tests run here, so an image is only produced from code that passes them.
FROM ${BUILD_IMAGE} AS build
WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
ARG VERSION=dev
# No BuildKit-only features (cache or secret mounts): this file must build the same way with
# docker build on a laptop and with `az acr build` in session 2.
RUN go test ./... && \
    CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" -o /out/payments-api .

# Runtime stage: CA certificates, tzdata and a nonroot user. No shell, no package manager.
FROM ${RUNTIME_IMAGE}
COPY --from=build /out/payments-api /usr/bin/payments-api
# Numeric user: Kubernetes runAsNonRoot can verify a number, not a name.
USER 65532
EXPOSE 8080
ENTRYPOINT ["/usr/bin/payments-api"]
