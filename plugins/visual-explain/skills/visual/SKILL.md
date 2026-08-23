---
description: Pick and render the right visual for a maths, physics, or chemistry problem — plots, free-body diagrams, circuits, ray diagrams, Lewis structures, 3D surfaces, molecules, vector fields, geometric constructions. Routes to the correct rendering mechanism and knows when a visual would not help. Use whenever a scientific or mathematical answer would be clearer with a picture, or when the user asks for a graph, diagram, structure, plot, or render.
---

# Visual

A router, not a renderer. The job is to choose **whether** a visual helps, **which** visual, and **which mechanism** draws it — then draw that one well.

Read `references/widget-contract.md` before writing any widget. Load only the reference file for the family you actually need.

## First: should there be a visual at all?

> Choose a visual because it answers a question, not because the problem looks abstract.

Skip the visual, and say why in one clause, when:
- the relationship is already obvious from the algebra (`3x + 7 = 2x + 12` has a graph; it teaches nothing)
- the picture would restate the answer rather than explain it
- there is no spatial, geometric, or quantitative structure to show
- a table would genuinely be clearer (short sequences, iteration traces, comparing expected against observed)

A router that always renders is worse than one that stays quiet. Omitting a visual is a valid, frequently correct output.

## Routing table

| The problem is about | Visual | Mechanism | Reference |
|---|---|---|---|
| Roots, solving one equation | curve with axis crossings marked | Plotly or inline SVG | `plotting.md` |
| Inequalities, sign analysis | shaded number line or sign chart | inline SVG | `plotting.md` |
| System of 2 equations | intersecting lines | Plotly 2D | `plotting.md` |
| System of 3 equations | intersecting planes | Plotly 3D | `plotting.md` |
| Single-variable calculus | curve with tangent, area, or limit marked | Plotly | `plotting.md` |
| Multivariable, fields, potentials | surface, contour, or quiver plot | Plotly 3D | `plotting.md` |
| Complex numbers | Argand diagram | inline SVG | `plotting.md` |
| Statistics, distributions | density or histogram with region shaded | Plotly | `plotting.md` |
| Forces, statics, mechanics | free-body diagram | inline SVG | `diagrams-physics.md` |
| Vector addition, resolution | head-to-tail arrows with components | inline SVG | `diagrams-physics.md` |
| Circuits | schematic with labelled components | inline SVG | `diagrams-physics.md` |
| Optics | ray diagram with focal points | inline SVG | `diagrams-physics.md` |
| Waves, oscillation, interference | animated waveform | SVG + JS, or Manim for a file | `diagrams-physics.md` |
| Thermodynamic cycles | PV or TS diagram with the path traced | Plotly | `plotting.md` |
| Quantum states, orbitals | wavefunction plot, orbital isosurface, Bloch sphere | Plotly 3D | `geometry-3d.md` |
| Molecular structure, bonding | Lewis structure | inline SVG | `chemistry.md` |
| Molecular geometry, conformation | 3D ball-and-stick | 3Dmol.js | `chemistry.md` |
| Crystal lattices, unit cells | 3D lattice | 3Dmol.js or three.js | `geometry-3d.md` |
| Euclidean geometry, constructions | interactive construction | JSXGraph | `geometry-3d.md` |
| Graph theory, networks | node-link diagram | inline SVG or vis.js | `geometry-3d.md` |
| **Nothing above fits and nothing spatial is at stake** | **none — say so briefly** | — | — |

When a problem spans two rows, pick the one matching **what the user is actually stuck on**, not the most impressive render. A projectile question is usually a free-body diagram problem, not a 3D trajectory problem.

## Mechanisms, in order of preference

1. **Hand-authored inline SVG** — no dependency, instant, fully theme-controlled, works everywhere. Default for anything with known structure: diagrams, schematics, number lines, Lewis structures. Prefer this whenever it is sufficient.
2. **Plotly** from an allowed CDN — for anything driven by data or a function: 2D/3D plots, surfaces, contours, fields. Roughly 3 MB, so do not load it to draw a straight line.
3. **Specialist libraries** — 3Dmol.js for real molecules, JSXGraph for interactive geometry, three.js for custom 3D. Load only when the domain genuinely needs it.
4. **Manim**, via the `manim-viz` plugin — only when the user wants a **saved video file** rather than an inline visual, or when the motion itself is the explanation. Slow and Docker-dependent; never the default.

Only CDN hosts on the allowlist load: `cdnjs.cloudflare.com`, `esm.sh`, `cdn.jsdelivr.net`, `unpkg.com`, `fonts.googleapis.com`, `fonts.gstatic.com`. Anything else fails silently — always guard with a `typeof Lib === "undefined"` check and a visible message.

## Compute what you plot

Where the underlying values matter, derive them rather than eyeballing them:
- `sympy` (from `physics-core`) for symbolic results — roots, derivatives, series, eigenvalues
- Wolfram, where connected, for numeric evaluation and physical constants

Plotting a curve through points you guessed is worse than plotting nothing.

## Always offer export

Any visual carrying real data should be exportable so the user can rebuild it elsewhere: MATLAB `.m`, Python/matplotlib, CSV for raw data, and format-appropriate extras (XYZ or SMILES for molecules, TikZ for diagrams destined for LaTeX).

Downloads started by the page are blocked by the sandbox. Provide a Copy button that reports honestly if the clipboard is blocked, and a `sendPrompt(...)` button asking Claude to write the file to disk and send it back.

## Interaction defaults

Make it explorable where exploration teaches something — rotate a 3D surface, drag a parameter, toggle a force on and off. Do not add controls that do not answer a question.

Provide toggles for optional panels rather than stacking everything. Label what each control does; never leave a slider unlabelled.
