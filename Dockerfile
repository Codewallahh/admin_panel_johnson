# ---------- Build stage ----------
FROM node:20-alpine AS build
WORKDIR /app
 
# Use npm ci for reproducible builds (package-lock.json exists)
COPY package*.json ./
RUN npm ci
 
# Copy source and build
COPY . .
# If you need environment variables for Vite, pass them at build time:
# e.g. docker build --build-arg VITE_API_URL=/api -t your-image .
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}
RUN npm run build
 
# ---------- Run stage ----------
FROM nginx:alpine
 
# Clean default web root & copy build
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/dist /usr/share/nginx/html
 
# Nginx config for SPA routing + sensible caching
COPY nginx.conf /etc/nginx/conf.d/default.conf
 
# Optional: healthcheck (simple)
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -qO- http://localhost/ || exit 1
 
EXPOSE 2027
CMD ["nginx", "-g", "daemon off;"]