# Plotting

For anything driven by a function or dataset. Follow `widget-contract.md` for theming and structure.

## Choosing the plot

| Question being asked | Plot |
|---|---|
| Where are the roots? | curve with axis crossings marked and labelled |
| Where do these two agree? | both curves on shared axes, intersection marked |
| What is the sign of this? | shaded number line or sign chart |
| What does this rate look like? | curve with tangent line at the point of interest |
| How much accumulates? | curve with the region under it shaded |
| What is the shape of this surface? | 3D surface, plus a contour projection |
| Which way does the field point? | quiver or streamline plot |
| How is this distributed? | density curve with the region of interest shaded |
| Does this converge? | table or sequence plot — often a table teaches better |

Pick the window from the mathematics, not from a default. If the interesting behaviour lives on `[1.9, 3.1]`, do not plot `[-10, 10]`.

Always mark and label the features that answer the question — roots, intersections, extrema, asymptotes, the point of tangency. An unlabelled curve is decoration.

## Inline SVG for simple 2D

Prefer this over loading Plotly for a single curve. Build a coordinate mapper, sample the function, emit a path:

```js
const W=640,H=210, x0=0,x1=5, y0=-1.6,y1=6.6;
const PX = x => 44 + (x-x0)/(x1-x0)*(W-70);
const PY = y => H-24 - (y-y0)/(y1-y0)*(H-44);
let d=""; for(let x=x0; x<=x1+1e-9; x+=0.05){
  const y = f(x); d += (d?"L":"M") + PX(x).toFixed(1) + "," + PY(y).toFixed(1);
}
```

Draw axes at `PY(0)` and `PX(0)`, then the path with `stroke="var(--curve)" fill="none" stroke-width="2.5"`. Read `--text-muted` at runtime for axis strokes.

Clamp or clip samples that fall outside the y-window rather than letting the path shoot off-canvas.

## Number lines and sign charts

For inequalities, sign analysis, and interval answers. Mark critical points, use filled circles for closed endpoints and hollow for open, shade satisfying intervals, and label each region with its sign. This is almost always clearer than a curve for inequality questions.

## Plotly

Load only when 3D, fields, or interactivity genuinely earn ~3 MB:

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/plotly.js/2.27.0/plotly.min.js"></script>
```

Transparent background and themed font, always:

```js
const fc = getComputedStyle(document.body).getPropertyValue("--text-muted").trim() || "#888";
Plotly.newPlot(el, traces, {
  margin:{l:0,r:0,t:0,b:0},
  paper_bgcolor:"rgba(0,0,0,0)", plot_bgcolor:"rgba(0,0,0,0)",
  font:{color:fc, size:11},
  scene:{ xaxis:{title:"x"}, yaxis:{title:"y"}, zaxis:{title:"V"},
          camera:{eye:{x:1.5,y:1.5,z:1.1}} }
}, {displayModeBar:false, responsive:true});
```

Trace types worth knowing:
- `type:"surface"` with `contours:{z:{show:true, usecolormap:true, project:{z:true}}}` — a surface plus its contour shadow, which reads far better than the surface alone
- `type:"contour"` — level curves for potentials and topography
- `type:"scatter3d", mode:"lines"` — trajectories and parametric curves
- `type:"scatter", fill:"tozeroy"` — shaded area under a curve
- `type:"cone"` — 3D vector fields

Guard the load, per the contract. Set `showscale:false` unless the colour scale carries meaning the reader needs.

## Thermodynamic and phase diagrams

PV, TS, and phase-space plots are ordinary 2D plots with the *path* as the content. Draw the cycle direction with arrowheads along the path, label each leg with its process (isothermal, adiabatic), and mark state points. Enclosed area usually means work — say so in the caption if it does.

## Captions

One or two sentences saying what the visual confirms, and what it only suggests. If the plot and the algebra disagree, say so plainly rather than trusting either — that disagreement is a finding.
