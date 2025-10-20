# Build stage
FROM klakegg/hugo:ext-alpine AS builder

WORKDIR /src
COPY . .
RUN hugo --minify

# Production stage
FROM nginx:alpine

COPY --from=builder /src/public /usr/share/nginx/html

EXPOSE 80
