# DOX: docs/ -- Documentation Hub

## Purpose

Provide all user-facing and developer-facing documentation for Hound ELINT, including markdown guides, LDoc-generated HTML API docs, and the GitHub Pages deployment source.

## Ownership

This subtree owns all hand-written documentation (`.md` files), generated HTML docs (`web/` and `web/dev/`), and the LDoc configuration files at the repo root (`config_general.ld`, `config_developer.ld`).

## Local Contracts

- **Source of truth**: Hand-written markdown files in `docs/` root (24 files). These are maintained by the developer.
- **Generated docs**: `docs/web/` (public API HTML) and `docs/web/dev/` (developer API HTML) are built by LDoc via `config_general.ld` and `config_developer.ld`. Do not hand-edit generated files.
- **Reproducible builds**: Run `generate_docs.sh` (from `tools/`) to regenerate HTML docs from `src/` LDoc annotations.
- **Publishing**: `.github/workflows/deploy-pages.yml` deploys `docs/web/` to GitHub Pages on push to `main` that touches `docs/web/**`.
- **`docs/src/README_OLD.MD`**: Legacy readme preserved for reference.
- **LDoc configs at root**:
  - `config_general.ld` -- Public API docs (excludes internal/utility modules)
  - `config_developer.ld` -- Full internal docs (excludes only coroutine, mist shim, matrix, footer)

## Work Guidance

- Hand-written docs should be updated when public API changes.
- Generated HTML docs are rebuilt via `tools/generate_docs.sh` (which calls `ldoc .`).
- Use the `docs/` directory as the `--guides-dir` for `generate_md_docs.py`.
- Markdown docs use GitHub-flavored Markdown with fenced code blocks for examples.
- Keep the `llms.txt` at repo root in sync with available docs.

## Verification

- `luacheck` does not apply here. Verify markdown renders correctly on GitHub.
- LDoc configs must reference valid source file paths.
- GitHub Actions will fail if `docs/web/` has broken HTML.

## Child DOX Index

- `web/` -- Generated HTML documentation (public + developer API). Gitignored? No -- tracked for GitHub Pages. Do not hand-edit.
- `src/` -- Contains `README_OLD.MD` only, legacy preserve.
