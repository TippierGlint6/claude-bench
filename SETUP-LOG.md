# SETUP-LOG

Written 2026-08-22, at the end of the session that built this repo from scratch. This is meant to let anyone — including a future Claude Code session with zero memory of that conversation — pick this up cold and know exactly where things stand.

## Status: Phases 0–3 complete, plus a fourth MCP server added afterward

- **Phase 0** — audited what was already on the machine before installing anything.
- **Phase 1** — built the smallest possible working marketplace: one plugin, one real skill (`derivation-check`), installed locally and confirmed working.
- **Phase 2** — added MCP servers one at a time, checking prerequisites before each.
- **Phase 3** — turned this folder into a git repo and pushed it to GitHub: **https://github.com/TippierGlint6/claude-bench** (public repo, `master` branch).
- **Post-Phase-3** — added a fourth server, `obsidian`, after Phase 3 was already live and pushed.
- **Post-Phase-3, second addition** — added a fifth server, `manim` (3Blue1Brown-style animations), which required installing Docker Desktop system-wide first.
- **Post-Phase-3, third addition** — added four general coding-productivity servers (not physics-specific): `repomix`, `context7`, `playwright`, `github`. All four smoke-tested successfully before being handed off.
- **Post-Phase-3, fifth plugin** — added `visual-explain`: two skills (`step-work`, `visual`) and six reference playbooks. No MCP servers, so it works on every surface including plain claude.ai chat. Built after prototyping the widget behaviour interactively across several iterations (term-level FLIP motion, colour-coded operators, fresh-term highlighting, transcript, multi-method tabs and compare mode, graph panel, toggles, export). The prototypes are the reference implementation the skill encodes.
- **Post-Phase-3, restructure** — split the single `claude-bench-plugin` into four separate plugins (`physics-core`, `knowledge-tools`, `manim-viz`, `coding-tools`), after a performance review found that Claude Code has no per-server enable/disable — only per-plugin. With everything in one plugin, the heavy Docker-based servers (`manim`, `github`) always started alongside lightweight ones. See "Why four plugins" in README for the full reasoning; see "Restructure migration notes" below for exactly what moved.

## Repo layout

```
claude-bench/
├── .claude-plugin/
│   └── marketplace.json          # lists all four plugins
├── plugins/
│   ├── physics-core/               # default ON
│   │   ├── .claude-plugin/plugin.json
│   │   ├── .mcp.json                # arxiv, sympy
│   │   ├── servers/sympy-mcp/        # bundled source (no nested .git — stripped deliberately)
│   │   └── skills/derivation-check/
│   ├── knowledge-tools/             # default ON
│   │   ├── .claude-plugin/plugin.json
│   │   └── .mcp.json                # zotero, obsidian
│   ├── visual-explain/              # default ON — skills only, no servers
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   │       ├── step-work/SKILL.md    # animated algebraic manipulation
│   │       └── visual/
│   │           ├── SKILL.md          # the visual router (small, always loaded)
│   │           └── references/       # 6 playbooks, loaded on demand
│   ├── manim-viz/                   # default OFF
│   │   ├── .claude-plugin/plugin.json
│   │   ├── .mcp.json                # manim
│   │   └── servers/math-animation-mcp/
│   └── coding-tools/                # default OFF
│       ├── .claude-plugin/plugin.json
│       └── .mcp.json                # repomix, context7, playwright, github
├── README.md
├── SETUP-LOG.md               # this file
└── .gitignore
```

Each plugin's `plugin.json` version starts fresh at `1.0.0` (the old single-plugin `0.7.0` numbering doesn't carry over — these are separate plugins now, not the same one renamed). Bump a plugin's own version on every future change to it, or updates to that specific plugin silently won't propagate.

## Install on any machine

