# Build stage
FROM ghcr.io/gohugoio/hugo:v0.151.2 AS builder

WORKDIR /site
COPY . .
RUN chmod -R u+w /site
RUN hugo --minify

# Production stage
FROM docker.angie.software/angie:latest

COPY --from=builder /src/public /usr/share/nginx/html

EXPOSE 80
