#!/usr/bin/env bash
# Component tests of generic-container's update-preflight-gitops Task (its
# update step, Decision 0064): the step's own script, extracted from the Task,
# runs in the step's own pinned image (docker, no network, the step's user)
# over a Preflight GitOps repository rendered from the template, one fixture
# per case. No Cell, no git remote: checkout and push are not run here.
#
# usage: tests/update-preflight-gitops.sh      (or: make test)
set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TEMPLATE=$ROOT/templates/generic-container/gitops-preflight
TASK=$TEMPLATE/.pathops/tekton/tasks/update-preflight-gitops.yaml
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

IMAGE=$(python3 -I - "$TASK" <<'PY'
import sys, yaml
steps = {s["name"]: s for s in yaml.safe_load(open(sys.argv[1]))["spec"]["steps"]}
print(steps["update"]["image"])
PY
)
SRC=0123456789abcdef0123456789abcdef01234567
TAG=0123456789ab
DIGEST=sha256:1111111111111111111111111111111111111111111111111111111111111111
REPO=zot.cell.example/apps/6344ed5a-4373-4939-a4d7-c41f8a0d6e3e
REF=$REPO:$TAG@$DIGEST
WHOAMI=docker.io/traefik/whoami:v1.12.0@sha256:c4717a8d1f0134a7444e24f881160e033991f23027c6c5a9a3f8fd22e70d1d44
OLD=$REPO:aaaaaaaaaaaa@sha256:2222222222222222222222222222222222222222222222222222222222222222

PASSED=0 FAILED=0
pass() {
  PASSED=$((PASSED + 1))
  echo "PASS $1"
}
fail() {
  FAILED=$((FAILED + 1))
  echo "FAIL $1"
  [ -z "${2:-}" ] || sed 's/^/     | /' "$2"
}

# The update step's script with the Task's parameters of one run.
script() { # source-revision image-revision image-digest -> stdout
  python3 -I - "$TASK" "$1" "$2" "$3" "$REPO" <<'PY'
import sys, yaml
task, src, tag, digest, repo = sys.argv[1:]
steps = {s["name"]: s for s in yaml.safe_load(open(task))["spec"]["steps"]}
s = steps["update"]["script"]
for k, v in {"$(params.source-revision)": src, "$(params.image-revision)": tag, "$(params.image-digest)": digest,
             "$(params.image-repository)": repo, "$(results.image.path)": "/work/result-image"}.items():
    s = s.replace(k, v)
assert "$(params." not in s and "$(results." not in s, "an unknown Task variable"
print(s, end="")
PY
}

# A Preflight GitOps repository as the template generates it for hello.
fixture() { # dir
  mkdir -p "$1" && cp -R "$TEMPLATE" "$1/repo"
  find "$1/repo" -name '*.tmpl' | while read -r f; do
    sed -e 's/{{ app.name }}/hello/g' -e 's/{{ route.preflight.host }}/hello-preflight.cell.example/g' "$f" >"${f%.tmpl}"
    rm "$f"
  done
}

# Run the update step over dir/repo: exit status of the step; its output in dir/out.
run() { # dir [source-revision image-revision image-digest]
  script "${2:-$SRC}" "${3:-$TAG}" "${4:-$DIGEST}" >"$1/update.sh"
  chmod -R a+rwX "$1"
  docker run --rm --network none --user 65534:65532 -e HOME=/tmp -v "$1:/work" --entrypoint /bin/sh "$IMAGE" -c 'sh /work/update.sh; rc=$?; chmod -R a+rwX /work/repo /work/marked 2>/dev/null; exit $rc' >"$1/out" 2>&1
}

# rendered dir: the images the repository's desired state runs now
images() {
  docker run --rm --network none --user 65534:65532 -v "$1/repo:/r:ro" --entrypoint /app/kustomize "$IMAGE" build /r | sed -n 's/^[[:space:]-]*image:[[:space:]]*//p' | sort
}
export -f images
export IMAGE

