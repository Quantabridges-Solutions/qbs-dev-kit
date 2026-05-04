---
description: Docker + docker-compose conventions for local full-stack development
paths:
  - docker-compose*.yml
  - "**/Dockerfile"
---

# Docker Standards

## Service naming: `{project}-db`, `{project}-api`, `{project}-frontend`

## Healthchecks — always required
```yaml
# PostgreSQL
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U {project} -d {project}"]
  interval: 10s
  timeout: 5s
  retries: 5

# API
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:5075/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s
```

## Service dependency order
`db` (healthy) → `api` (healthy) → `frontend`

## Standard services
- `postgres:16-alpine` — port 5432
- `redis:7-alpine` — port 6379
- `rnwood/smtp4dev:v3` — port 5050 (web), 2525 (SMTP)
- API — port 5075
- Frontend (nginx) — port 3000

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
RUN npm i -g pnpm
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN pnpm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

## Never commit `.env` — use `.env.example` with placeholder values
