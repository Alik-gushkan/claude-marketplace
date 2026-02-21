# claude-marketplace

Plugin marketplace for Claude Code. Contains plugins in `plugins/` and a CI workflow to validate them.

## Architecture

```
claude-marketplace/
  .claude-plugin/plugin.json   # Marketplace-level manifest (name: "alik-plugins")
  .github/workflows/           # CI: validates plugin structure on push/PR
  plugins/
    dev-toolkit/               # Showcase plugin — all component types
      .claude-plugin/plugin.json
      skills/                  # SKILL.md files (auto-discovered)
      commands/                # Command markdown (auto-discovered)
      agents/                  # Agent markdown (auto-discovered)
      hooks/hooks.json         # Hook event config → references scripts/
      scripts/                 # Bash scripts for hooks (must be chmod +x)
```

## Plugin Component Formats

### Skills (`plugins/*/skills/<name>/SKILL.md`)
- YAML frontmatter: `description` (trigger phrases), `argument-hint`, `allowed-tools`
- Body: imperative instructions for Claude, NOT user-facing docs
- `$ARGUMENTS`, `$1`, `$2` for argument substitution

### Commands (`plugins/*/commands/<name>.md`)
- YAML frontmatter: `description`, `argument-hint`, `allowed-tools`
- Same format as skills — creates `/plugin:command` slash commands

### Agents (`plugins/*/agents/<name>.md`)
- YAML frontmatter: `name`, `description` (when to invoke), `tools`, `model`, `color`
- Body: system prompt defining agent role and behavior
- Runs in isolated context window (separate from main conversation)

### Hooks (`plugins/*/hooks/hooks.json`)
- Events: `PreToolUse`, `PostToolUse`, `SessionStart`, `Stop`, etc.
- Matcher: tool name regex (e.g., `"Bash"`, `"Write|Edit"`)
- Hook types: `command` (shell), `prompt` (LLM), `agent` (subagent)
- Scripts receive JSON on stdin, return JSON on stdout
- Use `${CLAUDE_PLUGIN_ROOT}` for portable paths — never hardcode absolute paths

### Manifest (`plugins/*/.claude-plugin/plugin.json`)
- Required: `name` (kebab-case)
- Recommended: `version` (semver), `description`, `author`, `keywords`
- Component paths are optional — standard directories are auto-discovered

## Key Conventions

- Plugin names: kebab-case (`dev-toolkit`, not `devToolkit`)
- All hook scripts must have `#!/usr/bin/env bash` shebang and be executable
- Hook scripts should use `set -euo pipefail` and parse stdin JSON with `jq`
- Skill descriptions must be third-person with trigger phrases for intent matching
- Agent descriptions should include "Use this agent when..." phrasing
- `${CLAUDE_PLUGIN_ROOT}` resolves to the plugin's root directory at runtime

## Adding a New Plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json` with at least `name` and `version`
2. Add components in standard directories (`skills/`, `commands/`, `agents/`, `hooks/`)
3. Add `README.md` with usage docs
4. CI validates structure automatically on push

## Validation

The GitHub Actions workflow (`validate.yml`) checks:
- `plugin.json` exists and is valid JSON with required `name` field
- `hooks.json` is valid JSON if present
- Scripts in `scripts/` are executable
- Reports component counts per plugin

## Gotchas

- Hook scripts that aren't executable (`chmod +x`) will fail silently
- `jq` is required by hook scripts — document as a dependency
- PreToolUse hooks returning `"decision": "block"` will **prevent** the tool from running — use `"ask"` for advisory warnings
- PostToolUse hooks run **after** the tool succeeds — they don't see failed operations
- Agent `model` field accepts aliases only: `sonnet`, `opus`, `haiku`, `inherit` — not full model IDs
- Marketplace-level `plugin.json` (root) is separate from individual plugin manifests