expect_pass() { # name dir [extra check command...]
  local name=$1 d=$2
  shift 2
  if run "$d" && [ "$(cat "$d/result-image" 2>/dev/null)" = "$REF" ] && { [ $# -eq 0 ] || "$@"; }; then
    pass "$name"
  else
    fail "$name" "$d/out"
  fi
}
expect_fail() { # name dir message
  if run "$2"; then
    fail "$1: the update succeeded" "$2/out"
  elif ! grep -qF -- "$3" "$2/out"; then
    fail "$1: not refused for '$3'" "$2/out"
  elif [ -e "$2/result-image" ]; then
    fail "$1: an image result was written" "$2/out"
  else
    pass "$1"
  fi
}

workload() { # dir name image: a Deployment of that image (Pod Security restricted)
  cat >"$1/repo/$2.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: $2}
spec:
  selector: {matchLabels: {app.kubernetes.io/name: $2}}
  template:
    metadata: {labels: {app.kubernetes.io/name: $2}}
    spec:
      containers:
        - name: $2
          image: $3
EOF
  printf '  - %s.yaml\n' "$2" >>"$1/repo/kustomization.yaml"
}

docker image inspect "$IMAGE" >/dev/null 2>&1 || docker pull -q "$IMAGE" >/dev/null || {
  echo "FAIL the update step's image $IMAGE cannot be pulled"
  exit 1
}

# 1. One image: the template as generated; deployment.yaml joins the resources.
d=$T/single && fixture "$d"
expect_pass "one image: deployment.yaml joins the resources and the image app runs exactly the build's image" "$d" \
  bash -c '[ "$(images "$0")" = "$1" ] && grep -qx -- "- deployment.yaml" "$0/repo/kustomization.yaml"' "$d" "$REF"

# 2. More images: a workload of the user's own image is kept as it is.
d=$T/more-images && fixture "$d" && workload "$d" example "$WHOAMI" && cp "$d/repo/example.yaml" "$d/example.before"
expect_pass "several images: the image app is the build's; the user's whoami workload, its image and its file unchanged" "$d" \
  bash -c '[ "$(images "$0")" = "$(printf "%s\n%s\n" "$1" "$2" | sort)" ] && cmp -s "$0/repo/example.yaml" "$0/example.before"' "$d" "$REF" "$WHOAMI"

# 3. More workloads of the image app: every one runs the build's image.
d=$T/more-workloads && fixture "$d" && workload "$d" worker app
expect_pass "several workloads of the image app: both run the build's image" "$d" \
  bash -c '[ "$(images "$0")" = "$(printf "%s\n%s\n" "$1" "$1")" ] && grep -q "2 container(s) of the image app run" "$0/out"' "$d" "$REF"

# 4. Not updated: a patch of the repository pins the Deployment to an older build.
d=$T/not-updated && fixture "$d" && cat >>"$d/repo/kustomization.yaml" <<EOF
patches:
  - target: {kind: Deployment, name: hello}
    patch: |-
      - {op: replace, path: /spec/template/spec/containers/0/image, value: "$OLD"}
EOF
expect_fail "the image app not updated to the build's digest (a patch pins an older build)" "$d" "no container of the rendered desired state runs the image app"

# 5. The build's reference written by hand in another workload, the image app nowhere.
d=$T/foreign && fixture "$d" && sed -i "s#image: app#image: $REF#" "$d/repo/deployment.yaml"
expect_fail "the build's digest only in a workload that is not the image app's" "$d" "no container of the rendered desired state runs the image app"

# 6. No image app at all.
d=$T/none && fixture "$d" && sed -i "s#image: app#image: $WHOAMI#" "$d/repo/deployment.yaml"
expect_fail "no managed image in the desired state" "$d" "no container of the rendered desired state runs the image app"

# 7. Kustomize cannot render the desired state.
d=$T/broken && fixture "$d" && printf '  - missing.yaml\n' >>"$d/repo/kustomization.yaml"
expect_fail "a Kustomize rendering error" "$d" "missing.yaml"

# 8. The parameters stay checked.
d=$T/bad-source && fixture "$d"
if run "$d" 0123 "$TAG" "$DIGEST"; then fail "a short source revision is accepted" "$d/out"; elif grep -q "not a full source commit" "$d/out"; then pass "a source revision that is not a full commit is refused"; else fail "short source revision" "$d/out"; fi
d=$T/bad-tag && fixture "$d"
if run "$d" "$SRC" bbbbbbbbbbbb "$DIGEST"; then fail "a foreign image revision is accepted" "$d/out"; elif grep -q "is not the source commit's first 12 characters" "$d/out"; then pass "an image revision that is not the source commit's first 12 characters is refused"; else fail "foreign image revision" "$d/out"; fi
d=$T/bad-digest && fixture "$d"
if run "$d" "$SRC" "$TAG" latest; then fail "a digest that is not one is accepted" "$d/out"; elif grep -q "not an OCI digest" "$d/out"; then pass "an image digest that is not an OCI digest is refused"; else fail "bad digest" "$d/out"; fi

# 9. The step reads and writes the repository only: no Kubernetes client, API or credential.
if grep -Eq 'kubectl|KUBERNETES_SERVICE|serviceaccount|https?://' <(script "$SRC" "$TAG" "$DIGEST"); then
  fail "the update step names a Kubernetes client, API or URL"
else
  pass "the update step uses no Kubernetes client, API or URL"
fi

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" = 0 ]
