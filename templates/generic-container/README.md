# generic-container

The initial PathOps Golden Path template.

It intentionally assumes no programming language or application framework:
the application is a static page served by BusyBox `httpd` (non-root, port
8080, `/healthz`), built from `.pathops/build/Dockerfile`. It scaffolds three
repositories:

```text
<app>
<app>-gitops-preflight
<app>-gitops-production
```

The source repository owns `.pathops/build/` and `.pathops/tekton/` (the
build-and-push Pipeline and its build-image Task, run by PathOps on every push
to `main`); preflight owns its GitOps desired
state plus `.pathops/deploy/` and `.pathops/tests/`; production owns its desired
state plus `.pathops/deploy/` and `.pathops/smoke/`.

Generated files are ordinary editable Docker/Tekton/Kubernetes/script files.
This template remains the generic escape hatch when no stack-specific PathOps
template exists.
