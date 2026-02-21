# claude-marketplace

A public Claude Code plugin marketplace — install developer tools directly into Claude Code.

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [dev-toolkit](./plugins/dev-toolkit/) | Developer utilities: project summarization, scaffolding, code explanation, commit checks, auto-formatting | 1.0.0 |
| [task-manager](./plugins/task-manager/) | Persistent, version-controlled task management with TODO.md, per-task markdown files, and session context injection | 0.1.0 |

## Installation

### Add this marketplace

```bash
claude /plugin marketplace add alikgushkan/claude-marketplace
```

### Install a plugin

```bash
claude /plugin install dev-toolkit@alik-plugins
```

### Or test locally

```bash
git clone https://github.com/alikgushkan/claude-marketplace.git
claude --plugin-dir ./claude-marketplace/plugins/dev-toolkit
```

## Plugin Highlights

### dev-toolkit

A showcase plugin demonstrating all major Claude Code plugin component types:

- **Skill** (`quick-context`) — Summarizes any project's tech stack, structure, and recent activity
- **Command** (`scaffold`) — Generates boilerplate for components, routes, tests, and more
- **Agent** (`code-explainer`) — Deep code explanations with data flow diagrams
- **Hooks** — Pre-commit test check + auto-formatting on file writes

See the [dev-toolkit README](./plugins/dev-toolkit/README.md) for full usage details.

## For Plugin Authors

Want to add your plugin to this marketplace? Open a PR:

1. Create your plugin in `plugins/your-plugin-name/`
2. Include a `.claude-plugin/plugin.json` manifest
3. Add a `README.md` with installation and usage docs
4. The CI workflow will validate your plugin structure automatically

### Plugin Structure

```
plugins/your-plugin/
├── .claude-plugin/
│   └── plugin.json      # Required: name, version, description
├── skills/              # Optional: SKILL.md files
├── commands/            # Optional: command markdown files
├── agents/              # Optional: agent markdown files
├── hooks/               # Optional: hooks.json
├── scripts/             # Optional: hook scripts
└── README.md            # Required: documentation
```

## License

MIT
