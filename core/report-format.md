# Report Format

Every agent and skill in this toolkit reports findings in the structure below. A single,
shared format is what lets a lightweight skill and a multi-agent deep audit produce output
that reads the same, dedupes cleanly, and can be piped between tools.

**Language rule:** write the report in the language the user is speaking. The taxonomy ids,
field names, and severity labels stay in English (they are stable identifiers); the prose
adapts.

---

## Severity rubric

Severity = **Impact × Likelihood**. Reason about both axes explicitly; never assign
severity from the failure category alone.

**Impact** — blast radius if it happens:
- *Critical*: data loss/corruption, security breach, money loss, full outage, safety issue.
- *High*: broken core feature, partial outage, wrong results users act on.
- *Medium*: degraded UX, recoverable error, wrong results in a non-critical path.
- *Low*: cosmetic, rare inconvenience, internal-only.

**Likelihood** — how plausibly it triggers in real use:
- *Likely*: normal inputs/usage hit it, or an attacker is clearly motivated and unblocked.
- *Possible*: needs a specific-but-realistic condition or some attacker effort.
- *Unlikely*: needs a rare combination or significant effort/access.

**Severity matrix:**

| Impact ↓ / Likelihood → | Likely   | Possible | Unlikely |
|-------------------------|----------|----------|----------|
| Critical                | Critical | Critical | High     |
| High                    | Critical | High     | Medium   |
| Medium                  | High     | Medium   | Low      |
| Low                     | Medium   | Low      | Low      |

---

## Finding structure

Present findings ordered by severity (Critical first). Use this shape for each one:

```
### [SEVERITY] <short title>   (taxonomy: <ID>)

- **Where:** file:line, component, spec section, or prompt region.
- **What:** the weakness, in one or two sentences.
- **Failure scenario:** concrete inputs/conditions → the wrong outcome. Be specific
  enough that a reader could reproduce or picture it. This is the heart of the finding.
- **Impact / Likelihood:** <Critical/High/Medium/Low> / <Likely/Possible/Unlikely> — one
  line of justification for each axis.
- **Evidence:** the code snippet, spec quote, log line, or test result that grounds this.
  If unverified, say so and mark confidence.
- **Recommendation:** the smallest change that removes or mitigates the risk. Point to a
  test that would catch a regression.
- **Confidence:** Confirmed (observed/reproduced) | Probable (strong reasoning, not run)
  | Speculative (worth checking).
```

Keep speculative findings clearly separated from confirmed ones. A wall of low-confidence
"maybes" erodes trust in the whole report — surface the ones that matter.

---

## Report envelope

Wrap the findings with a short top and tail:

```
## Adversarial review — <artifact name>

**Scope:** what was examined (and, honestly, what was NOT).
**Dimensions covered:** e.g. FUNC, SEC, RES.
**Headline:** the single most important thing the reader must know, in one sentence.

### Findings
<severity-ordered findings>

### Summary
- Counts by severity (e.g. 2 Critical, 3 High, 5 Medium).
- The 1–3 things to fix first, and why.
- Blind spots: what this pass could not cover and would need next (a dimension not run,
  a claim not verified, a file not read). Never let silence imply full coverage.
```

---

## Principles

- **Concrete over abstract.** "Fails" is useless; "with `qty=0` the discount loop divides
  by zero and 500s" is actionable.
- **No silent caps.** If you sampled, stopped at top-N, or skipped a dimension, say so in
  Blind spots. Truncation dressed as completeness is a lie.
- **Prioritize ruthlessly.** The reader fixes top-down. Rank by severity, then by
  cheapness of the fix.
- **Every finding earns its place.** Merge duplicates, drop the trivial, keep what changes
  what the reader does next.

---

## Beyond the terminal

Findings are authored once in the structure above. To also persist them to a file, render a
navigable HTML artifact, or post them as inline PR comments, see
[output-channels.md](output-channels.md) — those channels re-render this same content without
changing it. The terminal (Markdown) channel is always the default.
