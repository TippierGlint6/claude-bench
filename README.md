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
│   ├── sympy-mcp/          # bundled source for the symbolic-math server (so it isn't tied to any one machine)
│   └── math-animation-mcp/ # bundled + locally-patched source for the manim animation server (runs via Docker)
├── skills/
│   └── derivation-check/
│       └── SKILL.md       # the one skill this plugin currently provides
├── README.md               # this file
└── .gitignore               # files that should never be committed (see below)
```

This started as the smallest version that works — one marketplace, one plugin, one skill, no MCP servers — to prove the install loop end to end before adding anything more complicated. It now also carries five MCP servers (see below).

## The skill: `derivation-check`

Give it a multi-step physics derivation and it checks each step for:
- dimensional consistency (do the units on both sides actually match?)
- algebraic validity (does each line actually follow from the one before it?)
- limiting/special-case behavior (does the final result reduce correctly to known cases, e.g. the relativistic result reducing to the classical one as v → 0?)

## MCP servers

An **MCP server** is an outside program Claude can talk to for extra capabilities, beyond what a skill alone can do. This plugin bundles five, all auto-started when the plugin is enabled:

| Server | What it does | Requires at runtime |
|---|---|---|
| `arxiv` | Search and read papers from arXiv | Nothing extra — `uvx` fetches it on first use |
| `sympy` | Symbolic math (algebra, calculus, some GR) | Nothing extra — bundled in `servers/sympy-mcp/`, `uv` builds an isolated environment for it automatically |
| `zotero` | Search your Zotero library, including PDF highlights/annotations | The Zotero desktop app must be running, with **Settings → Advanced → "Allow other applications on this computer to communicate with Zotero"** turned on |
| `obsidian` | Read, write, and search your Obsidian vault | The Obsidian desktop app must be running, with the **"Local REST API with MCP"** community plugin installed and enabled, its **"Enable Non-encrypted (HTTP) Server"** setting turned on, and an `OBSIDIAN_API_KEY` environment variable set to the API key shown in that plugin's settings (never stored in this repo — see below) |
| `manim` | Generates 3Blue1Brown-style math/physics animations (`bcefghj/math-animation-mcp`, bundled and patched in `servers/math-animation-mcp/`) | **Docker Desktop** installed and running, plus a one-time image build (see below) — this is the one server that isn't ready immediately after `/plugin install` |

### One-time setup: building the `manim` server's Docker image

This server runs inside a container rather than as a plain subprocess, since Manim's own dependencies (FFmpeg, a full LaTeX distribution, Cairo, Pango, CJK fonts) are heavy enough that bundling them in a container beats installing each one on the host directly. Docker doesn't build that image automatically on `/plugin install` — run this once per machine, standing anywhere:
```powershell
docker build -t math-animation-mcp:local "<path-to-your-claude-bench-checkout>\servers\math-animation-mcp"
```
Rendered animations land in this plugin's persistent data directory (`${CLAUDE_PLUGIN_DATA}/manim-output`), which survives plugin updates.

> **⚠ Cold-start warning:** each `manim` tool call runs `docker run --rm`, which starts a fresh container from scratch — there's no long-running server to stay warm. If no `math-animation-mcp:local` container has run recently, the first call after a while can take several seconds (~2.5s observed on this machine) purely for Docker to cold-start it, on top of however long the actual render takes. That's slow enough to risk a client-side timeout or just look like a stuck call. If a `manim` call ever seems to hang right at the start, this is the most likely reason — give it a few extra seconds before assuming something's broken. (This machine also has a local, machine-only hook — `.claude/hooks/manim-health-check.sh`, not part of the distributed plugin — that checks for a warm container before each call and asks for confirmation if a cold-start looks likely.)

**Two upstream bugs already patched in this bundled copy** (see the comment at the top of `servers/math-animation-mcp/pyproject.toml` for full detail): the original `pyproject.toml` required `gradio` and `pix2text` unconditionally even though the MCP server itself never imports either (only the separate, unused `--web` UI and one OCR tool do) — `pix2text` also pulled in `pyarrow`, which fails to build from source on this image's Python 3.14. And `mcp[cli]>=1.0.0` had no upper bound, so pip could install a breaking `mcp` 2.0.0 that moved `mcp.server.fastmcp.FastMCP`. Both are fixed locally; if you ever re-pull fresh upstream source instead of this bundled copy, re-apply both fixes first.

**Deliberately not included:** `jupyter-mcp-server`. Unlike the four above, it doesn't spawn its own process — it connects to a JupyterLab server you start and keep running separately, over a token-protected URL. That's meaningfully more moving parts (a background process to remember to start, plus a secret token that can't safely live in this repo), so it's parked for a later phase rather than rushed in.

### Secrets: never in this repo

`zotero` needs no credential at all (local-mode only). `obsidian` needs an API key, and it's handled the same way any future server's secret should be: referenced in `.mcp.json` as `${OBSIDIAN_API_KEY}` — an **environment variable expansion** Claude Code resolves at connect time — rather than the literal value ever being written into a committed file. Set it once per machine:
```powershell
[Environment]::SetEnvironmentVariable("OBSIDIAN_API_KEY", "your-actual-key", "User")
```
Then restart any terminal (including a running `claude` session) before it'll pick up the new value — environment variables are only read when a process starts, not live.

## System-level prerequisites

Programs installed on the host machine itself, outside this repo, that some servers above depend on. **None of these get installed automatically by `/plugin install`** — Claude Code manages this plugin's own files, not your operating system, so each needs to be installed once per machine before its matching server will connect.

**Docker Desktop** — required for `manim` (bundles Manim's heavy dependencies — FFmpeg, a full LaTeX distribution, Cairo, Pango, CJK fonts — inside a container instead of installing each one on the host directly).
```powershell
winget install -e --id Docker.DockerDesktop
```
Its installer will prompt to enable WSL2 and restart the machine if that's not already set up — accept both. After restarting, launch Docker Desktop once and wait for the whale icon in the system tray to stop animating before it's actually usable.

**WSL (Windows Subsystem for Linux)** — the virtualization backend Docker Desktop runs on under Windows. Normally enabled automatically by Docker's own installer above; only run this yourself if Docker reports WSL is missing:
```powershell
wsl --install
```
Note if you also run VMware or another hypervisor: WSL2 and those can conflict over Windows' Hyper-V virtualization layer on some version combinations — worth confirming your other VMs still start after installing this.

**Zotero** — required for the `zotero` server (reference library and PDF-highlight search).
```powershell
winget install -e --id DigitalScholar.Zotero
```
After installing: open it once, then go to Settings → Advanced and check **"Allow other applications on this computer to communicate with Zotero."**

**Obsidian** — required for the `obsidian` server (notes vault read/write/search).
```powershell
winget install -e --id Obsidian.Obsidian
```
After installing: inside Obsidian, go to Settings → Community plugins → Browse, install and enable **"Local REST API with MCP"** (by Adam Coddington), then turn on its **"Enable Non-encrypted (HTTP) Server"** setting and set `OBSIDIAN_API_KEY` per the Secrets section above.

**JupyterLab** — not wired into an MCP server in this repo yet (see `jupyter-mcp-server` above for why), but installed alongside this toolkit for future live-notebook work. It's a Python package rather than a downloadable installer:
```powershell
py -m venv jupyter-env
jupyter-env\Scripts\pip.exe install jupyterlab
```
Launch it later with `jupyter-env\Scripts\jupyter-lab.exe`.

## Installing this

On a **new machine**, this repo is hosted at **https://github.com/TippierGlint6/claude-bench** (public, no login needed) — install it there with just:
```
/plugin marketplace add TippierGlint6/claude-bench
/plugin install claude-bench-plugin@claude-bench
```
No local checkout required first. The steps below are for installing from a local copy of this folder instead (what this repo's own history was built and tested against).

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
- No other skills — one is enough to prove the install loop works

## Portability

Nothing in this repo hardcodes a machine-specific path. If a future skill or hook needs to reference its own plugin folder, it should use the `${CLAUDE_PLUGIN_ROOT}` environment variable (which Claude Code fills in automatically at install time) rather than a hardcoded path, so this keeps working unchanged on Windows, macOS, or Linux.
