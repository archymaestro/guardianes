# Stage 1: Build the application
FROM node:22-alpine AS builder

# Install pnpm globally
RUN npm i -g pnpm

WORKDIR /app

# Copy dependency files first to utilize Docker caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Install dependencies (frozen lockfile for reproducible builds)
RUN pnpm install --frozen-lockfile

# Copy the rest of the application files
COPY . .

# Build the Astro static site
RUN pnpm build

# Stage 2: Serve the static files using Nginx
FROM nginx:alpine

# Copy built static files to Nginx default folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