```
/plugin marketplace add TippierGlint6/claude-bench
/plugin install physics-core@claude-bench
/plugin install knowledge-tools@claude-bench
```
`manim-viz` and `coding-tools` install the same way but are opt-in (`defaultEnabled: false` in `marketplace.json`) — add them only when actually wanted:
```
/plugin install manim-viz@claude-bench
/plugin install coding-tools@claude-bench
```
Needs `uv` on that machine for the arxiv/sympy servers, and (if you want them live) Zotero running with local API enabled and/or Obsidian running with the "Local REST API with MCP" plugin enabled (plus `OBSIDIAN_API_KEY` set — see the MCP servers table below).

## `visual-explain` design notes

Worth knowing before changing it, since these were deliberate and non-obvious:

- **Progressive disclosure.** `skills/visual/SKILL.md` holds only the routing table and the skip rule, so it stays cheap to load every session. The six `references/*.md` playbooks load only when that family actually comes up. Keep the router small; put detail in references.
- **The skip rule is load-bearing.** The router is explicitly instructed that producing *no* visual is a valid, frequently-correct output. A router that always renders is worse than one that stays quiet.
- **Term identity drives the animation.** In `step-work`, the same `\htmlId{t-NAME}` across consecutive steps means "same term" and triggers a glide between positions. Reusing an id for a conceptually different term produces a *misleading* animation, so the skill is strict about this.
- **Downloads are blocked** by the viewer sandbox — `<a download>`, blob URLs, and script-driven saves are all inert. Export therefore shows copyable code plus a `sendPrompt` button asking Claude to write the real file with its own tools. Do not "fix" this by adding a download link; it will fail silently.
- **Verification is optional by design.** `step-work` uses `sympy` (from `physics-core`) to check steps when available, but degrades gracefully without it — and is instructed never to claim verification that did not happen. This is what keeps the skill usable in plain chat.
- **Known-good CDN pins:** KaTeX `0.16.9`, Plotly `2.27.0`, both from `cdnjs.cloudflare.com`. Only allowlisted hosts load; everything else fails silently, so guards are mandatory.

## Restructure migration notes

- `servers/sympy-mcp` → `plugins/physics-core/servers/sympy-mcp`, `skills/` → `plugins/physics-core/skills/`. Moving `sympy-mcp` hit real friction: two live Python processes were still running out of its `.venv\Scripts\python.exe` (the actual connected `sympy` MCP server subprocess from an active terminal session) and Windows refused to move/rename the locked folder. Had to stop those processes before the move could complete — if a future move/rename of a bundled server's folder mysteriously fails on Windows with "Permission denied" or "Device or resource busy," check for a running MCP server process from that folder first via `Get-Process | Where-Object {$_.Path -like '*<folder-name>*'}`.
- `servers/math-animation-mcp` → `plugins/manim-viz/servers/math-animation-mcp`. Moved cleanly, no lock issues.
- The old root-level `.claude-plugin/plugin.json` and root `.mcp.json` (the single-plugin versions) were deleted, superseded by the four per-plugin copies.
- `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_PLUGIN_DATA}` references in each `.mcp.json` didn't need any changes — they already resolve per-plugin, not to the marketplace root, so they kept working correctly across the move.

## MCP servers — what's working, what's not

