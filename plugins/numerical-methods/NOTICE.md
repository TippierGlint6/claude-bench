# Attribution

The skills in `skills/` are **vendored, unmodified**, from:

- **Project:** materials-simulation-skills
- **Author:** HeshamFS
- **Source:** https://github.com/heshamfs/materials-simulation-skills
- **Licence:** Apache License 2.0 — full text in `LICENSE`
- **Vendored:** 2026-08-23

## What was taken, and what wasn't

Copied (14 skills):

| Upstream group | Skills |
|---|---|
| `core-numerical` | convergence-study, differentiation-schemes, linear-solvers, mesh-generation, nonlinear-solvers, numerical-integration, numerical-stability, time-stepping |
| `simulation-workflow` | parameter-optimization, performance-profiling, post-processing, simulation-orchestrator, simulation-validator |
| `hpc-deployment` | slurm-job-script-generator |

**Deliberately excluded:** the upstream `ontology` group (ontology-explorer, ontology-mapper, ontology-validator). Those parse materials-science ontology structures — real work, but specific to materials informatics rather than general applied physics, so they would have added skill descriptions to every session for no benefit here. Pull them from upstream if that ever changes.

## Structural change

Upstream nests skills two levels deep (`skills/core-numerical/linear-solvers/SKILL.md`). Claude Code's default discovery scans one level (`skills/<name>/SKILL.md`), so the group directories were **flattened away** — each skill directory was moved up unchanged, contents intact. No file inside any skill was edited.

Skill names were already unique across groups, so nothing had to be renamed.

## Updating

To refresh from upstream, re-clone and repeat the flatten: copy each `skills/<group>/<skill>/` directory to `skills/<skill>/`. Check whether upstream added skills to the excluded `ontology` group, or added new groups worth including.
