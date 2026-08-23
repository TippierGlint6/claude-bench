---
description: Render multi-step algebraic or symbolic manipulation as an animated, step-through widget where individual terms glide between positions, operators are colour-coded, newly introduced terms are highlighted, and a running transcript records every operation. Use whenever the user asks to solve, rearrange, derive, simplify, expand, factor, integrate, or otherwise transform an expression across more than one step. Do NOT use for plain arithmetic, single-substitution evaluations, definitions, or conceptual questions.
---

# Step Work

Show the manipulation happening, not just its result. The reader should be able to point at any moment and say what changed and why.

Read `../visual/references/widget-contract.md` before writing any widget — it carries the shared colour, theming, accessibility, and streaming rules. Read `../visual/references/fallbacks.md` if there is no inline widget renderer on this surface.

## When this fires

**Fire** on genuine multi-step symbolic work: solving an equation or system, rearranging a formula for a different variable, deriving a result, simplifying or expanding an expression, factoring, applying an identity chain, integrating or differentiating by a named technique.

**Do not fire** on:
- arithmetic (`what is 17 × 23`)
- one-move evaluations (plug numbers into a formula you were handed)
- definitions and conceptual questions (`what is a determinant`)
- work where the answer is the point and the path is uninteresting

A widget for a one-line answer is noise. When in doubt, answer in prose and offer the widget.

## Building the step array

Each step is `{tex, op, log}`:

- **`tex`** — the full expression at this moment, as a KaTeX string
- **`op`** — one or two sentences under the equation saying what was done *and why this move rather than another*
- **`log`** — a short past-tense transcript line (`"Subtracted 6 from both sides"`), or `null` for the opening step

### Tag terms so they can move

Wrap every term you want tracked in `\htmlId{t-NAME}{...}`. **The same `t-NAME` across consecutive steps means "this is the same term" and it will glide from its old position to its new one.** A term with a new id fades in as newly introduced.

This is the single most important authoring decision in the skill. Reusing an id for a term that is conceptually different produces a misleading animation — a term appearing to *move* when it was actually *replaced*. Be strict: same id only when it is genuinely the same quantity.

```
\htmlId{t-x2}{x^2} \htmlClass{op-sub}{-} \htmlId{t-5x}{5x} \htmlClass{op-eq}{=} \htmlId{t-0}{0}
```

### Tag operators by kind

| Operation | Wrapper | Colour |
|---|---|---|
| addition | `\htmlClass{op-add}{+}` | teal |
| subtraction | `\htmlClass{op-sub}{-}` | coral |
| multiplication | `\htmlClass{op-mul}{\cdot}` | purple |
| division | `\htmlClass{op-div}{\frac{a}{b}}` | pink (colours the fraction bar itself) |
| equality | `\htmlClass{op-eq}{=}` | muted, deliberately quiet |

Terms themselves stay neutral. Only operations carry colour, so the eye reads *what is being done* before *what it is being done to*. Always include the legend.

### Newly introduced terms

A term whose id did not exist in the previous step enters in the "fresh" colour (blue), then transitions back to neutral before the next step. Hold the fresh colour ~2.6 s, transition over 800 ms.

## Timing

Err slow — the point is that the user can track the change as it happens.

| Motion | Duration |
|---|---|
| Term gliding to a new position | 1400 ms, `cubic-bezier(.33,0,.2,1)` |
| New term fading in | 900 ms, 450 ms delay |
| Fresh colour → neutral | 800 ms, after ~2.6 s hold |
| Autoplay interval | 4200 ms (offer Fast / Normal / Slow at 1.6× / 1× / 0.6×) |

Implement motion with FLIP: measure every tagged term's `getBoundingClientRect()` **before** re-rendering, render the new step, measure again, apply the inverse translation with `transition:none`, then in a `requestAnimationFrame` set the transition and clear the transform. This is the browser equivalent of Manim's `TransformMatchingTex`.

## Name the hinge

Most steps are bookkeeping. Usually one is a real decision — completing the square, choosing a substitution, picking a trig identity. Mark it, and in its `op` say plainly that nothing forced it and why it was chosen anyway.

This matters more than the steps. A reader who knows *which step required judgement* has learned something transferable; a reader who only knows the sequence has memorised one problem.

## Multiple solution paths

When a problem admits more than one method, **always offer them as switchable tabs** rather than silently picking one. This is a primary goal of this skill, not a nice-to-have.

For each method provide a plain-language note on **when to reach for it** — that note is the real content; the steps are evidence for it. Example shape: *"Fastest when the roots are small integers you can spot. Gives you nothing the moment they aren't."*

Also offer a **Compare** mode putting two methods side by side, stepping together, each with its own transcript. When one method has fewer steps it finishes and holds at its result while the other continues — that visible asymmetry is the comparison.

The generalisation worth surfacing when it applies: **a hinge is a decision point, and the number of hinges is inversely proportional to how mechanical a method is.** Factoring has a hinge that can fail you; the quadratic formula has none, which is exactly why it always works and teaches nothing about the specific equation.

## Tap for context

Make key terms clickable, revealing the identity, definition, or caveat behind them. Prioritise: named identities, anything with a domain restriction, and any symbol whose meaning is the actual lesson (a discriminant, a Jacobian, a coupling constant).

Include domain caveats here rather than dropping them — `cos θ ≠ 0` belongs in the annotation for the step that divided by `cos²θ`.

## Verify when you can

If the `sympy` MCP server is available (from the `physics-core` plugin), use it to confirm each transition actually follows — `simplify_expression` on the difference, or `solve_algebraically` to check the final roots. Say in the response that steps were verified symbolically.

If `sympy` is not available, still produce the widget, but do not claim verification. Never present unverified steps as checked.

## Toggles and export

Offer toggles for **Transcript**, **Graph**, **Export**, and **Tap hints**. Default: transcript and graph on, export off, hints on.

For export, generate real, runnable code for the current problem — MATLAB `.m`, Python/matplotlib, LaTeX (the derivation as an `align` block), and CSV data. Provide a Copy button that attempts `navigator.clipboard` and **reports honestly when it is blocked**, plus a button calling `sendPrompt(...)` to ask Claude to write the file to disk and send it.

Never offer a plain download link. The sandbox blocks downloads a page starts itself, so `<a download>` and script-driven saves are inert and would fail silently.

## Pair with a visual

When the problem also has a meaningful diagram or plot, invoke the `visual` skill for it and place it below the transcript. Follow that skill's rule about when a visual is *not* warranted — do not force one.
