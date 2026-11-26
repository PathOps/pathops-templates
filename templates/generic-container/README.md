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
state plus `.pathops/tekton/` (the update-preflight-gitops Pipeline and Task,
run by PathOps after each successful build to set the build's exact image),
`.pathops/deploy/` and `.pathops/tests/`; production owns its desired state
plus `.pathops/deploy/` and `.pathops/smoke/`.

Preflight starts Flux-safe: its Kustomization deploys only the Service until
the first update adds `deployment.yaml` with the build's exact
`<repository>:<revision>@<digest>` (the Deployment's image is the logical name
`app` until then and never runs). The Deployment runs as `<app>-runtime`, the
Preflight runtime identity PathOps provisions. The update sets only the image
`app`: other workloads and images of the repository are the user's and stay
as they are (`gitops-preflight/.pathops/deploy/README.md`).

Generated files are ordinary editable Docker/Tekton/Kubernetes/script files.
This template remains the generic escape hatch when no stack-specific PathOps
template exists.
