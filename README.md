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

A target template provides, directly or through resolved adapters:

- application source and unit/component tests;
- application OCI image build definition;
- integration/regression test OCI image build definition;
- readiness/liveness behavior;
- stdout/stderr logging;
- a build/publish Jenkins pipeline;
- a GitOps-update Jenkins pipeline;
- Kubernetes desired-state templates for preflight/production and verification Jobs.

The current template catalog is still evolving toward this contract; not every
existing template implements every target element yet.

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
