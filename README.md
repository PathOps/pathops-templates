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

Templates generate applications that satisfy the PathOps Technology Contract
while keeping application code independent from PathOps-internal products.
Tool-specific integration is supplied by generated CI/GitOps files and platform
configuration, not by requiring application code to depend on GitLab, Jenkins,
Harbor, Argo CD, Keycloak, or Loki APIs.

A target template scaffolds three user-owned repositories:

- **source**: application source/tests and `.pathops/build/` (editable Tekton
  build workflow, Dockerfile and any build-specific config/scripts);
- **preflight GitOps**: preflight desired state plus `.pathops/` workflows and
  environment tests owned by preflight;
- **production GitOps**: production desired state plus `.pathops/` workflows
  and smoke tests owned by production.

`.pathops/` is a transparent convention, not a proprietary pipeline DSL. The
generated Tekton/Kubernetes YAML, Dockerfiles and scripts are intentionally
visible and editable. PathOps supplies the execution engines and initial wiring;
the Application owns the generated workflows afterwards.

The first product template is intentionally technology-agnostic and proves the
container/GitOps contract with a minimal working application. Stack-specific
templates (Go, Spring Boot, Node.js, React/NGINX, etc.) are conveniences layered
on that contract, not the only technologies PathOps can support.

The current template catalog predates this target and is still evolving toward
it; existing templates are not yet evidence that the full contract is
implemented.

## Goals

- Reproducible application bootstrapping
- Opinionated DevOps golden paths
- GitOps-first workflows
- Technology-neutral minimum deployment contract
- Version-matched deployed verification tests
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
