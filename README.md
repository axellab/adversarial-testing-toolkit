# Adversarial Testing Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](.claude-plugin/plugin.json)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin-8A2BE2.svg)](https://code.claude.com/docs/en/plugins)
[![Seeded-bug recall](https://img.shields.io/badge/seeded--bug%20recall-27%2F27-brightgreen.svg)](#status)
[![Hooks](https://img.shields.io/badge/hooks-PowerShell-012456.svg)](hooks/hooks.json)

A set of Claude Code **agents** and **skills** that help you find where a piece of software
will break — and prove it with tests — instead of only building it. It brings the discipline
of *adversarial testing* (the red-teaming used to break models) to apps, systems, prompts,
specs, and implementation plans, and composes with spec-driven development for an extra
quality gate.

Developed in this repo; intended to be packaged as a Claude Code plugin later.

## The idea

Most assistants answer the question. This toolkit also answers **"how does this fail?"** —
systematically, with severity, concrete scenarios, and regression tests. It does that at
three levels:

1. A persistent **adversarial mode** that appends a "how this can fail" section to every
   answer.
2. Focused **skills** for a single artifact or a single job (red-team, test plan, generate
   tests, attack a spec).
3. A heavyweight **deep audit** that fans out specialized auditors in parallel and verifies
   their findings before reporting.

## Architecture

One shared knowledge core; many thin consumers. Nothing about failure modes, severity, or
reporting is duplicated.

```
.claude-plugin/            Plugin + marketplace manifests
core/                      Single source of truth (referenced, never copied)
  failure-taxonomy.md      WHAT to look for — FUNC / SEC / RES / LLM / PLAN failure ids
  report-format.md         HOW to report — severity = Impact × Likelihood, finding structure
  output-channels.md       WHERE to send findings — terminal / file / HTML artifact / PR comments
  stack-detection.md       HOW to detect language/test framework before testing
  adversarial-mindset.md   HOW to think like a red team
  templates/               Rendering assets (audit-report.html for the HTML channel)
agents/                    Specialized subagents (one job each)
skills/                    User-invocable /commands (thin orchestration)
hooks/hooks.json           SessionStart (publish core path) + UserPromptSubmit (adversarial mode)
scripts/                   Hook scripts (PowerShell)
docs/methodology.html      Visual methodology dossier
```

### Agents

| Agent | Job |
|-------|-----|
| `redteam-critic` | Attacks any one artifact (plan/spec/code/prompt); returns only the failure analysis |
| `weakpoint-scout` | Maps functional weak points and recommends the tests worth writing |
| `test-engineer` | Detects the stack, generates tests in the repo's conventions, runs them, reports evidence |
| `security-auditor` | Attack-surface review (injection, authZ/authN, secrets, SSRF, config…) |
| `resilience-auditor` | Failure & load behavior (timeouts, retries, leaks, scaling, recovery, observability) |
| `llm-robustness-auditor` | Prompt injection, jailbreaks, exfiltration, tool abuse, grounding, robustness |

### Skills (commands)

| Command | What it does |
|---------|--------------|
| `/adversarial-mode on\|off\|status` | Toggle persistent adversarial mode (hook-enforced) |
| `/redteam <target>` | Focused adversarial critique of one plan/spec/code/prompt |
| `/test-plan <target>` | Risk-ranked plan of tests worth writing (recommend only) |
| `/generate-tests <target>` | Generate + run tests in the project's framework, with evidence |
| `/spec-attack <spec\|plan\|tasks>` | Attack Spec Kit artifacts; return findings + corrective tasks |
| `/deep-audit <target>` | Parallel multi-agent audit + adversarial verification → one ranked report |

## How the pieces fit

- **Daily use:** turn on `/adversarial-mode` and every answer carries a red-team tail. Or
  reach for `/redteam` on a specific thing.
- **Before writing code (SDD):** run `/spec-attack` on your spec/plan so ambiguities and
  missing requirements die cheap. Works with GitHub Spec Kit (`specify → plan → tasks →
  attack → implement`).
- **While building:** `/test-plan` to see the weak points, `/generate-tests` to cover them.
- **Before release / high stakes:** `/deep-audit` for a full parallel sweep with verified
  findings.

## How findings are shown

Findings are authored once in the canonical Markdown structure (`report-format.md`) and
rendered to the **terminal** by default — severity-ordered, with clickable `file:line`
links. Any finding-producing skill (`/redteam`, `/deep-audit`) can additionally route the
*same* findings to other channels on request (`--out file,html,pr` or natural language),
per `output-channels.md`:

| Channel | What you get | Confirmation |
|---------|--------------|--------------|
| Terminal | Markdown report (default, always) | — |
| File | `reports/<skill>-<date>.md` for versioning/sharing | none |
| HTML artifact | Self-contained page, filterable by severity/dimension/file | none (private to you) |
| PR comments | Inline `file:line` review comments on a GitHub PR | **explicit yes required** |

Agents only ever produce the canonical report; the *skill* routes it — so a new channel is
defined once in `core/` and inherited everywhere.

## Design principles

- **Shared core, no duplication.** Improving `core/` improves every agent at once.
- **Internal prompts in English, output in your language.** Reports respond in the language
  you speak; taxonomy ids and severities stay English as stable identifiers.
- **Concrete findings.** Every finding is a reproducible scenario with a severity and a
  paired regression test — no vibes.
- **Analyze → generate → execute.** Test skills detect the stack and run real tests; they
  never fake a passing run.
- **Safety.** Adversarial *analysis and testing* only — never real attacks, exfiltration, or
  weaponized findings.

## Install

This repo is a Claude Code plugin. Install it from the bundled marketplace:

```
/plugin marketplace add axellab/adversarial-testing-toolkit
/plugin install adversarial-testing@adversarial-testing-tools
```

Then restart Claude Code so the hooks load. After install you have `/redteam`, `/deep-audit`,
`/test-plan`, `/generate-tests`, `/spec-attack`, and `/adversarial-mode`, plus the six agents.

Validate the plugin before distributing with `claude plugin validate .`.

### Notes

- **Hooks are PowerShell** (`powershell.exe`, always present on Windows), invoked via
  `${CLAUDE_PLUGIN_ROOT}`. On PowerShell 7 or non-Windows, swap `powershell` for `pwsh` in
  `hooks/hooks.json` and keep the scripts 5.1-compatible.
- **Core-path resolution:** because `${CLAUDE_PLUGIN_ROOT}` doesn't expand inside agent/skill
  bodies, the `SessionStart` hook records the plugin's `core/` path to
  `<project>/.claude/.adversarial-testing-root` and injects it into the session; agents resolve
  the shared files from there (falling back to `./core` in dev mode). Add
  `.claude/.adversarial-testing-root` to your project's `.gitignore`.
- `/adversarial-mode` manages a per-project state file under `<project>/.claude/state/`.
- **Version:** set explicitly in `plugin.json` (bump on each release), or omit it to track the
  git SHA for auto-update. Fill in `homepage`/`repository` before publishing.

## Status

`0.1.0` — packaged as an installable Claude Code plugin, validated against a 27-bug playground
(recall 27/27 across all four dimensions). Ships six agents, six skills, and the persistent
adversarial mode.
