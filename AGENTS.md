# Hound ELINT for DCS World

Radar detection and tracking for DCS World missions. Detects enemy radar emitters via ELINT platforms, triangulates positions, delivers intelligence via map markers, voice radio, and data exports.

- Agent must follow DOX instructions across any edits.

## Core Contract

- AGENTS.md files are binding work contracts for their subtrees.
- Work products, source materials, instructions, records, assets, and durable docs must stay understandable from the nearest applicable AGENTS.md plus every parent AGENTS.md above it.

## Read Before Editing

1. Read root AGENTS.md.
2. Identify every file/folder you expect to touch.
3. Walk from repo root to each target path.
4. Read every AGENTS.md along each route.
5. Parent-listed child AGENTS.md whose scope covers the path → read child, continue from there.
6. Nearest AGENTS.md = local contract; parent docs = repo-wide rules.
7. Conflict: closer doc controls local details; no child doc may weaken DOX.
8. Do not rely on memory — re-read the applicable DOX chain in-session before editing.

## Update After Editing

Every meaningful change requires a DOX pass before the task is done.

Update the closest owning AGENTS.md when a change affects:
- purpose, scope, ownership, responsibilities
- durable structure, contracts, workflows, operating rules
- required inputs, outputs, permissions, constraints, side effects, artifacts
- user preferences on behavior, communication, process, organization, quality
- AGENTS.md create/delete/move/rename, or index contents

Update parent docs on parent-level structure/ownership/workflow/child index changes. Update child docs when parent changes alter local rules. Remove stale or contradictory text immediately. Edits that change no behavior or contract leave docs unchanged; no write-up.

## Hierarchy

- Root AGENTS.md: repo-wide instructions, global preferences, durable workflow rules, top-level Child DOX Index.
- Child AGENTS.md: domain-specific instructions + own Child DOX Index.
- Parent states what each child covers and what stays owned by parent.
- Closer doc = more specific and practical.

## Child Doc Shape

- Create a child AGENTS.md when a folder becomes a durable boundary with its own purpose, rules, responsibilities, workflow, materials, or quality standards.
- Work Guidance: current project/user standards; empty if none.
- Verification: existing check; empty if none exists yet.
- Section order: Purpose, Ownership, Local Contracts, Work Guidance, Verification, Child DOX Index.

## Style

- Facts only. Current state only.
- No prose, no narrative, no history, no diary, no rationale.
- No change narration ("was", "now does", "recently", "currently").
- Document stable contracts, never events.
- Bullets > paragraphs. Explicit names > descriptions.
- Delete stale notes instead of explaining history.
- Trim obvious statements, repeated rules, misplaced detail, stale warnings.
- Duplicate rules only when each scope needs a local copy.
- No metaphors, no filler, no hedging.

## Closeout

1. Re-check changed paths against the DOX chain.
2. Update nearest owning docs and affected parents/children.
3. Refresh every affected Child DOX Index.
4. Remove stale or contradictory text.
5. Run existing verification when relevant.
6. List docs intentionally left unchanged.

## User Preferences

Durable user behavior changes → record here or in the relevant child AGENTS.md.

## Child DOX Index

| Path | Scope | Owner |
|------|-------|-------|
| `src/` | Core Lua source (36 files, numbered loading order) -- all runtime logic | Developer |
| `tools/` | Build tooling, doc generation scripts, DB validation, JSON export, test framework libs | Developer |
| `docs/` | Hand-written markdown guides, LDoc-generated HTML API docs, GitHub Pages source | Developer |
| `demo_mission/` | .miz demo missions, Lua mission scripts, unit test harness (luaunit) | Developer |
| `.ignore/` | Scratch/archive workspace, reference PDFs, third-party libs, backups (gitignored) | Developer |

### What stays owned by root

- Build orchestration: `hound_builder.sh` (concatenates `src/*.lua` → `include/HoundElint.lua`, strips debug, optional minify). Run `bash hound_builder.sh --compile` to rebuild.
- CI/CD: `.github/workflows/build.yml` compiles `include/HoundElint.lua` on push to `main` and on `v*` tags; on tag push it also creates a draft Release with the built file attached
- **Generated file**: `include/HoundElint.lua` is built by `hound_builder.sh` from `src/*.lua` — do not edit directly.
- LDoc configuration: `config_general.ld`, `config_developer.ld`
- Development loader: `HoundElint_devel.lua` (sequential source loading). Dev loop: edit `HoundWorkDir` in both `hound_loader.lua` + `HoundElint_devel.lua`, then `loadfile hound_loader.lua` from DCS mission to load individual `src/*.lua` files preserving per-file stack frames.
- Top-level API references: `HOUND_API_REFERENCE.md`, `DEVELOPER_API_REFERENCE.md`, `llm-integration-guide.md`, `llms.txt`
- GitHub metadata: `LICENSE`
- Project assets: `README.MD`, `images/`, `logo/` (gitignored), `include/DCS-SimpleTextToSpeech.lua` (TTS audio lib)
- IDE config: `.vscode/`, `.cursor/` (both gitignored)
- AI planning: `.claude/` (gitignored)
- **Testing requirement**: Every new function or functionality must include unit tests in `demo_mission/hound_unit_test/` unless testing is infeasible (e.g., depends on DCS runtime features that can't be mocked). Add tests under `demo_mission/hound_unit_test/extras/test-*.lua` following the patterns in `demo_mission/hound_unit_test/AGENTS.md`.