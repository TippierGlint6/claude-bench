# claude-bench

A personal Claude Code plugin marketplace. This repo is both a working plugin and the catalog that describes it, so it can be installed on any machine running Claude Code with two commands.

## What's in here

```
claude-bench/
├── .claude-plugin/
│   ├── marketplace.json   # the catalog: tells Claude Code what plugins this repo offers
│   └── plugin.json        # the plugin itself: name, version, author
├── .mcp.json               # MCP servers this plugin provides (auto-discovered, no manifest entry needed)
├── servers/
│   └── sympy-mcp/          # bundled source for the symbolic-math server (so it isn't tied to any one machine)
├── skills/
│   └── derivation-check/
│       └── SKILL.md       # the one skill this plugin currently provides
├── README.md               # this file
└── .gitignore               # files that should never be committed (see below)
```

This started as the smallest version that works — one marketplace, one plugin, one skill, no MCP servers — to prove the install loop end to end before adding anything more complicated. It now also carries three MCP servers (see below).

## The skill: `derivation-check`

Give it a multi-step physics derivation and it checks each step for:
- dimensional consistency (do the units on both sides actually match?)
- algebraic validity (does each line actually follow from the one before it?)
- limiting/special-case behavior (does the final result reduce correctly to known cases, e.g. the relativistic result reducing to the classical one as v → 0?)

## MCP servers

An **MCP server** is an outside program Claude can talk to for extra capabilities, beyond what a skill alone can do. This plugin bundles three, all auto-started when the plugin is enabled:

| Server | What it does | Requires at runtime |
|---|---|---|
| `arxiv` | Search and read papers from arXiv | Nothing extra — `uvx` fetches it on first use |
| `sympy` | Symbolic math (algebra, calculus, some GR) | Nothing extra — bundled in `servers/sympy-mcp/`, `uv` builds an isolated environment for it automatically |
| `zotero` | Search your Zotero library, including PDF highlights/annotations | The Zotero desktop app must be running, with **Settings → Advanced → "Allow other applications on this computer to communicate with Zotero"** turned on |

**Deliberately not included:** `jupyter-mcp-server`. Unlike the three above, it doesn't spawn its own process — it connects to a JupyterLab server you start and keep running separately, over a token-protected URL. That's meaningfully more moving parts (a background process to remember to start, plus a secret token that can't safely live in this repo), so it's parked for a later phase rather than rushed in.

## Installing this locally

Run these from a terminal, standing in the folder that *contains* `claude-bench` (i.e. one level above it, not inside it).

Start Claude Code, if it isn't already running:
```bash
claude
```

Register this folder as a plugin marketplace Claude Code knows about:
```
/plugin marketplace add ./claude-bench
```

Install the one plugin this marketplace offers:
```
/plugin install claude-bench-plugin@claude-bench
```

If the install summary tells you to run `/reload-plugins`, do that next so the skill actually activates in your current session:
```
/reload-plugins
```

## Confirming it worked

Ask Claude something like *"check this derivation"* and paste a short multi-step physics derivation. If the skill loaded, Claude will work through it step by step, checking units and limiting cases explicitly, rather than just giving a general opinion on whether it looks right.

You can also check installation status directly:
```
/plugin
```
This opens the plugin manager view — `claude-bench-plugin` should be listed as installed and enabled.

## Why the files are structured this way

- **One shared `.claude-plugin/` folder** holds both `marketplace.json` and `plugin.json` because this marketplace's one plugin uses `"source": "./"` — meaning the plugin *is* the marketplace root, so both manifest files naturally live in the same place. A marketplace with several plugins would instead put each plugin's `plugin.json` inside that plugin's own subfolder.
- **`skills/derivation-check/`** is Claude Code's default location for skills — no extra configuration in `plugin.json` was needed to make it discoverable.

## What's deliberately not here yet

- `jupyter-mcp-server` (see MCP servers section above for why)
- No GitHub hosting yet — this only installs from a local path so far
- No other skills — one is enough to prove the install loop works

## Portability

Nothing in this repo hardcodes a machine-specific path. If a future skill or hook needs to reference its own plugin folder, it should use the `${CLAUDE_PLUGIN_ROOT}` environment variable (which Claude Code fills in automatically at install time) rather than a hardcoded path, so this keeps working unchanged on Windows, macOS, or Linux.
