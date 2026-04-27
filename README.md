# guest-book-deployment


A full-stack guestbook app built with **Spring Boot 3.2**, **Angular 17**, and **MySQL 8.0**, fully containerized with Docker and deployable to **Amazon EKS**.

## Architecture

```
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│   Angular 17 UI  │─────▶│  Spring Boot API  │─────▶│     MySQL 8.0    │
│   (Nginx :4200)  │ /api │    (Java :8080)   │ JDBC │    (DB :3306)    │
│                  │      │                    │      │                  │
│ • Glassmorphism  │      │ • REST + Pagination│      │ • Schema + Seed  │
│ • Dark Mode      │      │ • Search, Like, Pin│      │ • Persistent Vol │
│ • Toast Notifs   │      │ • Validation       │      │                  │
└──────────────────┘      └──────────────────┘      └──────────────────┘
  guestbook-ui ns           guestbook-api ns          guestbook-db ns
```

## Features

| Feature | Description |
|---------|-------------|
| 📝 CRUD | Create, read, update, delete guestbook entries |
| ❤️ Likes | Like entries with animated heart counter |
| 📌 Pin | Pin important entries to the top |
| 😊 Mood | Emoji mood selector (😊😍🎉👋🔥🤔😎💡) |
| 🔍 Search | Debounced search by name or message |
| 📊 Stats | Dashboard with total messages, today's count, total likes |
| 📄 Pagination | Server-side pagination |
| 🌙 Dark Mode | Toggle light/dark theme |
| 🔔 Toasts | Auto-dismissing success/error notifications |
| 🎨 Glassmorphism | Modern frosted glass UI with animations |
| 📱 Responsive | Mobile-friendly layout |

## Quick Start

```bash
cd sample-java-project
docker-compose up --build
```

Open http://localhost:4200 in your browser.

## Services

| Service | Directory | Port | Tech | Description |
|---------|-----------|------|------|-------------|
| UI | [guest-book-ui](./guest-book-ui/) | 4200 | Angular 17 + Nginx | SPA with glassmorphism design |
| API | [guest-book-api](./guest-book-api/) | 8080 | Spring Boot 3.2 + Java 17 | REST API with pagination & search |
| DB | [guest-book-backend](./guest-book-backend/) | 3306 | MySQL 8.0 | Database with schema & seed data |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/entries?page=0&size=10` | List entries (paginated, pinned first) |
| GET | `/api/entries?search=keyword` | Search by name or message |
| GET | `/api/entries/stats` | Get stats (total, today, likes) |
| POST | `/api/entries` | Create new entry |
| PUT | `/api/entries/{id}` | Update an entry |
| PATCH | `/api/entries/{id}/like` | Increment like count |
| PATCH | `/api/entries/{id}/pin` | Toggle pin status |
| DELETE | `/api/entries/{id}` | Delete an entry |

## Docker Images

```bash
# Build individually
docker build -t guestbook-db  ./guest-book-backend
docker build -t guestbook-api ./guest-book-api
docker build -t guestbook-ui  ./guest-book-ui
```

## Kubernetes (EKS) Deployment

Each microservice deploys to its own namespace with NetworkPolicies restricting cross-namespace traffic.

```
k8s/
├── base/
│   ├── namespaces.yaml        # guestbook-db, guestbook-api, guestbook-ui
│   └── network-policies.yaml  # Cross-namespace traffic rules
├── db/                        # StatefulSet + PVC + Secret + ConfigMap
├── api/                       # Deployment + HPA + Secret
├── ui/                        # Deployment + HPA + NLB Service + ConfigMap
└── deploy.sh                  # One-click build, push & deploy
```

```bash
# Deploy to EKS
chmod +x k8s/deploy.sh
./k8s/deploy.sh
```

Or manually:
```bash
kubectl apply -f k8s/base/namespaces.yaml
kubectl apply -f k8s/db/
kubectl apply -f k8s/base/network-policies.yaml
kubectl apply -f k8s/api/
kubectl apply -f k8s/ui/
```

## Stop

```bash
# Docker Compose
docker-compose down -v

# Kubernetes
kubectl delete -f k8s/ui/ -f k8s/api/ -f k8s/base/network-policies.yaml -f k8s/db/ -f k8s/base/namespaces.yaml
```

## Documentation

Each microservice has its own detailed README:

- [Guest Book API README](https://github.com/ajinkyajoshi/guest-book-api/blob/main/README.md) — API endpoints, data model, environment variables, sample responses
- [Guest Book Backend README](https://github.com/ajinkyajoshi/guest-book-backend/blob/main/README.md) — Schema, seed data, backup/restore, persistence
- [Guest Book UI README](https://github.com/ajinkyajoshi/guest-book-ui/blob/main/README.md) — Components, features, design system, nginx config
