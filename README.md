# claude-bench

A personal Claude Code plugin marketplace covering physics/math study tools and general coding tools. Split into four independently-installable plugins so you only run what you actually need for a given session — see "Why four plugins" below for how this came about.

## What's in here

```
claude-bench/
├── .claude-plugin/
│   └── marketplace.json          # the catalog: lists all four plugins and where to find them
├── plugins/
│   ├── physics-core/               # default ON — skill + arXiv + symbolic math
│   │   ├── .claude-plugin/plugin.json
│   │   ├── .mcp.json
│   │   ├── servers/sympy-mcp/      # bundled source, so it isn't tied to any one machine
│   │   └── skills/derivation-check/
│   ├── knowledge-tools/             # default ON — Zotero + Obsidian
│   │   ├── .claude-plugin/plugin.json
│   │   └── .mcp.json
│   ├── manim-viz/                   # default OFF — Manim animations, via Docker
│   │   ├── .claude-plugin/plugin.json
│   │   ├── .mcp.json
│   │   └── servers/math-animation-mcp/  # bundled + locally-patched source
│   └── coding-tools/                # default OFF — general software engineering
│       ├── .claude-plugin/plugin.json
│       └── .mcp.json
├── README.md                       # this file
├── SETUP-LOG.md                     # detailed build history, for cold pickup by a future session
└── .gitignore                       # files that should never be committed (see below)
```

This started as the smallest version that works — one marketplace, one plugin, one skill, no MCP servers — to prove the install loop end to end. It grew to nine MCP servers in a single plugin, then got split into four plugins once that single-plugin setup made it impossible to turn any one server off without turning all of them off.

## The four plugins

| Plugin | Contains | Default |
|---|---|---|
| `physics-core` | `derivation-check` skill, `arxiv`, `sympy` | **ON** — lightweight, always relevant |
| `knowledge-tools` | `zotero`, `obsidian` | **ON** — central to the literature/notes workflow this repo exists for |
| `visual-explain` | `step-work` and `visual` skills | **ON** — skills only, no servers, so it costs nothing to leave enabled |
| `numerical-methods` | 14 computational-physics skills | **OFF** — specialised; enable when doing simulation or numerical work |
| `manim-viz` | `manim` | **OFF** — the heaviest single item (3+ GB Docker image), clearly opt-in |
| `coding-tools` | `repomix`, `context7`, `playwright`, `github` | **OFF** — general software engineering, not physics-specific |

Toggle any of them per session with `/plugin enable <name>@claude-bench` or `/plugin disable <name>@claude-bench` — no reinstall needed, and no restructuring risk from touching this repo again.

### `physics-core`

**Skill — `derivation-check`.** Give it a multi-step physics derivation and it checks each step for:
- dimensional consistency (do the units on both sides actually match?)
- algebraic validity (does each line actually follow from the one before it?)
- limiting/special-case behavior (does the final result reduce correctly to known cases, e.g. the relativistic result reducing to the classical one as v → 0?)

**Servers:**
| Server | What it does | Requires at runtime |
|---|---|---|
| `arxiv` | Search and read papers from arXiv | Nothing extra — `uvx` fetches it on first use |
| `sympy` | Symbolic math (algebra, calculus, some GR) | Nothing extra — bundled in `servers/sympy-mcp/`, `uv` builds an isolated environment automatically |

### `visual-explain`

Two skills, no MCP servers — pure instructions, which means this one works on **every** surface including plain claude.ai chat, unlike the server-backed plugins.

