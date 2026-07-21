# DOX: tools/ -- Build Tooling & Documentation Generation

## Purpose

Provide scripts and utilities for building Hound ELINT, generating documentation, validating databases, and exporting data.

## Ownership

This subtree owns all developer tooling that processes source code into deliverables: the build pipeline, doc generation, DB validation, and JSON export.

## Local Contracts

- **`hound_builder.sh`** (at repo root, references tools/): The primary build script. Concatenates and minifies `src/` into `include/HoundElint.lua`.

  | Flag | What it does |
  |------|-------------|
  | `-t` | Lint `src/*.lua` + DB validation |
  | `-c` | Compile → `include/HoundElint.lua`, then lint result |
  | `-c --minify` | Also produce `include/minified/HoundElint_.lua` (luasrcdiet) |
  | `-d` | Build LDoc HTML docs (public → `docs/web/`, dev → `docs/web/dev/`) |
  | `-m` | Rebuild demo `.miz` files |
  | `--release` | Compile + docs + missions, strips `-TRUNK` version suffix |
  | `--all` | Lint + docs + compile + missions |

- **`generate_md_docs.py`**: Generates `HOUND_API_REFERENCE.md`, `DEVELOPER_API_REFERENCE.md`, and `llm-integration-guide.md` from LDoc-annotated source. Requires Ollama for the LLM integration guide.
- **`validate_db.lua` / `validate_db.sh`**: Validate DCS unit databases for correctness.
- **`hound_json_export.lua`**: Export contact data to JSON.
- **`parse_dcs-lua-datamine_for_hound.lua`**: Parse DCS datamine output into Hound DB format.
- **`testing/`**: Contains `luaunit.lua` test framework used by `demo_mission/hound_unit_test/`.
- **`requirements.txt`**: Python dependencies for doc generation (`mistune`, `markdown`, `pyyaml`).
- **`generate_docs.sh`**: Shell wrapper for the LDoc-based HTML documentation generation.
- **`__pycache__/`**: Python bytecode cache, gitignored.

### Lint

- `luacheck -g --no-self --no-max-line-length src/<file>.lua`
- `.luacheckrc` silences all warning classes **except** whitespace and warnings `011`/`511` — lint is a syntax/undefined-call gate, not style enforcement.

### Compile-Time Stripping

The following are removed during `hound_builder.sh -c`:
- `StopWatch` / `:Stop()` lines
- `HOUND.Logger.trace("` lines
- `--` comment lines
- `DEBUG = true` flipped to `false`
- `-TRUNK` version suffix rewritten

Do not put logic on these lines — they are eliminated at compile.

## Work Guidance

- Python doc generation scripts must remain compatible with Python 3.10+.
- When adding new source files to `src/`, update doc generation file lists if needed.
- Keep `requirements.txt` minimal.
- Scripts should work on both macOS and Linux (see `hound_builder.sh` for platform detection patterns).

## Verification

- `generate_md_docs.py --skip-integration-guide` runs without Ollama, verifies LDoc parsing.
- `validate_db.sh` validates DB integrity.
- Python scripts pass `ruff` linting (no CI config yet; run manually).

## Child DOX Index

- `testing/` -- Contains `luaunit.lua` and `StopWatch.lua` test utilities. No durable boundary warranting its own AGENTS.md; referenced from `demo_mission/`.