| Server | Plugin | Status | Notes |
|---|---|---|---|
| `arxiv` | `physics-core` | ✅ Working, confirmed connected | Zero extra setup — `uvx` fetches it fresh each run. |
| `sympy` | `physics-core` | ✅ Working, confirmed connected | Source bundled in `servers/sympy-mcp/`, `uv` builds its own isolated env automatically on first run. Skips `einsteinpy`, so GR-specific tensor work isn't available — add it to that folder's `pyproject.toml` dependencies if that's ever needed. Kept despite overlap with the Wolfram connector, since it's local/free and already had a head start; Wolfram is still the better choice for most conversational symbolic-math questions. |
| `zotero` | `knowledge-tools` | ✅ Working, confirmed connected | Needs Zotero desktop **running**, with Settings → Advanced → "Allow other applications on this computer to communicate with Zotero" checked (it already was, at `localhost:23119/api`). If this ever shows disconnected, that's almost certainly just Zotero not being open. |
| `obsidian` | `knowledge-tools` | ✅ Working, confirmed connected | Added after Phase 3. Uses the **"Local REST API with MCP"** community plugin (by coddingtonbear), which as of a recent version serves MCP directly over HTTP — no separate third-party MCP server package needed. Connects to `http://127.0.0.1:27123/mcp/`, authenticated via `Authorization: Bearer ${OBSIDIAN_API_KEY}` — the key is read from an environment variable, never committed. **Debugging note for future reference:** the plugin's "Enable Non-encrypted (HTTP) Server" setting did not take effect until Obsidian was fully quit and restarted — if `obsidian` ever shows `ConnectionRefused` on port 27123 again, check that setting and restart Obsidian before assuming anything else is wrong. |
| `manim` | `manim-viz` | ✅ Working, built and smoke-tested | Runs `bcefghj/math-animation-mcp` inside Docker (bundled + patched source), chosen after the originally-found `Stelath/manim-mcp` turned out to be a dead repo (404 — verify a repo actually still exists before trusting a search result, don't just trust that it once did). **Requires Docker Desktop** and a one-time manual `docker build` per machine (not run automatically by `/plugin install`) — see README. Two real upstream bugs found and patched: (1) `pyproject.toml` required `gradio`/`pix2text` unconditionally though the MCP server never imports either, and `pix2text` pulled in `pyarrow`, which fails to build from source on this image's Python 3.14 — fixed by moving both to their already-existing-but-unused optional-dependency groups; (2) `mcp[cli]>=1.0.0` had no upper bound, so pip installed a breaking `mcp` 2.0.0 that moved `mcp.server.fastmcp.FastMCP` — fixed by pinning `<2.0.0`. Measured cold-start (container startup only, not render time): ~0.8s. Image size: 3.16 GB. |
| `repomix` | `coding-tools` | ✅ Working, smoke-tested | Whole-codebase context packing. Switched from `npx repomix@latest` to a global install (`npm install -g repomix`) partway through — measured ~1.1s startup vs ~2-2.6s for the npx-based servers below, since npx does a registry round-trip on every launch even when cached. Sandboxed to `${CLAUDE_PROJECT_DIR}` deliberately. |
| `context7` | `coding-tools` | ✅ Working, smoke-tested | Up-to-date library docs, via `npx @upstash/context7-mcp` (~2.6s startup, npx overhead — see `repomix` note; not yet switched to a global install). Running the free/no-key tier. |
| `playwright` | `coding-tools` | ✅ Working, smoke-tested | Official Microsoft browser-automation server, via `npx @playwright/mcp@latest` (~2.1s startup, npx overhead — same note as `context7`). |
| `github` | `coding-tools` | ✅ Working, smoke-tested | Official GitHub server, run via Docker (`ghcr.io/github/github-mcp-server`, 66 MB published image, no local build needed unlike `manim`, ~0.8s cold-start). Needs a `GITHUB_PAT` environment variable — a personal access token scoped to just `repo`. |
| `jupyter-mcp-server` | — (not added) | ❌ Not added — deliberately skipped | Unlike the other four, it doesn't spawn its own process — it connects to a separately-run JupyterLab server over a token-protected URL. That means: (1) two more packages needed in the Jupyter environment (`jupyter-collaboration`, `ipykernel` — not yet installed), (2) a JupyterLab instance the user has to remember to start and keep running, (3) a secret token that can't safely be hardcoded into this repo. Revisit if/when live-notebook execution actually becomes a blocker for something. There's also an "extension mode" (runs inside JupyterLab itself, HTTP-only) that trades the two-process problem for HTTP-only transport — not explored yet. Note: `obsidian`'s solution (env-var-based secret, HTTP transport) is a good template to reuse for Jupyter's token if this gets revisited. |

## What was installed system-wide (not part of this repo)

- **JupyterLab** — installed in a dedicated virtual environment at `C:\Users\Riley\jupyter-env`. Launch with `C:\Users\Riley\jupyter-env\Scripts\jupyter-lab.exe`.
- **Zotero desktop app** — now at `C:\Program Files\Zotero`. Was not installed at the start of the session; appeared partway through. Its old data folder (`C:\Users\Riley\Zotero`, ~41 MB — full-text index, citation styles, translators) predates this reinstall and got picked back up automatically.
- **git identity** configured globally: name `TippierGlint6`, email `rileyv1109908@gmail.com`.
- **Docker Desktop** — installed via `winget install -e --id Docker.DockerDesktop`, needed WSL2 enabled and a restart. This machine also has VMware Workstation installed; the two are known to conflict over Hyper-V-based virtualization on older VMware versions. Checked directly after the restart — both Docker and a VMware VM started successfully, no conflict on this machine's VMware version. If VMware ever breaks after a future Windows/Docker update, this is the first thing to check.

## What was explicitly NOT installed, and why

- **Docker** — not needed for anything on the physics/research toolchain wishlist.
- **Obsidian** — a vault already exists at `C:\Users\Riley\Obsidian Vault` (real `.obsidian` config, just the default `Welcome.md` note) from a previous install, but the app itself isn't currently installed. Reinstalling Obsidian should reconnect to that vault automatically. Not done this session — user didn't ask for it.
- **sympy-mcp's `einsteinpy` extra** — skipped to keep the bundle minimal; only needed for general-relativity-specific calculations.

## Found but not yet integrated

- **`materials-simulation-skills`** — a git clone (`heshamfs/materials-simulation-skills`) found loose in the home directory, covering numerical methods, HPC deployment, and simulation workflows. Archived (copied, not moved) to `C:\Users\Riley\OneDrive\Desktop\Claude Workspace\_staged-for-repo\materials-simulation-skills` for future consideration — not yet turned into a plugin skill here. Worth a look if simulation/numerical-methods work comes up.

## Known housekeeping items, flagged during the session but not acted on

These live outside this repo and were left alone deliberately (read-only audit, nothing destructive without explicit sign-off):

- **Duplicate Python installs**: `C:\Python314` (primary, what `python` resolves to) and `C:\Users\Riley\AppData\Local\Programs\Python\Python313\` (older, still fully functional, still on PATH). Not a current problem, just worth knowing about if a tool ever mysteriously uses the "wrong" Python.
- **Empty leftover Claude Desktop folders**: `AppData\Local\Claude Nest-3p`, `Claude-3p`, `Claude-Data` — all 0 bytes, harmless debris from an app update.
- **`AppData\Roaming\Claude\vm_bundles`** — 11 GB, belongs to Claude Desktop's sandboxed code-execution feature. Large, but not necessarily unused; flagged for awareness, not touched.
- **General Electron cache bloat** in `AppData\Roaming\Claude\Cache`, `Code Cache`, etc. (~175 MB) — safe to clear anytime, low priority.

## Open decisions for next time

1. Does live Jupyter notebook execution actually get used enough to justify the token/process-management overhead of `jupyter-mcp-server`? If yes, standalone mode (needs `jupyter-collaboration` + `ipykernel`, a running `jupyter lab --IdentityProvider.token ...`, and a way to keep that token out of the repo) or extension mode (HTTP-only, one process instead of two) are the two paths — neither has been tried yet.
2. Should `materials-simulation-skills` become a second skill (or second plugin) in this marketplace?
3. `sympy-mcp`'s value versus Wolfram hasn't actually been tested head-to-head yet — worth revisiting once there's real usage to compare.
4. `context7` and `playwright` still run via `npx` (~2-2.6s startup each) rather than a global install like `repomix` got (~1.1s) — a real, measured, easy win if `coding-tools` startup latency ever matters. Not done yet, just identified.
5. `docker builder prune -f` was recommended during the performance review to reclaim ~3.2 GB of stale build cache from iterating on `manim-viz`'s Dockerfile — not yet run as of this writing, check if it's still needed.
