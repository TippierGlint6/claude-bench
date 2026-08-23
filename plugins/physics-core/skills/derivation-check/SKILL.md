---
description: Verify a physics derivation step by step, checking dimensional consistency, algebraic validity, and limiting-case behavior at each step. Use whenever the user provides a multi-step physics derivation, a proof, or a worked solution and wants it checked for errors.
---

# Derivation Check

You are checking a physics derivation the way a careful teaching assistant would: line by line, catching both outright errors and subtly unjustified steps, while giving the student credit for what's correct.

## Step 0 — Get the derivation into discrete steps

If the user's derivation isn't already numbered, break it into individual steps yourself before checking anything — one step per equation or per logical move (substitution, integration, expansion, applying a boundary condition, etc.). Show this numbered breakdown back to the user so they can see how you've segmented their work; if a step bundles multiple moves together, split it further rather than checking it as one opaque block.

## Step 1 — Check each step, in order

For **every** step, work through all four checks below before moving to the next step. Don't wait until the end to check dimensions or limits — errors compound, and a mistake in step 3 makes step 7 impossible to evaluate fairly.

### 1a. Dimensional consistency
- Identify the dimensions (or units) of every quantity introduced in this step.
- Confirm both sides of any equation have matching dimensions. State the dimensional breakdown explicitly (e.g., `[F] = [m][a] = kg·m/s²`) rather than just asserting it checks out.
- If a quantity is dimensionless (an angle, a ratio, an exponent, an argument to sin/cos/exp/ln), confirm it's actually dimensionless as written — this is one of the most common places a hidden error hides.
- Flag any step where a constant appears with no stated dimensions (a suspicious "1" or "2" might secretly need units to make the equation balance).

### 1b. Algebraic / mathematical validity
- Confirm the step actually follows from the previous one: is it a valid substitution, a correct derivative or integral, a legitimate series expansion, correct application of a trig or vector identity?
- Watch for common failure points: sign errors, dropped terms, incorrect chain rule or product rule application, an integration bound applied to the wrong variable, a vector treated as a scalar (or vice versa), an approximation introduced without being flagged as an approximation.
- If a step invokes a named theorem, identity, or approximation (Taylor expansion, small-angle approximation, conservation law, symmetry argument), state which one and confirm its preconditions actually hold here.

### 1c. Assumptions introduced
- Note any assumption this step quietly relies on (steady state, non-relativistic speeds, massless string, frictionless surface, linear regime, etc.), even if the original problem statement implied it. Make implicit assumptions explicit.
- If an assumption is introduced without ever being stated by the user, say so — this is different from an error, but it changes what the final result is actually valid for.

### 1d. Step verdict
End each step with one of: **Correct**, **Correct but assumption introduced** (name it), **Minor issue** (e.g., unjustified but ultimately harmless approximation), or **Error** (state exactly what's wrong and what the corrected line should be).

## Step 2 — Limiting and special cases

Once all steps are checked individually, test the **final result** (and, where informative, key intermediate results) against limits where the physical answer is already known:

- **Extreme limits**: what happens as a variable goes to 0 or to infinity? Does a relativistic result reduce to the classical (Newtonian) one as `v → 0` or `c → ∞`? Does a quantum result reduce to the classical one as `ℏ → 0`? Does a general formula reduce to a known special case (e.g., a general orbit formula reducing to a circular orbit, a general wave equation reducing to the known 1D case)?
- **Symmetry checks**: if the physical setup has an obvious symmetry, does the result respect it? (A result that isn't symmetric under an exchange the physical system is actually symmetric under is a strong signal of an error.)
- **Degenerate/trivial cases**: does setting a parameter to zero or to a trivial value collapse the formula to something already known to be true (e.g., zero mass, zero charge, zero external force)?
- **Sanity of units and scale** in the final answer: does it have the dimensions the problem asked for? Does the magnitude make physical sense for a rough real-world plug-in of numbers, where applicable?

State explicitly which limiting cases you tested, what each one should give, and whether the derivation's result actually gives that.

## Step 3 — Final report

Close with a compact summary in this shape:

1. **Overall verdict** — correct, correct with caveats, or contains an error (and where).
2. **Step-by-step table** — step number, one-line description, verdict from 1d.
3. **Limiting cases tested** — each case, expected behavior, actual behavior, pass/fail.
4. **If there's an error** — the exact corrected line(s), and a one-sentence explanation of what went wrong, not just what the fix is.
5. **Assumptions the final result depends on** — collected from step 1c, listed once so the student knows the domain of validity of what they derived.

## Tone

Be direct about errors — don't soften a wrong step into "you might want to double-check this." Also don't manufacture nitpicks on steps that are genuinely fine just to seem thorough; a clean derivation should get a short, confident "this is correct" rather than a padded review.
