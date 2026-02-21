# dev-toolkit

A developer utility plugin for [Claude Code](https://claude.com/claude-code) that bundles practical daily-use tools while showcasing all major plugin component types.

## Components

| Type | Name | What it does |
|------|------|-------------|
| Skill | `quick-context` | Summarizes a project's tech stack, structure, key files, and recent changes |
| Command | `scaffold` | Generates boilerplate for components, routes, tests, hooks, models, services, middleware |
| Agent | `code-explainer` | Produces detailed code explanations with data flow diagrams and complexity analysis |
| Hook (Pre) | `pre-commit-check` | Warns when committing without test files staged |
| Hook (Post) | `auto-format` | Runs the project's formatter after file writes/edits |

## Installation

### From marketplace

```bash
# Add the marketplace (one-time)
claude /plugin marketplace add alikgushkan/claude-marketplace

# Install the plugin
claude /plugin install dev-toolkit@alik-plugins
```

### Local development

```bash
git clone https://github.com/alikgushkan/claude-marketplace.git
claude --plugin-dir ./claude-marketplace/plugins/dev-toolkit
```

## Usage

### Quick Context

Ask Claude to summarize your project:

```
> give me quick context on this project
> what's the tech stack here?
> summarize this codebase
```

Or invoke directly:

```
> /dev-toolkit:quick-context ./src
```

### Scaffold

Generate boilerplate files:

```
> /scaffold component UserProfile
> /scaffold route auth --path src/api
> /scaffold test PaymentService
```

Available types: `component`, `route`, `test`, `hook`, `model`, `service`, `middleware`

### Code Explainer

Ask Claude to explain code in detail:

```
> explain how the authentication middleware works
> walk me through src/lib/parser.ts
> what does the handleWebSocket function do?
```

The code-explainer agent runs in its own context window, so it can analyze large files without impacting your main conversation.

### Hooks

Hooks activate automatically:

- **Pre-commit check**: When Claude runs `git commit`, it checks if test files are staged and warns if not
- **Auto-format**: After Claude writes or edits a file, it runs your project's formatter (Prettier, Ruff/Black, gofmt, rustfmt)

## Plugin Structure

```
dev-toolkit/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── skills/
│   └── quick-context/
│       └── SKILL.md          # Project summarization skill
├── commands/
│   └── scaffold.md           # Boilerplate generation command
├── agents/
│   └── code-explainer.md     # Code explanation subagent
├── hooks/
│   └── hooks.json            # Hook event configuration
├── scripts/
│   ├── pre-commit-check.sh   # Commit validation script
│   └── auto-format.sh        # Auto-formatting script
└── README.md
```

## Requirements

- Claude Code CLI
- `jq` (used by hook scripts to parse JSON input)
- Optional: project-specific formatters (Prettier, Ruff, Black, gofmt, rustfmt)

## License

MIT
