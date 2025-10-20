# Build stage
FROM ghcr.io/gohugoio/hugo:v0.151.2 AS builder

WORKDIR /hugo-site
COPY . .
RUN hugo --minify

# Production stage
FROM nginx:alpine

COPY --from=builder /src/public /usr/share/nginx/html

EXPOSE 80
