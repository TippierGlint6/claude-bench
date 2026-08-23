# Widget contract

Shared rules for every visual this plugin produces. Read before writing widget code.

## Theming — non-negotiable

Every colour must work in light and dark mode. Use the host's CSS variables for anything structural:

| Purpose | Variable |
|---|---|
| Body text | `var(--text-primary)` |
| Supporting text | `var(--text-secondary)` |
| Captions, axes, hints | `var(--text-muted)` |
| Panel background | `var(--surface-1)` |
| Raised card | `var(--surface-2)` |
| Hairline border | `var(--border)` / `var(--border-strong)` |
| Accent / active | `var(--text-accent)`, `var(--bg-accent)`, `var(--border-accent)` |
| Corner radius | `var(--radius)` for controls, `12px` for cards |
| Monospace | `var(--font-mono)` |

Never hardcode `#333` or `white` — invisible in one mode or the other.

For custom categorical colour (operators, series, categories), define your own variables with a dark-mode override, using 600 stops for light and 200 stops for dark:

```css
:root{--op-add:#0F6E56;--op-sub:#993C1D;--op-mul:#534AB7;--op-div:#993556;--fresh:#185FA5}
@media(prefers-color-scheme:dark){
  :root{--op-add:#5DCAA5;--op-sub:#F0997B;--op-mul:#AFA9EC;--op-div:#ED93B1;--fresh:#85B7EB}
}
```

Useful ramp stops (light 600 / dark 200): purple `#534AB7`/`#AFA9EC`, teal `#0F6E56`/`#5DCAA5`, coral `#993C1D`/`#F0997B`, pink `#993556`/`#ED93B1`, blue `#185FA5`/`#85B7EB`, amber `#854F0B`/`#FAC775`, green `#3B6D11`/`#C0DD97`.

In SVG, read a themed colour at runtime when you need it as an attribute:
```js
const muted = getComputedStyle(document.body).getPropertyValue("--text-muted");
```

## Structure

- Start with a visually-hidden `<h2 class="sr-only">` summarising the visual for screen readers. SVG-only output uses `role="img"` with an `aria-label` instead.
- No `<!DOCTYPE>`, `<html>`, `<head>`, or `<body>` — content fragments only.
- No `position: fixed` anywhere. The iframe sizes itself to in-flow content, so fixed elements collapse it. For popovers, use `position:absolute` inside a `position:relative` wrapper that reserves space with `padding-bottom`.
- Container is **680 px** wide. Use `repeat(auto-fit, minmax(160px, 1fr))` for responsive columns and `minmax(0, 1fr)` to stop grid children overflowing.
- Wide content scrolls inside its own `overflow-x:auto` container; the page itself must never scroll sideways.

## Streaming

Widget code streams token by token and scripts run only after streaming completes.

- Order: `<style>` (short) → content HTML → `<script>` last.
- A library's `<script src>` must appear **before** any inline script using its global.
- Prefer inline `style="..."` over long `<style>` blocks so controls look right mid-stream.
- No `display:none` sections during streaming, no tabs or carousels that hide content while it arrives. JS-driven toggles after load are fine.

## Typography and tone

- Sentence case everywhere, including axis labels and diagram text. Never Title Case, never ALL CAPS.
- Minimum font size 11 px. Body 14 px, captions 12–13 px.
- Two weights only: 400 and 500. Never 600 or 700.
- No emoji. Icons are Tabler outline webfont: `<i class="ti ti-check" aria-hidden="true"></i>`. Never `-filled` variants.
- Round every displayed number — `toFixed(n)`, `Math.round()`, or `toLocaleString()`. Float artefacts like `0.30000000000000004` reaching the screen is a bug.

## Controls

Form elements are pre-styled — write bare `<button>`, `<select>`, `<input type="range">`. Only add inline styles to override size.

- Every control gets a label or `aria-label`.
- Icon-only buttons must have `aria-label`.
- Disable navigation buttons at range ends rather than letting them no-op silently.
- Validate any input before acting on it; show an inline error in `var(--text-danger)` at 13 px and stop, rather than proceeding with bad input.

## Libraries

Allowed CDN hosts only: `cdnjs.cloudflare.com`, `esm.sh`, `cdn.jsdelivr.net`, `unpkg.com`, `fonts.googleapis.com`, `fonts.gstatic.com`. Every other origin is blocked by CSP and fails silently.

Always guard:
```js
if (typeof Plotly === "undefined") {
  stage.innerHTML = '<p style="font-size:13px;color:var(--text-danger)">Plot library failed to load.</p>';
  return;
}
```

Known-good: KaTeX `0.16.9`, Plotly `2.27.0`, both from cdnjs.

## Export

The viewer sandbox blocks downloads the page starts itself. `<a download>`, blob URLs, and script-driven saves are all inert.

Provide instead:
1. The generated code visible in a `<pre>` for manual selection.
2. A **Copy** button attempting `navigator.clipboard.writeText`, wrapped in try/catch, reporting honestly on failure ("Clipboard blocked — select the text above").
3. A button calling `sendPrompt("Write ... to a real file and send it to me.")` so Claude writes the file with its own tools and returns it.

## Using sendPrompt

`sendPrompt(text)` sends a message to chat as if the user typed it. Use it for anything needing Claude to think or act — saving files, exploring a variation, explaining a step further. Handle filtering, sorting, and recomputation in JS instead; do not round-trip through chat for work the widget can do itself.

Buttons that trigger `sendPrompt` get a trailing `↗`.

## Accessibility floor

- Text on a coloured fill uses the 800/900 stop of that same ramp — never black or generic grey.
- Colour is never the only channel. Pair it with a label, shape, or position.
- Include the legend whenever colour encodes meaning.
