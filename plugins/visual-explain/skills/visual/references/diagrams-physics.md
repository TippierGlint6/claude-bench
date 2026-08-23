# Physics diagrams

Hand-authored inline SVG. No library, full theme control, works on every surface. Follow `widget-contract.md`.

## Shared arrow setup

Define markers once, reuse everywhere:

```html
<defs>
  <marker id="ah" markerWidth="9" markerHeight="9" refX="7" refY="3" orient="auto">
    <path d="M0,0 L0,6 L8,3 z" fill="var(--text-accent)"/>
  </marker>
</defs>
```

One marker per colour used. `orient="auto"` keeps the head aligned with the line.

## Free-body diagrams

The default visual for any forces, statics, equilibrium, or Newton's-laws problem.

Rules that make an FBD correct rather than decorative:
- **Every force arrow starts at one point** — the body's centre. Forces are not drawn where they "look right".
- **Only forces acting *on* the body.** No reaction forces on other objects, no `ma` drawn as a force.
- **Label with symbols, not values** (`W = mg`, `N`, `f`, `T`), and keep the label at the arrow head.
- **Mark the angle** with a small arc and a symbol, and state its value in the caption.
- **Arrow length should reflect relative magnitude** where known. Equal-length arrows for unequal forces mislead.
- If resolving into components, draw components as dashed lines in the same colour as their parent vector.

Include the governing equations under the diagram (`f = mg sin θ`, `N = mg cos θ`) — the diagram exists to justify them.

For an inclined plane: draw the incline as a path, rotate the block with `transform="translate(x,y) rotate(-θ)"`, and remember screen y increases downward, so a physical angle of 30° above horizontal is `rotate(-30)` in SVG.

## Vector addition and resolution

Head-to-tail for sums, common-origin for resolution. Draw the resultant in a distinct colour and heavier stroke. Show component projections as dashed drop-lines to the axes. Label magnitude and angle of the resultant.

For 3D vectors, prefer an isometric projection in SVG over loading a 3D library — cheaper and usually clearer for textbook problems.

## Circuits

Draw components as conventional symbols on a rectilinear grid:
- resistor — zigzag or an open rectangle (pick one, stay consistent)
- capacitor — two parallel plates, unequal for polarised
- battery / cell — long and short parallel lines
- inductor — a series of arcs
- ground — the descending-bar symbol

Label every component with symbol and value (`R₁ = 4.7 kΩ`). Mark current direction with arrowheads on wires and state the convention used. Mark node voltages where the analysis depends on them. Keep wires on horizontal and vertical runs only, with clean corners — diagonal wires read as sloppy schematics.

For anything destined for LaTeX, offer a CircuiTikZ export alongside the SVG.

## Ray diagrams

For lenses and mirrors, draw the principal rays and nothing else:
1. parallel to the axis, then through (or from) the focal point
2. through the centre of the lens, undeviated
3. through the near focal point, then parallel

Mark `F` and `2F` on both sides, draw the object as an upright arrow from the axis, and the image where the rays converge — dashed rays and a dashed image for virtual images. That dashed convention carries the entire real/virtual distinction, so never omit it.

## Waves and oscillation

Animate rather than freeze when the motion *is* the point. A `requestAnimationFrame` loop updating a sampled path is enough for travelling waves, standing waves, superposition, and beats.

Always include a play/pause control — an animation that cannot be stopped is hostile to someone trying to read it. Mark wavelength, amplitude, and node positions on the paused frame.

For interference, draw the components in muted colours and the resultant in the accent colour, so the superposition is legible.

If the user wants a file to keep rather than an inline animation, hand off to the `manim-viz` plugin instead.

## Common failure modes

- Drawing forces that do not act on the chosen body
- Unlabelled angles, or an angle drawn from the wrong reference line
- Ray diagrams with solid lines for virtual rays
- Circuit diagrams with no current direction marked
- Any diagram whose caption does not say what it is showing
