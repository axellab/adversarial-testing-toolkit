---
name: test-plan
description: >
  Analyze code (a file, feature, module, or change) and produce a prioritized, risk-ranked
  plan of the tests worth writing — the weak points, critical paths, and recommended cases
  by type (unit/integration/e2e/property). Use when the user asks "what should we test?",
  "qué pruebas recomendás", "where are the weak points?", or wants a test strategy before
  writing code. Recommends; it does not write or run tests (use /generate-tests for that).
---

# Recommended test plan

This skill delegates to the `weakpoint-scout` agent to map where the target is likely to
fail and what to test, ranked by risk.

## What to do

1. **Identify the target.** A file/path, a feature, a module, or the current change/diff. If
   unspecified, ask or offer the current change.
2. **Delegate to `weakpoint-scout`.** Pass the target and context, plus any focus the user
   named. The agent loads the shared mindset/taxonomy/format itself.
3. **Return its report.** It arrives risk-ranked with a "Recommended test plan" block. Keep
   that structure. Offer, as a next step, to hand the plan to `/generate-tests` to implement
   and run the tests.

## Principles

- Prioritized, concrete, and honest about coverage gaps — no flat undifferentiated lists.
- This is recommendation only. Respond in the user's language.
- For a full multi-dimension audit (security, resilience, LLM) rather than functional weak
  points, suggest `/deep-audit`.
