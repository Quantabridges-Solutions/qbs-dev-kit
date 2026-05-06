---
description: Docker + docker-compose conventions for local full-stack development
globs: docker-compose*.yml
alwaysApply: false
---

# Docker Standards

## Service naming
`{project}-db`, `{project}-api`, `{project}-frontend`, `{project}-smtp4dev`

## Standard docker-compose structure
```yaml
version: '3.9'

services:
  db:
    image: postgres:16-alpine
    container_name: {project}-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: {project}
      POSTGRES_USER: {project}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-DefaultPass123!}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U {project} -d {project}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - {project}-net

  api:
    build:
      context: ./src/backend
      dockerfile: Dockerfile
    container_name: {project}-api
    restart: unless-stopped
    environment:
      ConnectionStrings__DefaultConnection: "Host=db;Port=5432;Database={project};Username={project};Password=${DB_PASSWORD:-DefaultPass123!}"
      ASPNETCORE_ENVIRONMENT: Production
      ASPNETCORE_URLS: http://+:5075
    ports:
      - "5075:5075"
    depends_on:
      db:
        condition: service_healthy
    networks:
      - {project}-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5075/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  frontend:
    build:
      context: ./src/frontend
      dockerfile: Dockerfile
      args:
        VITE_API_URL: http://localhost:5075
    container_name: {project}-frontend
    restart: unless-stopped
    ports:
      - "3000:80"
    depends_on:
      api:
        condition: service_healthy
    networks:
      - {project}-net

volumes:
  postgres_data:
    driver: local

networks:
  {project}-net:
    driver: bridge
```

## API Dockerfile
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "{Project}.API.dll"]
```

## Frontend Dockerfile (Vite → Nginx)
```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm i -g pnpm && pnpm install --frozen-lockfile
COPY . .
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN pnpm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

## Development extras
- `smtp4dev` for local email capture (port 5050 web UI, 2525 SMTP)
- Redis on port 6379 when caching is needed
- Never commit `.env` — use `.env.example` with placeholder values
