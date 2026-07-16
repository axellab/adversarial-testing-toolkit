# Failure Taxonomy

The shared catalogue of failure modes every agent and skill in this toolkit reasons
against. When you analyze an artifact (code, spec, plan, prompt, or running system),
walk the relevant dimensions below and ask, for each entry, *"can this happen here, and
what would it cost?"* Cite the taxonomy id (e.g. `SEC-03`) in findings so reports stay
consistent and deduplicable.

This file is descriptive, not exhaustive. Treat each list as a prompt for thinking, not a
checklist to blindly tick. A finding that fits no id still counts — record it and note
`id: NEW`.

---

## FUNC — Functional correctness

- **FUNC-01 Boundary values** — off-by-one, empty collections, zero, negative, max int,
  first/last element, single-element vs many.
- **FUNC-02 Invalid & malformed input** — wrong types, nulls/undefined, NaN, encoding
  issues, oversized payloads, unexpected shapes.
- **FUNC-03 State & ordering** — operations run out of order, double submission, re-entrancy,
  stale reads, actions on deleted/expired entities.
- **FUNC-04 Idempotency** — retries produce duplicates; the same request applied twice
  changes state twice.
- **FUNC-05 Error handling** — swallowed exceptions, wrong error surfaced, partial writes
  left uncommitted, cleanup skipped on the failure path.
- **FUNC-06 Contract drift** — caller and callee disagree on units, nullability, ranges,
  enum values, or side effects; API and docs disagree.
- **FUNC-07 Rounding & precision** — float money, locale decimals, truncation, cumulative
  drift, currency/unit mismatches.
- **FUNC-08 Time & timezones** — DST, leap years/seconds, UTC vs local, clock skew,
  expiry boundaries, date parsing ambiguity.
- **FUNC-09 Concurrency correctness** — race conditions, lost updates, non-atomic
  read-modify-write, deadlock, inconsistent caches.
- **FUNC-10 Missing / dead requirements** — a stated need with no implementation, or code
  paths no requirement covers.

## SEC — Security

- **SEC-01 Injection** — SQL/NoSQL, OS command, LDAP, XPath, template, header, log
  injection; anywhere untrusted data reaches an interpreter.
- **SEC-02 Cross-site & client-side** — XSS (stored/reflected/DOM), CSRF, clickjacking,
  open redirects, postMessage abuse.
- **SEC-03 AuthN** — weak/absent authentication, credential stuffing exposure, missing
  rate limits on login, session fixation, token replay.
- **SEC-04 AuthZ** — missing object-level checks (IDOR), privilege escalation, path
  traversal, forced browsing, confused deputy.
- **SEC-05 Secrets & crypto** — hardcoded secrets, secrets in logs/URLs, weak/rolled-own
  crypto, missing encryption in transit/at rest, predictable tokens.
- **SEC-06 Input validation & SSRF** — unvalidated URLs/redirects, SSRF, XXE, unsafe
  deserialization, file upload abuse.
- **SEC-07 Sensitive data exposure** — PII in logs/errors/responses, over-broad API
  responses, verbose stack traces, cache leakage.
- **SEC-08 Dependencies & supply chain** — known-vuln packages, unpinned versions,
  typosquat risk, unverified downloads.
- **SEC-09 Config & headers** — missing security headers, permissive CORS, debug mode in
  prod, default credentials, open ports/buckets.
- **SEC-10 Rate limiting & abuse** — no throttling on expensive/enumeration endpoints,
  resource exhaustion via API.

## RES — Resilience, reliability & performance

- **RES-01 Dependency failure** — downstream service down, slow, or returning errors;
  no timeout, no fallback, cascading failure.
- **RES-02 Timeouts & retries** — missing/infinite timeouts, retries without backoff or
  jitter, retry storms, no circuit breaker.
- **RES-03 Load & scaling** — behavior under peak/burst, N+1 queries, unbounded memory,
  connection-pool exhaustion, hot partitions.
