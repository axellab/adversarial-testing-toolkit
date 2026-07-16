# Adversarial Testing Toolkit — repo conventions

This repo is a set of Claude Code **agents** and **skills** for testing/quality work and
**adversarial testing** (red-teaming applied to apps, systems, prompts, and implementation
plans), designed to compose with spec-driven development. It is developed here and will be
packaged as a Claude Code plugin later.

## Architecture

The design principle is **one shared knowledge core, many thin consumers**. Nothing about
failure modes, severity, or reporting is duplicated across agents.

This repo IS the plugin: components live at the plugin root (not under `.claude/`), which is
how Claude Code discovers them for a distributed plugin.

```
.claude-plugin/          Plugin + marketplace manifests.
  plugin.json            name, version, component paths.
  marketplace.json       distribution entry (install target).
core/                    Shared knowledge — the single source of truth. Referenced, never copied.
  failure-taxonomy.md    WHAT to look for (FUNC/SEC/RES/LLM/PLAN ids).
  report-format.md       HOW to report (severity rubric + finding structure).
  output-channels.md     WHERE to send findings (terminal/file/HTML artifact/PR comments).
  stack-detection.md     HOW to detect language/test framework before testing.
  adversarial-mindset.md HOW to think like a red team.
  templates/             Rendering assets (audit-report.html for the HTML channel).
agents/                  Specialized subagents (one job each). They load core/ files by reference.
skills/                  User-invocable /commands. Thin orchestration over agents + core/.
hooks/hooks.json         SessionStart (publish core path) + UserPromptSubmit (adversarial mode).
scripts/                 Hook scripts: locate-core.ps1, adversarial-mode.ps1 (PowerShell).
docs/                    methodology.html (visual dossier).
```

**Core-path resolution (plugin constraint).** `${CLAUDE_PLUGIN_ROOT}` expands in hook
*commands* but NOT in agent/skill markdown bodies, and subagents run with the user's project as
cwd — so they can't reach the plugin-bundled `core/*.md` by a relative path. The `SessionStart`
hook (`scripts/locate-core.ps1`) solves this: it writes the plugin root to
`<project>/.claude/.adversarial-testing-root` and injects the core path into the session. Agents
resolve `core/` via: (1) a path the caller passes, (2) that marker file, (3) `./core` in dev
mode. Keep new agents/skills using this resolution order — never hardcode a relative `core/`.

## Authoring rules

- **Reference the core, don't restate it.** An agent/skill points to `core/*.md` for the
  taxonomy, severity rubric, and mindset. If you find yourself pasting taxonomy text into
  an agent, stop and link instead. Improving `core/` must improve every consumer at once.
- **Internal prompts in English; output in the user's language.** All agent/skill prompt
  text and docs are English (model performance + reusability as a public plugin). Every
  agent/skill instructs the model to *write its report in the language the user speaks*.
  Taxonomy ids and severity labels stay English as stable identifiers.
- **Single responsibility.** Each agent does one kind of analysis. Each skill is one verb.
  Orchestration (fan-out, verification) lives in skills, not agents.
- **Analyze → generate → execute.** Test-producing skills detect the stack, generate tests
  in the project's own framework/conventions, run them, and report evidence. Never fake a
  run; if you couldn't execute, say so.
- **Findings are concrete.** Every finding is a reproducible scenario with a severity from
  the shared rubric and a paired regression test. No vibes.
- **Safety.** Adversarial *analysis and testing* only — never perform real attacks,
  exfiltrate real data, or weaponize findings.

## Frontmatter conventions

- Agents: `.claude/agents/<name>.md` with YAML frontmatter (`name`, `description`, `tools`,
  optional `model`). Description says *when* to use it (helps auto-delegation).
- Skills: `.claude/skills/<name>/SKILL.md` with frontmatter (`name`, `description`).
  Description starts with what it does + trigger phrases.

## Windows note

The author runs Windows 11 / Windows PowerShell 5.1 (`powershell.exe`; `pwsh` is not
installed). The hook is invoked via `powershell -NoProfile -ExecutionPolicy Bypass -File`
and the script stays 5.1-compatible (no `??`, no `pwsh`-only syntax). Keep shelled commands
cross-platform where possible.
