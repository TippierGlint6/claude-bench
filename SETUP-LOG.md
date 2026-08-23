# SETUP-LOG

Written 2026-08-22, at the end of the session that built this repo from scratch. This is meant to let anyone — including a future Claude Code session with zero memory of that conversation — pick this up cold and know exactly where things stand.

## Status: Phases 0–3 complete, plus a fourth MCP server added afterward

- **Phase 0** — audited what was already on the machine before installing anything.
- **Phase 1** — built the smallest possible working marketplace: one plugin, one real skill (`derivation-check`), installed locally and confirmed working.
- **Phase 2** — added MCP servers one at a time, checking prerequisites before each.
- **Phase 3** — turned this folder into a git repo and pushed it to GitHub: **https://github.com/TippierGlint6/claude-bench** (public repo, `master` branch).
- **Post-Phase-3** — added a fourth server, `obsidian`, after Phase 3 was already live and pushed.
- **Post-Phase-3, second addition** — added a fifth server, `manim` (3Blue1Brown-style animations), which required installing Docker Desktop system-wide first.

## Repo layout

```
claude-bench/
├── .claude-plugin/
│   ├── marketplace.json
│   └── plugin.json          # version 0.4.0 — bump this on every future change, or updates silently won't propagate
├── .mcp.json                 # 3 servers: arxiv, sympy, zotero
├── servers/
│   └── sympy-mcp/            # bundled source (no nested .git — was stripped deliberately, see note below)
├── skills/
│   └── derivation-check/
│       └── SKILL.md
├── README.md
├── SETUP-LOG.md               # this file
└── .gitignore
```

## Install on any machine

```
/plugin marketplace add TippierGlint6/claude-bench
/plugin install claude-bench-plugin@claude-bench
```
Needs `uv` on that machine for the arxiv/sympy servers, and (if you want them live) Zotero running with local API enabled and/or Obsidian running with the "Local REST API with MCP" plugin enabled (plus `OBSIDIAN_API_KEY` set — see the MCP servers table below).

## MCP servers — what's working, what's not

| Server | Status | Notes |
|---|---|---|
| `arxiv` | ✅ Working, confirmed connected | Zero extra setup — `uvx` fetches it fresh each run. |
| `sympy` | ✅ Working, confirmed connected | Source bundled in `servers/sympy-mcp/`, `uv` builds its own isolated env automatically on first run. Skips `einsteinpy`, so GR-specific tensor work isn't available — add it to that folder's `pyproject.toml` dependencies if that's ever needed. Kept despite overlap with the Wolfram connector, since it's local/free and already had a head start; Wolfram is still the better choice for most conversational symbolic-math questions. |
| `zotero` | ✅ Working, confirmed connected | Needs Zotero desktop **running**, with Settings → Advanced → "Allow other applications on this computer to communicate with Zotero" checked (it already was, at `localhost:23119/api`). If this ever shows disconnected, that's almost certainly just Zotero not being open. |
| `obsidian` | ✅ Working, confirmed connected | Added after Phase 3. Uses the **"Local REST API with MCP"** community plugin (by coddingtonbear), which as of a recent version serves MCP directly over HTTP — no separate third-party MCP server package needed, unlike the other three. Connects to `http://127.0.0.1:27123/mcp/`, authenticated via `Authorization: Bearer ${OBSIDIAN_API_KEY}` — the key is read from an environment variable, never committed. **Debugging note for future reference:** the plugin's "Enable Non-encrypted (HTTP) Server" setting did not take effect until Obsidian was fully quit and restarted — if `obsidian` ever shows `ConnectionRefused` on port 27123 again, check that setting and restart Obsidian before assuming anything else is wrong. |
| `manim` | ✅ Working, built and smoke-tested | Runs `bcefghj/math-animation-mcp` inside Docker (bundled + patched source in `servers/math-animation-mcp/`), chosen after the originally-found `Stelath/manim-mcp` turned out to be a dead repo (404 — verify a repo actually still exists before trusting a search result, don't just trust that it once did). **Requires Docker Desktop**, which wasn't installed on this machine before this addition — see the entry below. **Requires a one-time manual `docker build`** per machine (not run automatically by `/plugin install`) — see README. Two real upstream bugs found and patched in the bundled copy: (1) `pyproject.toml` required `gradio`/`pix2text` unconditionally though the MCP server never imports either, and `pix2text` pulled in `pyarrow`, which fails to build from source on this image's Python 3.14 — fixed by moving both to their already-existing-but-unused optional-dependency groups; (2) `mcp[cli]>=1.0.0` had no upper bound, so pip installed a breaking `mcp` 2.0.0 that moved `mcp.server.fastmcp.FastMCP` — fixed by pinning `<2.0.0`. If pulling fresh upstream source later, re-apply both fixes. |
| `jupyter-mcp-server` | ❌ Not added — deliberately skipped | Unlike the other four, it doesn't spawn its own process — it connects to a separately-run JupyterLab server over a token-protected URL. That means: (1) two more packages needed in the Jupyter environment (`jupyter-collaboration`, `ipykernel` — not yet installed), (2) a JupyterLab instance the user has to remember to start and keep running, (3) a secret token that can't safely be hardcoded into this repo. Revisit if/when live-notebook execution actually becomes a blocker for something. There's also an "extension mode" (runs inside JupyterLab itself, HTTP-only) that trades the two-process problem for HTTP-only transport — not explored yet. Note: `obsidian`'s solution (env-var-based secret, HTTP transport) is a good template to reuse for Jupyter's token if this gets revisited. |

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
