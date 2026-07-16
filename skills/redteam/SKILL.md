---
name: redteam
description: >
  Run a focused adversarial critique of one artifact — a plan, spec, code file/change, or
  LLM prompt — and get back only the structured "how it can fail" analysis. Use when the
  user says "red-team this", "attacá este plan/código/prompt", "how could this break?",
  "poke holes in this", or wants an adversarial second opinion on something specific.
  For a whole-project multi-dimension sweep use /deep-audit; for spec-kit artifacts use
  /spec-attack.
---

# Red-team a single artifact

This skill delegates to the `redteam-critic` subagent to produce a structured adversarial
analysis of one target, without touching the primary work.

## What to do

1. **Identify the target** from the user's message and context:
   - An explicit file/path, a pasted plan/spec/prompt, a described design, or the current
     diff/change under discussion.
   - If nothing is specified, ask what to red-team (or offer the current change/diff).

2. **Delegate to the `redteam-critic` agent.** Pass it:
   - The target (path or inlined content) and enough context to reason concretely.
   - The target type if known (plan / spec / code / prompt) so it aims the right lenses.
   - Any focus the user asked for (e.g. "just security").

   The agent loads `core/adversarial-mindset.md`, `core/failure-taxonomy.md`, and
   `core/report-format.md` itself, so you don't need to restate them.

3. **Return the agent's report** to the user as-is (it already follows the shared report
   format). Add at most a one-line orientation above it if helpful. Do not water down or
   summarize away the findings.

4. **Route to output channels (optional).** Always show the report in the terminal. If the
   user asked to persist or share it (a flag like `--out file,html,pr` or natural language),
   render to those channels per `core/output-channels.md` — `file` writes
   `reports/redteam-<YYYY-MM-DD>.md`, `html` builds from `core/templates/audit-report.html`
   and publishes via Artifact, `pr` posts inline PR comments **after explicit confirmation**.

## Principles

- This is analysis only — no fixes are applied, nothing is exploited.
- Keep the output honest about confidence and blind spots.
- Respond in the user's language.
- If the target is large (e.g. a whole codebase), say so and suggest `/deep-audit` for a
  parallelized multi-dimension pass instead of forcing one agent through everything.
