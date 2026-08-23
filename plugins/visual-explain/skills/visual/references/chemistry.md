# Chemistry visuals

Follow `widget-contract.md`.

## Lewis structures — inline SVG

Draw these yourself; no library needed for main-group species.

**Do the electron accounting before drawing anything.** Structure follows from the count, not the other way round:

1. Total valence electrons (add one per negative charge, subtract one per positive).
2. Skeleton with the least electronegative atom central (never hydrogen).
3. Single bonds, then complete octets on outer atoms.
4. Leftover electrons to the central atom.
5. Short of an octet? Form multiple bonds from a lone pair on an outer atom.
6. Compute formal charges; prefer the structure minimising them.

**Rendering conventions:**
- Atoms as element symbols at ~26 px, `var(--text-primary)`.
- Bonds as lines between symbols with a gap either side — single, or two/three parallel lines ~12 px apart.
- Lone pairs as dot pairs (r ≈ 3 px, ~9 px apart) placed on the free sides of the atom.
- Formal charges as circled superscripts, shown only when non-zero.
- Resonance structures side by side with a double-headed arrow between them, never as a single averaged drawing.

**Always state the checks in the caption**: total valence electrons and that they are all accounted for, formal charges, geometry, and bond angle. A Lewis structure without its electron count is unverifiable.

Reusable helper shape for lone pairs:
```js
const pairs = [[-20,-22],[20,-22],[-20,22],[20,22]];  // offsets around the symbol
```
Filter by which sides are free given the bonding.

## Geometry and VSEPR

State electron-domain geometry and molecular geometry separately — they differ whenever lone pairs are present, and that difference is usually the point of the question. Give the ideal bond angle and note deviation caused by lone-pair repulsion.

For a 2D depiction of 3D geometry, use wedge-and-dash: solid wedge toward the viewer, hashed wedge away, plain line in plane.

## 3D molecular structure — 3Dmol.js

When conformation, chirality, or real spatial arrangement matters, load 3Dmol from an allowed CDN and feed it XYZ or SMILES. Guard the load per the contract.

Ball-and-stick is the sensible default; space-filling only when steric bulk is the question. Keep the standard CPK colours — recolouring elements breaks a convention every chemist reads automatically.

Give the user rotation, and say in the caption what to look for while rotating; an unguided 3D model is a toy.

## Reaction mechanisms

Curly arrows show **electron movement**, and their tails and heads are the content:
- tail on the electron source — a lone pair or a bond, never an atom
- head on the destination — an atom or the midpoint of a forming bond
- double-barbed for a pair, single-barbed (fishhook) for a single electron in radical steps

Draw each step as its own frame with the arrows for that step only. Label intermediates and transition states. Stacking every arrow onto one diagram is the most common mechanism-drawing error.

## Export

- **SMILES** — compact, pasteable into nearly any chemistry tool
- **XYZ** — coordinates, for computational chemistry packages
- **MOL** — when bond orders must survive the round trip
- **SVG** — the drawing itself

Per the contract: show the text, offer Copy with honest failure reporting, and a `sendPrompt` button for Claude to write the real file.
