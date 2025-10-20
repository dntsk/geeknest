# Build stage
FROM ghcr.io/gohugoio/hugo:v0.151.2 AS builder

WORKDIR /src
COPY . .
RUN chmod -R u+w /src
RUN hugo --minify

# Production stage
FROM nginx:alpine

COPY --from=builder /src/public /usr/share/nginx/html

EXPOSE 80
