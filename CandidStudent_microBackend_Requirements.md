# CandidStudent Backend — Architecture, Modules, Microservices, and API

---

# 1. Overview

The backend is the single source of truth for:

- authentication & authorization (JWT + RBAC)
- university / teacher / student management
- skills, projects, verification workflows
- GitHub OAuth + repo import
- portfolio public data API
- skill-based student search
- engagement tracking

Tech stack:

- NestJS (TypeScript)
- Prisma ORM
- PostgreSQL
- Zod validation
- Argon2 hashing
- JWT tokens + RBAC guards
- AWS S3 (media)
- Docker / Docker Compose (dev)
- AWS EC2 (dev/staging)

---

# 2. High-Level Backend Architecture

## 2.1 Modular Monolith (MVP)
Start as a modular monolith:

- One NestJS app
- Domain modules separated cleanly
- Shared database (Postgres)
- Shared auth layer

## 2.2 Microservice-ready (Phase 2)
Later split into services:

- Auth Service
- University Service
- Student Service
- Projects + Verification Service
- Search Service
- Portfolio Service
- GitHub Integration Service

Communication options:
- REST (simple)
- NATS/Kafka/RabbitMQ (events later)

---

# 3. RBAC Roles

Roles:
- SUPER_ADMIN
- UNIVERSITY_ADMIN
- TEACHER
- STUDENT

Core permissions:
- SUPER_ADMIN: create universities, assign university admins
- UNIVERSITY_ADMIN: manage teachers, verify university projects, manage students
- TEACHER: approve/reject verification requests (same university only)
- STUDENT: manage own profile/skills/projects; request verification for university projects only

---

# 4. Core Modules (NestJS)

## 4.1 AuthModule
Responsibilities:
- register/login
- password hashing (argon2)
- issue JWT access token (refresh token optional)
- guards + decorators for RBAC

Endpoints:
- POST /auth/register
- POST /auth/login
- POST /auth/refresh (optional)
- POST /auth/logout (optional)
- GET /auth/me

Validation:
- Zod schemas for request bodies

---

## 4.2 UniversitiesModule
Responsibilities:
- create university (SUPER_ADMIN)
- assign university admins (SUPER_ADMIN)
- manage university metadata

Endpoints:
- POST /universities (SUPER_ADMIN)
- GET /universities
- GET /universities/:id
- PATCH /universities/:id (UNIVERSITY_ADMIN/SUPER_ADMIN)

---

## 4.3 UsersModule / ProfilesModule
Responsibilities:
- manage users
- student profile data
- teacher/admin profiles

Endpoints:
- GET /users (admin)
- GET /users/:id (admin)
- PATCH /me (student/teacher/admin)

---

## 4.4 TeachersModule
Responsibilities:
- invite/create teachers under a university
- list teachers for student verification selection

Endpoints:
- POST /universities/:id/teachers (UNIVERSITY_ADMIN)
- GET /universities/:id/teachers (STUDENT)
- PATCH /teachers/:id (UNIVERSITY_ADMIN)
- DELETE /teachers/:id (UNIVERSITY_ADMIN)

---

## 4.5 SkillsModule
Responsibilities:
- skills CRUD for students
- skill level management

Skill levels:
- Beginner
- Intermediate
- Advanced
- Expert

Endpoints:
- POST /skills (STUDENT)
- GET /skills/me (STUDENT)
- PATCH /skills/:id (STUDENT owner)
- DELETE /skills/:id (STUDENT owner)

---

## 4.6 ProjectsModule
Responsibilities:
- project CRUD
- project tagging
- attach GitHub repo link
- mark project as personal/university project

Endpoints:
- POST /projects (STUDENT)
- GET /projects/me (STUDENT)
- GET /projects/:id (owner/admin)
- PATCH /projects/:id (owner)
- DELETE /projects/:id (owner)

Important fields:
- is_university_project (boolean)
- university_id (required if is_university_project=true)
- verification_status (none/pending/verified/rejected)
- verification_badge_level (poor/medium/satisfactory)

---

## 4.7 VerificationModule
Responsibilities:
- verification request creation
- approval/rejection
- enforce ownership-based verification rules
- assign badge level (poor/medium/satisfactory)

Endpoints:
- POST /projects/:id/request-verification (STUDENT)
- GET /verification-requests?status=pending (TEACHER/ADMIN)
- POST /verification-requests/:id/approve (TEACHER/ADMIN)
- POST /verification-requests/:id/reject (TEACHER/ADMIN)

Critical rules (must enforce):
- Only university projects can be verified
- reviewer.university_id must equal project.university_id
- personal projects cannot create verification requests
- approval must assign badge level: poor/medium/satisfactory

---

## 4.8 GitHubModule
Responsibilities:
- GitHub OAuth
- fetch repos
- import repos as platform projects
- optional scheduled sync

Endpoints:
- GET /github/connect (returns GitHub auth URL)
- GET /github/callback (OAuth exchange)
- GET /github/repos (returns repos list)
- POST /github/import (turn repos into projects)

Notes:
- Backend calls GitHub API using stored token
- Frontend never receives GitHub token

---

## 4.9 SearchModule
Responsibilities:
- search students by skills + project verification
- filtering and ranking
- used by /skills micro-frontend and portfolio discovery

Endpoints:
- GET /search/students?skills=React,NestJS&level=advanced&verified=true&badge=satisfactory&universityId=...

Ranking suggestion:
- verified project count (desc)
- badge level weight
- skill match count
- recency (optional)

---

## 4.10 PortfolioModule (Public API)
Responsibilities:
- provide public portfolio data for templates
- privacy-safe outputs
- resume view data

Endpoints:
- GET /public/portfolio/:username
- GET /public/portfolio/:username/resume
- GET /public/search (optional public search limited)

Privacy rules:
- do NOT expose emails, tokens, internal audit fields
- show verifier identity only if project verified

---

## 4.11 EngagementModule (GitHub-like interest tracking)
Responsibilities:
- track who viewed project
- track admin/teacher interest
- list interested users

Endpoints:
- POST /projects/:id/view (record view)
- GET /projects/:id/engagement (owner)
- GET /me/notifications (owner)

Data tracked:
- viewer_id
- project_id
- timestamp
- action_type (view/verify/comment/request)

---

# 5. Data Layer Integration

- PostgreSQL + Prisma
- use migrations for schema changes
- indexes for:
  - skills.name
  - users.university_id
  - projects.student_id
  - projects.verification_status
  - projects.verification_badge_level

Media:
- store in AWS S3
- DB stores `s3_key` and metadata
- use presigned URLs for upload/download

---

# 6. Validation Strategy (Zod)

Validation points:
- incoming request body validation in controllers
- response contract validation (optional but strong)
- frontend shares schemas where possible (monorepo advantage)

---

# 7. Development & Deployment

Local dev:
- Docker Compose:
  - api
  - postgres
  - optional redis/worker

Cloud dev/staging:
- AWS EC2
- run docker compose
- optional Nginx reverse proxy for HTTPS

---

# 8. Future Event-Driven Design (Optional)

Emit events when:
- project created
- verification approved
- student skills updated
- GitHub sync completed

These events can power:
- analytics
- notifications
- search indexing

---
# End of Document
