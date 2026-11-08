# .pathops/build

How this repository's application image is built. These are ordinary files:
edit them freely.

- `Dockerfile`: the image, built with the repository root as context. Files the
  build needs (server configuration, package-manager settings, public CA
  certificates, scripts) can live next to it in this directory. Never commit
  secrets or private keys here.

PathOps builds the image in the Cell's Tekton on every push to `main`, with
the Pipeline and Task in `../tekton/` (also yours to edit): the exact pushed
commit, rootless BuildKit, and a push to this Application's registry
repository tagged with the commit's first 12 characters. An existing tag is
never overwritten.
