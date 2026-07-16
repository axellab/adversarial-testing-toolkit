---
name: generate-tests
description: >
  Generate tests for a target (file, feature, or change), matching the project's own
  framework and conventions, then run them and report results with evidence. Use when the
  user says "write tests for X", "generá y corré los tests", "add test coverage", or wants
  actual executable tests — not just recommendations. Detects the stack automatically and
  never fakes a passing run.
---

# Generate and run tests

This skill produces real, executable tests and runs them, delegating to the `test-engineer`
agent. It composes naturally after `/test-plan`.

## What to do

1. **Identify the target** (file, feature, module, or current change). If a prior
   `/test-plan` / weakpoint-scout report exists in the conversation, pass that plan through
   so generation targets the ranked weak points. Otherwise the agent will identify cases
   itself.
2. **Delegate to `test-engineer`.** It will:
   - Detect the language, test framework, real test command, and existing conventions.
   - Generate tests that fit the repo (same runner, style, placement, mocks).
   - Run them and report the real command + output.
3. **Return its results.** Present what was generated, the execution evidence, any bugs the
   tests surfaced (as findings), and remaining coverage gaps.

## Guardrails

- **Never fake a run.** If the tests couldn't be executed (missing deps, unknown command),
  the report must say they were generated but NOT run, with the exact command to run or a
  request to install what's needed. Don't claim green when you don't know.
- **Fit in, don't take over.** No new test framework or dependency without asking. Keep
  tests isolated from real networks/DBs/paid APIs unless the repo already does otherwise.
- **A failing generated test may be a real bug**, not a mistake — surface it as a finding
  rather than quietly "fixing" it to pass.
- Respond in the user's language.
