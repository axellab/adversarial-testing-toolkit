---
name: spec-attack
description: >
  Adversarially review spec-driven-development artifacts before they turn into code —
  attacks a spec, plan, or task list (GitHub Spec Kit spec.md / plan.md / tasks.md, or any
  spec/plan document) for ambiguity, unstated assumptions, missing and conflicting
  requirements, untestable acceptance criteria, sequencing/rollback risk, integration gaps,
  and security/privacy-by-design omissions. Returns ranked findings plus corrective tasks
  you can fold back into the plan. Use for "attack this spec/plan", "revisá la spec antes
  de codear", or as the critique phase between specify → plan → tasks → implement.
---

# Spec-attack — adversarial review for spec-driven development

This skill hardens specs and plans *before* implementation, where fixing a flaw is cheapest.
It composes with GitHub Spec Kit but works on any spec/plan document.

## What to do

### 1. Locate the artifact
- **Spec Kit layout:** look under `specs/**/` for `spec.md`, `plan.md`, `tasks.md`, and a
  `constitution` / principles file if present. Also check `.specify/` or a `memory/`
  constitution. If several feature folders exist, ask which, or take the one the user named.
- **Otherwise:** use the spec/plan file or pasted content the user provides.
- Identify which stage you're attacking (spec vs plan vs tasks) — the lens differs.

### 2. Delegate to `redteam-critic`
Pass the artifact, its type (spec / plan / tasks), and any linked context (the constitution,
the parent spec when attacking a plan, the existing system when attacking a migration). Ask
it to weight the **PLAN** dimension of the taxonomy first:
- PLAN-01 ambiguity, PLAN-02 unstated assumptions, PLAN-03 missing requirements, PLAN-04
  conflicts, PLAN-05 untestable acceptance criteria, PLAN-06 scope/sequencing & rollback,
  PLAN-07 interface/integration gaps, PLAN-08 failure/rollback planning, PLAN-09 operational
  readiness, PLAN-10 security/privacy by design.
- Then the FUNC/SEC/RES/LLM risks the spec's or plan's choices will create downstream.

For consistency with Spec Kit's own review gates, also check: does every requirement have an
objective acceptance test? Does every task trace to a requirement? Are there requirements
with no task, or tasks with no requirement?

### 3. Turn findings into corrective actions
Beyond the ranked findings, produce a **"Corrective tasks"** block: concrete edits to the
spec/plan and, where useful, new task entries phrased to drop straight into `tasks.md`
(e.g. "Clarify FR-3: define 'fast' as p95 < 200ms" / "Add task: define rollback for the
data-migration step"). This is what makes the critique actionable inside the SDD loop.

### 4. Return the report
Present the `redteam-critic` report (report-format envelope + ranked findings) followed by
the Corrective tasks block. Offer to apply the spec/plan edits if the user wants, and to run
`/deep-audit` once code exists.

## Principles

- Attack the artifact before it becomes expensive code; the earlier the cheaper.
- Every finding names the requirement/section it targets and how to make it testable.
- Analysis and recommendation only — don't rewrite the whole spec unless asked.
- Respond in the user's language; keep taxonomy ids in English.
