# CandidStudent Platform — Requirements and Micro-Frontend Architecture

---

# 1. Overview

CandidStudent is a university-integrated platform that allows students to create, manage, and showcase their projects, receive official university verification, and automatically generate professional portfolios.

The system consists of multiple micro-frontends connected to a centralized backend.

Core goals:

- Provide automated student portfolio generation
- Enable university project verification with badge levels
- Allow skill-based student discovery
- Integrate GitHub projects
- Provide engagement tracking similar to GitHub
- Enable university administrators to manage and verify student work

---

# 2. Micro-Frontend Architecture

The platform is split into multiple micro-frontends for scalability and separation of concerns.

## 2.1 /student — Student Platform

Purpose:
Primary dashboard for students.

Features:

- Authentication (login/register)
- Profile management
- GitHub OAuth integration
- Skills management (CRUD)
- Project management (CRUD)
- Mark project as university project
- Submit project for verification
- View verification status
- View verification badge level:
  - Poor
  - Medium
  - Satisfactory
- View engagement:
  - Who viewed project
  - Who verified project
  - Verification history

Project fields:

- title
- description
- technologies
- github_url
- demo_url
- is_university_project
- verification_status
- verification_badge_level

---

## 2.2 /portfolio — Portfolio Platform

Purpose:
Public-facing professional portfolios automatically generated from backend data.

Features:

- Public portfolio URL:
  /portfolio/{username}

- Multiple portfolio templates
- Display:
  - student profile
  - skills
  - projects
  - verification badges
  - GitHub projects

- Resume view:
  - printable resume
  - professional format
  - optional PDF export

- Portfolio themes:
  - template switching
  - responsive layouts

Portfolio loads data from main backend API.

---

## 2.3 /university — University Platform

Purpose:
Dashboard for university administrators and teachers.

Features:

- Manage students
- View all university projects
- Review verification requests
- Approve or reject projects
- Assign verification badge level:
  - Poor
  - Medium
  - Satisfactory

Verification rules:

- Only university projects can be verified
- Verifier must belong to same university
- Personal projects cannot be verified

---

## 2.4 /skills — Skill Discovery Platform

Purpose:
Skill-based student search system.

Features:

- Search students by:
  - skill name
  - skill level
  - university
  - verification badge level
  - verified projects only

- View student skill profiles
- View student projects
- View verified projects

Use cases:

- Universities discovering top students
- Employers discovering talent
- Skill analytics

---

## 2.5 /auth — Authentication Micro-Frontend

Purpose:
Centralized authentication interface.

Features:

- Login
- Register
- GitHub OAuth connect
- JWT token management
- Session management

---

# 3. Backend Integration

All micro-frontends connect to the main backend.

Backend responsibilities:

- Authentication
- RBAC authorization
- GitHub integration
- Project management
- Verification workflows
- Skills management
- Student search
- Portfolio data API

Backend acts as single source of truth.

---

# 4. Verification Badge System

University projects receive one of three levels:

Poor
- Minimal academic quality

Medium
- Acceptable academic quality

Satisfactory
- Strong academic quality

Stored fields:

- verification_status
- verification_badge_level
- verified_by
- verified_at

---

# 5. Portfolio System

Portfolio automatically generated from backend data.

Portfolio includes:

- profile
- skills
- verified projects
- GitHub projects
- resume view

No manual portfolio creation required.

---

# 6. GitHub Integration

Features:

- OAuth connection
- Import repositories
- Convert repos into projects
- Display GitHub projects in profile and portfolio

---

# 7. Engagement Tracking

System tracks:

- project views
- verification activity
- admin interactions

Students can view engagement dashboard.

---

# 8. Deployment Architecture

Micro-frontends:

- /student
- /portfolio
- /university
- /skills
- /auth

All connected to centralized backend.

---

# 9. Future Micro-Frontends (Optional)

/admin — platform administration
/analytics — skill analytics dashboard
/employers — employer discovery dashboard

---

# 10. Technology Stack Summary

Frontend:

- React + Vite
- React Query
- Zustand
- Zod
- Tailwind + ShadCN
- Feature-based architecture

Backend:

- NestJS
- Prisma
- PostgreSQL
- JWT + RBAC
- Argon2
- GitHub OAuth

Infrastructure:

- Docker
- AWS EC2
- AWS S3

---

# End of Document
