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

for kind in library app; do
    dest="$out/demo-$kind"
    echo "::group::$kind"
    copier copy --defaults --quiet --vcs-ref HEAD \
        --data project_name="demo-$kind" --data kind="$kind" \
        "$template" "$dest"
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
