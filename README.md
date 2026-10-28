# mirrorball

The [copier](https://copier.readthedocs.io/) template behind my Python repos,
and the script that keeps them in step with it.

What a generated repo gets:

- **Python 3.15** in the devcontainer and CI. Libraries declare
  `requires-python >= 3.14`, one behind, so they never ask a consumer for a
  newer interpreter than it runs; apps declare 3.15.
- **[uv](https://docs.astral.sh/uv/)**: `[project]` metadata, a `dev`
  dependency group, a committed `uv.lock`, hatchling to build.
- **[ruff](https://docs.astral.sh/ruff/)** for formatting and linting
  (defaults + `I` + `UP`), **[ty](https://docs.astral.sh/ty/)** for types with
  warnings treated as errors, **pytest** in strict mode.
- `make check` / `make lint` / `make test`, and a CI workflow with one job,
  `ci`, that runs `uv sync --locked`, `make check` and `make test`. The branch
  ruleset requires `ci`, so nothing red merges.
- A devcontainer: non-root `dev` user (uid 1000), pinned uv, gh, AWS CLI
  (optional) and Claude Code, ruff and ty in VS Code.

Every version above is set once, in `copier.yaml`.

## New repo

```
uvx copier copy gh:NathanDeMaria/mirrorball my-repo
cd my-repo && git init && uv lock
```

## Who owns what

`copier update` re-applies template changes with a three-way merge, so a repo
can edit template files and keep its edits. It goes smoothest when repo-specific
things live where the template doesn't:

| Template-owned (updated) | Repo-owned (created once, never updated) |
|---|---|
| `Makefile` (includes `project.mk`) | `project.mk`: the repo's own targets |
| `.github/workflows/ci.yml` | any other workflow |
| `.devcontainer/*` | a runtime `Dockerfile` for repos that ship an image |
| tool sections of `pyproject.toml` | its dependencies |
| `.python-version`, `.gitignore`, `.dockerignore` | `README.md`, the package code |

## Releasing a change to every repo

1. Change the template; `make test` renders a library and an app and runs
   their checks (CI also builds the devcontainer).
2. Merge, then tag: `git tag v1.1.0 && git push --tags`.
3. `make propagate` opens an "Update to mirrorball v1.1.0" PR in every repo in
   `repos.txt`. Conflicts stay inline and the PR opens as a draft listing them;
   the repo's `ci` fails until they're resolved. `make propagate DRY_RUN=1`
   shows the diffs first.

## Adopting the template in an existing repo

```
uvx copier copy --overwrite gh:NathanDeMaria/mirrorball .
git diff   # put back anything repo-specific the template overwrote
```

then add the repo to `repos.txt`.