**`step-work`** renders multi-step algebraic manipulation as an animated step-through: individual terms glide from their old position to their new one (browser FLIP, the same idea as Manim's `TransformMatchingTex`), operators are colour-coded by kind while terms stay neutral, newly introduced terms enter highlighted and cool to neutral, and a running transcript logs every operation. It names the **hinge step** — the one move that required judgement rather than bookkeeping — and when a problem admits several methods it presents them as switchable tabs with a note on when to reach for each, plus a side-by-side compare mode. Fires on genuine multi-step work only, not arithmetic or definitions.

**`visual`** is a router, not a renderer. It decides *whether* a visual helps at all (staying quiet is a valid output), *which* visual the problem calls for, and *which mechanism* draws it — hand-authored SVG for free-body diagrams, circuits, ray diagrams and Lewis structures; Plotly for plots, surfaces and fields; 3Dmol or JSXGraph for molecules and constructions; Manim when the user wants a saved video instead.

```
skills/visual/
├── SKILL.md                    # the routing table and the skip rule — loads every session
└── references/                  # loaded on demand, only when that family is needed
    ├── widget-contract.md       # shared colours, theming, a11y, streaming, export
    ├── plotting.md
    ├── diagrams-physics.md
    ├── chemistry.md
    ├── geometry-3d.md
    └── fallbacks.md             # what to do on surfaces that can't render widgets
```

That split is deliberate: only the small router file costs context every session, and the detailed playbooks load when a given domain actually comes up.

### `knowledge-tools`

| Server | What it does | Requires at runtime |
|---|---|---|
| `zotero` | Search your Zotero library, including PDF highlights/annotations | The Zotero desktop app must be running, with **Settings → Advanced → "Allow other applications on this computer to communicate with Zotero"** turned on |
| `obsidian` | Read, write, and search your Obsidian vault | The Obsidian desktop app must be running, with the **"Local REST API with MCP"** community plugin installed and enabled, its **"Enable Non-encrypted (HTTP) Server"** setting turned on, and an `OBSIDIAN_API_KEY` environment variable set (never stored in this repo — see Secrets below) |

### `numerical-methods`

Fourteen computational-physics skills, vendored unmodified from [heshamfs/materials-simulation-skills](https://github.com/heshamfs/materials-simulation-skills) under Apache-2.0 — see `plugins/numerical-methods/NOTICE.md` for exactly what was taken, what was left behind, and why.

| Group | Skills |
|---|---|
| Numerical core | `numerical-stability` (CFL, von Neumann analysis, stiffness), `time-stepping`, `linear-solvers`, `nonlinear-solvers`, `numerical-integration`, `differentiation-schemes`, `convergence-study`, `mesh-generation` |
| Simulation workflow | `simulation-orchestrator`, `simulation-validator`, `parameter-optimization`, `post-processing`, `performance-profiling` |
| HPC | `slurm-job-script-generator` |

Default OFF because 14 skill descriptions is real context cost for something you only want during simulation work. Enable with `/plugin enable numerical-methods@claude-bench` when it's relevant.

### `manim-viz`

| Server | What it does | Requires at runtime |
|---|---|---|
| `manim` | Generates 3Blue1Brown-style math/physics animations (`bcefghj/math-animation-mcp`, bundled and patched in `servers/math-animation-mcp/`) | **Docker Desktop** installed and running, plus a one-time image build (see below) |

**One-time setup: building the Docker image.** This server runs inside a container rather than as a plain subprocess, since Manim's own dependencies (FFmpeg, a full LaTeX distribution, Cairo, Pango, CJK fonts) are heavy enough that bundling them beats installing each one on the host directly. Docker doesn't build that image automatically on `/plugin install` — run this once per machine, standing anywhere:
```powershell
docker build -t math-animation-mcp:local "<path-to-your-claude-bench-checkout>\plugins\manim-viz\servers\math-animation-mcp"
```
Rendered animations land in this plugin's persistent data directory (`${CLAUDE_PLUGIN_DATA}/manim-output`), which survives plugin updates.

> **⚠ Cold-start warning:** each `manim` tool call runs `docker run --rm`, which starts a fresh container from scratch — there's no long-running server to stay warm. Measured cold-start is ~0.8s on this machine, on top of however long the actual render takes. If a `manim` call ever seems to hang right at the start, this is the most likely reason. (This machine also has a local, machine-only hook — `.claude/hooks/manim-health-check.sh`, not part of the distributed plugin — that checks for a warm container before each call.)

**Two upstream bugs already patched in this bundled copy** (see the comment at the top of `plugins/manim-viz/servers/math-animation-mcp/pyproject.toml` for full detail): the original `pyproject.toml` required `gradio` and `pix2text` unconditionally even though the MCP server itself never imports either — `pix2text` also pulled in `pyarrow`, which fails to build from source on this image's Python 3.14. And `mcp[cli]>=1.0.0` had no upper bound, so pip could install a breaking `mcp` 2.0.0 that moved `mcp.server.fastmcp.FastMCP`. Both are fixed locally; if you ever re-pull fresh upstream source, re-apply both fixes first.

**Note on image size:** `math-animation-mcp:local` is ~3.16 GB, almost entirely the Manim base image plus a full LaTeX distribution and CJK fonts. Inherent to what it bundles, not a mistake — but worth knowing if disk space is tight. `docker builder prune -f` reclaims stale build-cache layers left over from iterating on the Dockerfile, if that ever piles up again.

### `coding-tools`

Not physics-specific — general software engineering tools.

| Server | What it does | Requires at runtime |
|---|---|---|
| `repomix` | Packs an entire codebase into one AI-friendly summary, for fast context on an unfamiliar project | **`repomix` installed globally** (`npm install -g repomix`) — runs the installed command directly rather than fetching via `npx` each time, for faster startup (~1.1s vs ~2-2.6s measured). Sandboxed to `${CLAUDE_PROJECT_DIR}` so its file access can't wander outside whatever project you're actually in |
| `context7` | Injects current, version-accurate library/framework docs into context | Nothing extra for the free tier. An optional API key from context7.com raises rate limits, but isn't required |
| `playwright` | Drives a real browser for end-to-end testing and UI verification, via accessibility snapshots rather than screenshots | Nothing extra — `npx` fetches it on first use |
| `github` | Browse repos, manage issues/PRs, and check CI status directly | A GitHub personal access token, scoped to just `repo`, set as a `GITHUB_PAT` environment variable (never stored in this repo — see Secrets below). Runs via Docker (`ghcr.io/github/github-mcp-server`, a small ~66 MB published image, no local build needed unlike `manim`) |

**Deliberately not included anywhere:** `jupyter-mcp-server`. Unlike the servers above, it doesn't spawn its own process — it connects to a JupyterLab server you start and keep running separately, over a token-protected URL. That's meaningfully more moving parts (a background process to remember to start, plus a secret token), so it's parked for later.

## Secrets: never in this repo

`zotero` needs no credential at all (local-mode only). `obsidian` and `github` each need an API key/token, referenced in their `.mcp.json` as `${OBSIDIAN_API_KEY}` / `${GITHUB_PAT}` — **environment variable expansion** Claude Code resolves at connect time — rather than the literal value ever being written into a committed file. Set each once per machine:
```powershell
[Environment]::SetEnvironmentVariable("OBSIDIAN_API_KEY", "your-actual-key", "User")
[Environment]::SetEnvironmentVariable("GITHUB_PAT", "your-actual-token", "User")
```
For the GitHub token: create one at [github.com/settings/personal-access-tokens/new](https://github.com/settings/personal-access-tokens/new), scoped to just **`repo`** — no need for `read:packages` or `read:org` for personal use, and narrower scope means less damage if it's ever leaked.

Then restart any terminal (including a running `claude` session) before it'll pick up the new value(s) — environment variables are only read when a process starts, not live.

## System-level prerequisites

Programs installed on the host machine itself, outside this repo, that some servers depend on. **None of these get installed automatically by `/plugin install`.**

**Docker Desktop** — required for `manim-viz` and `coding-tools`' `github` server.
```powershell
winget install -e --id Docker.DockerDesktop
```
Its installer will prompt to enable WSL2 and restart the machine if that's not already set up — accept both. After restarting, launch Docker Desktop once and wait for the whale icon in the system tray to stop animating before it's actually usable.

**WSL (Windows Subsystem for Linux)** — the virtualization backend Docker Desktop runs on under Windows. Normally enabled automatically by Docker's own installer above; only run this yourself if Docker reports WSL is missing:
```powershell
wsl --install
```
Note if you also run VMware or another hypervisor: WSL2 and those can conflict over Windows' Hyper-V virtualization layer on some version combinations — worth confirming your other VMs still start after installing this.

**repomix** — required for `coding-tools`.
```powershell
npm install -g repomix
```

**Zotero** — required for `knowledge-tools`.
```powershell
winget install -e --id DigitalScholar.Zotero
```
After installing: open it once, then go to Settings → Advanced and check **"Allow other applications on this computer to communicate with Zotero."**

**Obsidian** — required for `knowledge-tools`.
```powershell
winget install -e --id Obsidian.Obsidian
```
After installing: inside Obsidian, go to Settings → Community plugins → Browse, install and enable **"Local REST API with MCP"** (by Adam Coddington), then turn on its **"Enable Non-encrypted (HTTP) Server"** setting and set `OBSIDIAN_API_KEY` per the Secrets section above.

**JupyterLab** — not wired into an MCP server in this repo, but installed alongside this toolkit for future live-notebook work. It's a Python package rather than a downloadable installer:
```powershell
py -m venv jupyter-env
jupyter-env\Scripts\pip.exe install jupyterlab
```
Launch it later with `jupyter-env\Scripts\jupyter-lab.exe`.

## Installing this

On a **new machine**, this repo is hosted at **https://github.com/TippierGlint6/claude-bench** (public, no login needed):
```
/plugin marketplace add TippierGlint6/claude-bench
/plugin install physics-core@claude-bench
/plugin install knowledge-tools@claude-bench
/plugin install visual-explain@claude-bench
```
`manim-viz` and `coding-tools` are opt-in — install them the same way whenever you actually want them:
```
/plugin install manim-viz@claude-bench
/plugin install coding-tools@claude-bench
```

For a local checkout instead of GitHub, run these from a terminal standing in the folder that *contains* `claude-bench` (one level above it):
```bash
claude
```
```
/plugin marketplace add ./claude-bench
/plugin install physics-core@claude-bench
```
(and so on for the others, same names as above).

If the install summary tells you to run `/reload-plugins`, do that next so a newly-installed skill actually activates in your current session.

## Confirming it worked

Ask Claude something like *"check this derivation"* and paste a short multi-step physics derivation. If `physics-core`'s skill loaded, Claude will work through it step by step, checking units and limiting cases explicitly, rather than just giving a general opinion on whether it looks right.

You can also check installation status directly:
```
/plugin
```
This opens the plugin manager view — each installed plugin should be listed with its enabled/disabled state.

## Why four plugins

Claude Code doesn't support enabling or disabling individual MCP servers within a plugin — the docs are explicit that servers "start automatically when the plugin is enabled," all or nothing. With everything in one plugin, `manim` (a 3+ GB Docker container) and `github` (Docker again) always spun up alongside lightweight things like `arxiv`, whether or not that session actually needed them. Splitting into four separate plugins, each with its own `plugin.json` and `.mcp.json`, makes the heavy/situational ones (`manim-viz`, `coding-tools`) genuinely opt-in via `/plugin enable`/`/plugin disable`, while the lightweight always-useful ones (`physics-core`, `knowledge-tools`) stay on by default.

This is a separate concern from **tool search** — Claude Code's default behavior of deferring MCP tool *schemas* until actually needed, regardless of how many servers are connected. Tool search already keeps context-window cost low; this plugin split is about not *connecting* servers (and paying their startup/runtime cost) unless you actually want them that session.

## Companion skills, deliberately *not* vendored

Two useful collections live outside this repo on purpose. Both are already installed on the original machine; on a new one, install them separately.

**`tutor` / `tutor-setup`** — turns source material into an Obsidian StudyVault and quizzes you against it, with weak-area drilling and progress tracking. This is the spaced-repetition half of the workflow this repo exists to support, but it's an independent project ([RoundTable02/tutor-skills](https://github.com/RoundTable02/tutor-skills)) that installs machine-wide via skills.sh rather than through a plugin:
```powershell
npx skills add RoundTable02/tutor-skills
```
It lands in `~/.agents/skills/`, a shared location several AI tools read, so one copy serves all of them — which is why duplicating it here would be a step backwards.

**`claude-scientific-skills`** ([K-Dense-AI](https://github.com/K-Dense-AI/claude-scientific-skills), MIT) — 177 skills, and it's already a valid marketplace in its own right, so add it as one rather than copying 22 MB in:
```
/plugin marketplace add K-Dense-AI/claude-scientific-skills
/plugin install scientific-skills@claude-scientific-skills
```
Worth knowing before you do: roughly ninety percent of it is biology and pharma database tooling. The genuinely physics-adjacent entries are `qutip`, `qiskit`, `astropy`, `sympy`, `matplotlib`, `plotly`, and `arxiv-database` — and the last four already overlap what `physics-core` and `visual-explain` cover. Enable it when you specifically want the quantum or astronomy skills, not by default.

## What's deliberately not here yet

- `jupyter-mcp-server` (see `coding-tools` section above for why)
- No other skills beyond `derivation-check`

## Portability

Nothing in this repo hardcodes a machine-specific path. Every `${CLAUDE_PLUGIN_ROOT}` reference resolves to that specific plugin's own installation directory (not the marketplace root), and `${CLAUDE_PLUGIN_DATA}` to that plugin's persistent data directory — both filled in automatically by Claude Code, so this keeps working unchanged on Windows, macOS, or Linux, and unchanged if plugins get reordered or renamed later.