- **RES-04 Resource leaks** — file handles, sockets, DB connections, goroutines/threads,
  memory not released on error paths.
- **RES-05 Partial failure & consistency** — one step of a multi-step operation fails;
  no compensation/saga, orphaned records, split state.
- **RES-06 Backpressure & queues** — unbounded queues, no shedding, poison messages,
  consumer lag, ordering loss.
- **RES-07 Data volume** — pagination gaps, large-result OOM, slow full scans, missing
  indexes, unbounded growth over time.
- **RES-08 Recovery & startup** — cold-start behavior, migration failures, restart under
  load, replay/idempotency of recovery.
- **RES-09 Observability gaps** — silent failures, missing metrics/logs/traces on
  critical paths, no alerting on the thing that matters.
- **RES-10 Configuration & environment** — env-specific assumptions, missing env vars,
  clock/locale/filesystem differences, feature-flag interactions.

## LLM — LLM & prompt robustness

- **LLM-01 Prompt injection** — untrusted content (web pages, files, tool output, user
  data) carrying instructions the model may obey.
- **LLM-02 Jailbreak & guardrail bypass** — role-play, encoding, many-shot, obfuscation,
  or framing that defeats safety/system instructions.
- **LLM-03 Instruction hierarchy** — user/data content overriding system intent; tool
  results treated as commands rather than data.
- **LLM-04 Data exfiltration** — model coaxed into leaking system prompt, secrets,
  context, or other users' data; markdown/image side channels.
- **LLM-05 Tool & action abuse** — model triggering destructive/irreversible tools from
  attacker-influenced input; missing confirmation gates.
- **LLM-06 Hallucination & grounding** — fabricated facts/APIs/citations, ungrounded
  claims, overconfidence, no abstention path.
- **LLM-07 Output format & contract** — invalid JSON, schema drift, unescaped output
  breaking downstream parsers, truncation.
- **LLM-08 Robustness to phrasing** — brittle behavior across paraphrases, languages,
  typos, or adversarial unicode; inconsistent answers.
- **LLM-09 Context & memory** — context-window overflow, lost-in-the-middle, stale/poisoned
  memory, cross-session bleed.
- **LLM-10 Cost, latency & loops** — runaway token use, infinite agent loops, unbounded
  fan-out, no budget/step ceilings.

## PLAN — Specs, plans & requirements (for spec-driven work)

- **PLAN-01 Ambiguity** — vague terms ("fast", "secure", "handle errors") with no
  measurable definition; multiple valid interpretations.
- **PLAN-02 Unstated assumptions** — dependencies, preconditions, or environment taken
  for granted and never verified.
- **PLAN-03 Missing requirements** — error cases, non-functional needs, edge cases, or
  entire user journeys absent from the spec.
- **PLAN-04 Conflicting requirements** — two requirements that cannot both hold; spec
  contradicts plan; plan contradicts existing system.
- **PLAN-05 Untestable acceptance criteria** — no objective way to verify "done"; success
  defined subjectively.
- **PLAN-06 Scope & sequencing risk** — tasks with hidden dependencies, big-bang steps
  with no rollback, no incremental validation.
- **PLAN-07 Interface & integration gaps** — components whose contract is undefined, data
  ownership unclear, migration/compat path missing.
- **PLAN-08 Failure & rollback planning** — no answer to "what if this step fails
  halfway"; irreversible actions without a back-out plan.
- **PLAN-09 Operational readiness** — no monitoring, on-call, capacity, or data-migration
  consideration in the plan.
- **PLAN-10 Security & privacy by design** — threat model, data classification, and
  compliance not considered before implementation.

---

## How severity is assigned

Every finding carries a severity derived from **impact × likelihood** — see
[report-format.md](report-format.md) for the exact rubric. A boundary bug in a payment
path outranks an injection risk in dead code. Always reason about both axes; never label
severity by category alone.
