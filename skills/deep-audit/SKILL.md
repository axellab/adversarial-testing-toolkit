---
name: deep-audit
description: >
  Run a comprehensive, multi-agent adversarial audit of a target (feature, module, service,
  or change) across all dimensions in parallel — functional weak points, security,
  resilience/performance, and LLM robustness — then adversarially verify each finding to
  drop false positives before synthesizing one prioritized report. Use for "audit this
  thoroughly", "auditá a fondo", "full review before release", or high-stakes changes.
  Heavier and more thorough than /redteam (single agent, single artifact); use that for a
  quick focused pass.
---

# Deep audit — parallel multi-agent adversarial review

This is the heavyweight tier. It fans out specialized auditors, verifies their findings, and
synthesizes a single ranked report. Because it spends significant tokens, use it when depth
matters, not for a quick look.

**Resolving `core/`:** this skill reads shared files (`report-format.md`, the HTML template).
When installed as a plugin, their path is injected into the session at startup and also
recorded in `./.claude/.adversarial-testing-root` (→ `<root>/core/`); in project/dev mode they
are at `./core/`. Pass the resolved `core/` path to every auditor you spawn so they can load
the shared taxonomy without hunting for it.

## What to do

### 1. Scope
Determine the target and its relevant dimensions. Read enough to know which auditors apply:
- Always: `weakpoint-scout` (functional).
- If it handles untrusted input / auth / data / secrets: `security-auditor`.
- If it has external deps / load / state / concurrency: `resilience-auditor`.
- If it involves a model / prompt / agent: `llm-robustness-auditor`.
Skip a dimension only if clearly irrelevant, and say so in the final Blind spots.

State the scope to the user before fanning out (what's covered, what's not).

### 2. Fan out (parallel)
Launch the selected auditors **concurrently** (one Agent call per auditor, in a single
message) against the same target. Each loads the shared core files and returns findings in
the standard format. Let them run independently — don't serialize.

### 3. Consolidate
Collect all findings. Merge duplicates (same root cause found by two lenses → one finding,
noting both). Keep taxonomy ids so dedup is clean.

### 4. Adversarially verify
For the findings that matter (all Critical/High, and any surprising Medium), verify before
trusting them. Either delegate to `redteam-critic` framed as a skeptic ("try to refute this
finding; is it real, and is the severity right?") or verify inline by reading the cited
code/evidence. The goal is to drop plausible-but-wrong findings and correct inflated
severities. Mark each surviving finding Confirmed vs Probable.

### 5. Synthesize
Produce ONE report per `core/report-format.md`:
- Envelope: scope, dimensions covered, headline.
- Severity-ordered findings (verified), deduped, each with scenario + fix + regression test.
- Summary: counts by severity, the top 1–3 fixes to do first, and honest Blind spots
  (dimensions skipped, findings not verified, files not read).
Optionally offer `/generate-tests` to turn the recommended regression tests into real ones.

### 6. Route to output channels
Always print the synthesized report to the terminal. If the user selected additional
channels (a flag like `--out file,html,pr` or natural language such as "guardá el reporte" /
"como artifact HTML" / "comentá en el PR"), also render to those, following
`core/output-channels.md`:
- **file** → write to `reports/deep-audit-<YYYY-MM-DD>.md` and report the path.
- **html** → build from `core/templates/audit-report.html` (load the `artifact-design` skill
  first), inject the findings as the `FINDINGS` array, and publish via the Artifact tool.
- **pr** → post inline comments on the GitHub PR — **confirm the PR target and get an
  explicit yes before posting** (it is outward-facing).

The findings are authored once in the canonical structure; channels only re-render them.

## Principles

- **Parallel, then verify.** Breadth from fan-out, trust from the skeptic pass. Don't ship
  unverified Criticals.
- **One coherent report**, not four stapled together. The reader fixes top-down.
- **No silent caps.** If you sampled or skipped, say it.
- Respond in the user's language; keep taxonomy ids and severities in English.
