# Fallbacks by surface

Inline widgets do not render everywhere. Check what is actually available before promising a visual, and degrade deliberately rather than producing something that silently fails.

## Deciding what you can render

| Available | Use |
|---|---|
| An inline widget/visualisation tool | Interactive widget — the default and best option |
| No widget tool, but an Artifact tool | Publish a self-contained HTML page and hand over the link |
| Neither, but `manim-viz` is enabled | Render a video file |
| Neither, but file tools exist | Write an `.html`, `.svg`, or plotting script to disk and send the file |
| Text only | Describe the visual precisely, and give runnable code that produces it |

Never claim a visual was produced when it was not. If nothing can render, say so in one clause and give the code instead.

## Artifacts

A published Artifact is a real, self-contained page the user can revisit and share, which makes it the better choice for something they want to keep.

Differences from an inline widget:
- Write the full page content, but still no `<!DOCTYPE>`, `<html>`, `<head>`, or `<body>` — those are added at publish time.
- Set a `<title>` at the top: a short, distinctive noun phrase.
- The host CSS variables from the widget contract are **not** present. Define your own tokens on `:root`, with `@media (prefers-color-scheme: dark)` guarded as `:root:not([data-theme="light"])`, and again under `:root[data-theme="dark"]`. Give `body` an explicit background.
- Everything must be self-contained — inline all CSS and JS, embed assets as data URIs. Only the allowlisted CDN hosts load.
- Same download restriction: the sandbox blocks page-initiated downloads.

Publish to the same file path to update in place rather than creating a second artifact.

## Manim video

Use when the user wants a file to keep, or when motion itself is the explanation. Requires the `manim-viz` plugin enabled and its Docker image built.

`TransformMatchingTex` is the direct analogue of the step-work animation: split expressions with double braces so matching parts align automatically.

```python
MathTex(r"{{a^2}} + {{b^2}} = {{c^2}}")
```

Expect a cold start of roughly a second before rendering begins, plus render time. Do not use it for something that would have been an inline widget — it is minutes of work for seconds of payoff.

## Terminal sessions

No inline rendering at all. Best options, in order:

1. Write a self-contained `.html` file and tell the user the path to open.
2. Write a plotting script (`.py` / `.m`) they can run.
3. ASCII where it genuinely works — number lines, simple sign charts, small tables. Do not attempt ASCII surfaces or diagrams.

## Cloud sessions

Cloud environments have Python, Node, and Docker, but no desktop applications and no local Zotero or Obsidian. Plot generation works; anything depending on a local app does not.

Write output files into the repository so they survive the session.

## Plain chat, no MCP servers

The skills themselves still work — they are instructions, not servers. What is lost is `sympy` verification and `manim` rendering.

In that case: produce the visual and the steps, but do not claim symbolic verification. State that steps were reasoned rather than machine-checked. Accuracy about what was verified matters more than appearing thorough.
