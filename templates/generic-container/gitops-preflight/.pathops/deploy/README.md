# .pathops/deploy

How the preflight environment is deployed from this repository (PathOps
Decision 0064). These are ordinary files of this repository: edit them freely.

```text
push to the source repository
  -> PathOps builds the image <registry>/apps/<id>:<revision>@<digest>
  -> PathOps runs .pathops/tekton/pipelines/update-preflight-gitops.yaml
     (resolved from this repository at its current exact commit): its Task
     writes that image into this repository and pushes one commit
  -> Flux applies the Kustomization at the repository root to the namespace
     <app>-preflight, at exactly that commit
```

`ingress.yaml` exposes the Application at its default Route's Preflight
hostname (Decision 0067), e.g. `<route>-preflight-<cell>.<domain>`: PathOps
reserved it for this Application and the Cell admits an Ingress here only
with hostnames of this Application's Routes for Preflight. More public names
are more Routes (`pathops -a <app> create route <name>`); a Service of this
namespace (a database, say) needs none: Kubernetes Service DNS reaches it.

Until the first build only `service.yaml` and `ingress.yaml` are deployed: `deployment.yaml` is
added to `kustomization.yaml` by the first update, together with the build's
exact image, so the environment never runs a placeholder image. The
Deployment runs as the ServiceAccount `<app>-runtime`, which PathOps
provisions and authorizes to pull exactly this Application's image.

The update Task owns how the desired state changes (here `kustomize edit set
image`); PathOps only gives it the build's image identity and a write deploy
key of this repository, and waits for Flux to apply the commit it returns.

The desired state may hold more workloads and images than the Application's:
another Deployment, Service or Ingress (for another Route), with images of
your own. The update sets only the image `app` (the `images` entry of
`kustomization.yaml`): every container whose image is `app`, in any workload,
runs the build's exact image afterwards, and there must be one at least; any
other image and file stays as you wrote it. The update checks it by rendering
the desired state; it is a consistency check, not a security boundary (the
Cell's admission protects the runtime). Flux applies the whole repository and
the Deployment waits for all of it: a workload of yours that does not become
ready fails the next Deployment too. A push of yours to this repository is
applied by Flux on its own (it polls `main`), with no Delivery or Deployment
in PathOps.
