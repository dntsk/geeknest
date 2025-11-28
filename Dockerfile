# Build stage
FROM ghcr.io/gohugoio/hugo:v0.151.2 AS builder

WORKDIR /site
COPY . .
USER root
RUN hugo --minify

# Pagefind indexing stage
FROM node:22-alpine AS indexer

# Install pagefind
RUN npm install -g pagefind

# Copy built site from builder
COPY --from=builder /site/public /site/public

# Run pagefind to create search index
WORKDIR /site
RUN pagefind --site public --output-subdir pagefind

# Production stage
FROM docker.angie.software/angie:latest

COPY --from=indexer /site/public /usr/share/angie/html

EXPOSE 80
