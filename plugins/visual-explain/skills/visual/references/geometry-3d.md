# Geometry, 3D, and networks

Follow `widget-contract.md`. Guard every CDN load.

## Interactive geometry — JSXGraph

For Euclidean constructions, loci, conic sections, and anything where dragging a point is the lesson. Load from an allowed CDN (`cdnjs.cloudflare.com` or `cdn.jsdelivr.net`), CSS and JS both.

Use it when the construction is meant to be *manipulated*. For a static labelled figure, hand-authored SVG is lighter and gives better typography.

Make the draggable points obviously draggable, and say in the caption which ones move and what stays invariant while they do — an invariant the reader discovers by dragging is worth more than one asserted in text.

## 3D surfaces and fields — Plotly

Covered in `plotting.md`. Preferred for anything expressible as z = f(x,y), a parametric surface, or a vector field, because it handles axes, scaling, and camera for free.

Quantum-specific uses:
- **Wavefunctions** — plot ψ and |ψ|² together, and say which is which. Sign information in ψ is usually the point and vanishes in |ψ|².
- **Orbitals** — isosurfaces with the two phase lobes in different colours, since the phase relationship is what bonding arguments depend on.
- **Bloch sphere** — a unit sphere with the state vector, plus axis labels for |0⟩, |1⟩, |+⟩, |−⟩. Mark the poles.

## Custom 3D — three.js

Only when Plotly cannot express the object: crystal lattices with a specific basis, articulated mechanical assemblies, custom geometry with real materials and lighting.

Load from an allowed CDN, ideally as an ES module from `esm.sh` or `cdn.jsdelivr.net`. Dispose of renderers and geometries if the widget rebuilds, or repeated interaction leaks memory.

Set `renderer.setClearColor(0x000000, 0)` for a transparent background so the host theme shows through, and read text colours from CSS variables for any labels.

## Crystal lattices

Draw the unit cell edges explicitly — a cloud of atoms with no cell boundary is unreadable. Distinguish corner, face, and body positions by colour, and state the lattice type, coordination number, and atoms-per-cell in the caption. Where fractional occupancy matters (corner atoms shared between eight cells), say so rather than letting the picture imply whole atoms.

3Dmol.js handles standard crystal formats directly and is usually less work than three.js for this.

## Networks and graphs

Node-link diagrams for graph theory, circuits treated abstractly, state machines, and reaction networks.

Hand-authored SVG is enough for anything under roughly 20 nodes and gives full control of labelling. Beyond that, a force-directed layout from vis.js or D3 saves considerable effort.

Label edges with weights when weights matter. For directed graphs, arrowheads must be unmistakable — a directed graph read as undirected produces confidently wrong answers.

## Choosing between 2D and 3D

Default to 2D. Reach for 3D only when the third dimension carries information the reader cannot infer:

- A trajectory in a plane is a 2D problem, even though the motion happens in space.
- A saddle point genuinely needs 3D — "stable one way, unstable the other" is hard to see in a contour plot alone.
- Molecular geometry needs 3D when conformation or chirality is at issue, and does not when connectivity is.

3D that adds rotation but no information costs the reader effort and gives nothing back.

## Export

- **OBJ / STL** for 3D geometry, including 3D printing
- **XYZ** for atomic coordinates
- **MATLAB / Python** for surfaces and fields, so the user can regenerate and modify the plot
- **CSV** for the underlying data

Per the contract: visible code, Copy with honest failure reporting, and a `sendPrompt` button for a real file.
