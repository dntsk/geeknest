# Build stage
FROM ghcr.io/gohugoio/hugo:v0.151.2 AS builder

WORKDIR /site
COPY . .
USER root
RUN hugo --minify

# Production stage
FROM docker.angie.software/angie:latest

COPY --from=builder /site/public /usr/share/angie/html

EXPOSE 80
