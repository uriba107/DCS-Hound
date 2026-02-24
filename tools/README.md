# Hound Documentation Tools

This directory contains tools for generating Hound documentation from source code.

## Installation

Install required Python packages:

```bash
pip3 install -r requirements.txt
```

On macOS with externally-managed Python:

```bash
pip3 install --break-system-packages -r requirements.txt
```

## generate_md_docs.py

Generates AI-optimized Markdown documentation from LDOC comments in Lua source files.

### Usage

**Generate all documentation (requires Ollama running):**

```bash
# Default model (qwen3:4b)
python3 generate_md_docs.py

# Large model (qwen3:14b) - better quality, slower
python3 generate_md_docs.py --use-large-model

# Custom model with explicit context window
python3 generate_md_docs.py --llm-model "qwen3:8b" --llm-context 32768
```

**Generate only API reference files (no Ollama needed):**

```bash
python3 generate_md_docs.py --skip-integration-guide
```

### Requirements

- **Python 3** with packages from `requirements.txt`
- **Ollama** installed and running (unless `--skip-integration-guide`): https://ollama.ai/
  ```bash
  ollama pull qwen3:4b              # Default (fast)
  ollama pull qwen3:14b             # Large model (better quality)
  ollama serve
  ```

### Output

- `docs/HOUND_API_REFERENCE.md` - Public API documentation
- `docs/dev/DEVELOPER_API_REFERENCE.md` - Full developer documentation
- `docs/README/llm-integration-guide.md` - Self-contained LLM integration guide with categorized API reference and validated examples

### Options

| Option                     | Description                                             |
| -------------------------- | ------------------------------------------------------- |
| `--src-dir PATH`           | Source directory (default: `../src`)                    |
| `--public-output-dir PATH` | Public docs output (default: `../docs`)                 |
| `--dev-output-dir PATH`    | Developer docs output (default: `../docs/dev`)          |
| `--skip-integration-guide` | Skip LLM integration guide (only API reference files)   |
| `--llm-model MODEL`        | Ollama model to use (default: `qwen3:4b`)               |
| `--llm-context N`          | Context window size for Ollama (default: model default) |
| `--llm-timeout N`          | Timeout per LLM call in seconds (default: 300)          |
| `--use-large-model`        | Use `qwen3:14b` for better quality                      |
| `--verbose`, `-v`          | Enable verbose logging                                  |

## Notes

- By default the script generates all docs including the LLM integration guide
- Use `--skip-integration-guide` if Ollama is not available
- The guide uses freshly-generated API docs (in-memory) as primary context for accuracy
- Developer/internal functions are documented separately in `docs/dev/`
- LLM timeout: 300s default, configurable via `--llm-timeout`
