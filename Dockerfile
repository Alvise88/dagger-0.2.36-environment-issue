# syntax = docker/dockerfile:1.4

ARG FLAVOUR

FROM golang:1.19.4-${FLAVOUR} AS build
WORKDIR /src
RUN apk add --no-cache file git
ENV GOMODCACHE /root/.cache/gocache
RUN --mount=target=. --mount=target=/root/.cache,type=cache \
    CGO_ENABLED=0 go build -o /out/greeting -ldflags '-s -d -w' ./cmd/web; \
    file /out/greeting | grep "statically linked"

FROM scratch
COPY --from=build /out/greeting /bin/greeting
ENTRYPOINT ["/bin/greeting"]