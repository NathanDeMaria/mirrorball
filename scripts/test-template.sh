#!/usr/bin/env bash
# Render the template as a library and as an app, then run what a generated
# repo's CI runs on each. A template that renders a repo with a red `make
# check` or `make test` never gets tagged.
#
# Needs uv and copier on PATH. Uncommitted changes in this checkout are used --
# copier renders a dirty template from its working tree.
set -euo pipefail

template="$(cd "$(dirname "$0")/.." && pwd)"
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

# `package` is a library inside a bigger repo: no workflow of its own, since
# that repo's CI lives at its root.
for kind in library app package; do
    dest="$out/demo-$kind"
    echo "::group::$kind"
    ci=true; [ "$kind" = package ] && ci=false
    copier copy --defaults --quiet --vcs-ref HEAD \
        --data project_name="demo-$kind" --data kind="${kind/package/library}" \
        --data ci_workflow="$ci" \
        "$template" "$dest"
    if [ "$ci" = false ] && [ -n "$(ls -A "$dest/.github/workflows" 2>/dev/null)" ]; then
        echo "ci_workflow=false still rendered a workflow" >&2; exit 1
    fi
    (
        cd "$dest"
        git init --quiet
        uv lock --quiet
        uv sync --locked --quiet
        make check
        make test
    )
    echo "::endgroup::"
done
echo "template OK"
