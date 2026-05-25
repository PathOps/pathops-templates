# PathOps Templates

Official application templates for PathOps.

This repository contains reusable application templates used by the PathOps platform to bootstrap new applications and environments.

Templates are organized by technology stack and deployment model, for example:

- React + NGINX
- Spring Boot
- Node.js
- Python
- GitOps-ready applications
- CI/CD bootstrap templates

Each template is designed to work with the PathOps ecosystem, including:

- GitLab
- Jenkins
- Harbor
- Argo CD
- Kubernetes

## Goals

- Reproducible application bootstrapping
- Opinionated DevOps golden paths
- GitOps-first workflows
- Safe production evolution
- AI-assisted operational workflows

## Template Structure

```text
templates/
  react-nginx/
  spring-boot/
  nodejs/
```

Each template is versioned through Git tags and referenced by the PathOps Control Plane using:

* templateId
* templateRef
* templateCommitSha

This allows fully reproducible application generation.
