# .pathops/build

How this repository's application image is built. These are ordinary files:
edit them freely.

- `Dockerfile`: the image, built with the repository root as context. Files the
  build needs (server configuration, package-manager settings, public CA
  certificates, scripts) can live next to it in this directory. Never commit
  secrets or private keys here.

PathOps runs the build in the Cell's Tekton from this directory. The build
workflow files are added here by a later PathOps release; until then, nothing
builds automatically.
