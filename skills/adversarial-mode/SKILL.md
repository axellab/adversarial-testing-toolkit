---
name: adversarial-mode
description: >
  Toggle persistent Adversarial Testing mode on or off for this project. When ON, every
  assistant response gains a structured "how this can fail" red-team section automatically
  (enforced by a deterministic hook). Use when the user says things like "adversarial mode
  on/off", "activá el modo adversarial", "turn on red-team mode", or asks the current
  state. Accepts: on | off | status (default: toggle/report).
---

# Adversarial Mode toggle

This skill turns the persistent adversarial mode on or off by managing a state file that
the `adversarial-mode.ps1` UserPromptSubmit hook reads. The hook does the actual per-turn
injection; this skill only flips the switch.

## State file

`<project>/.claude/state/adversarial-mode.on`
- **Present** → mode ON. Its contents (optional) are extra per-project config appended to
  the injected instruction (e.g. focus dimensions or intensity).
- **Absent** → mode OFF.

## What to do

Parse the argument (`on`, `off`, `status`, or focus hints). Then:

### `on`
1. Ensure the directory exists and create the state file. Optionally write focus config
   into it if the user specified dimensions (e.g. "focus on security and resilience") or an
   intensity.

   PowerShell:
   ```powershell
   $dir = ".claude/state"
   if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
   Set-Content -Path "$dir/adversarial-mode.on" -Value "" -Encoding utf8
   ```
   Bash:
   ```bash
   mkdir -p .claude/state && : > .claude/state/adversarial-mode.on
   ```
2. Confirm to the user: mode is ON, what it does (every response now ends with a red-team
   section), any focus set, and how to turn it off (`/adversarial-mode off`).
3. Note the caveat: the per-turn injection is done by the toolkit's `UserPromptSubmit` hook
   (shipped in the plugin's `hooks/hooks.json`). It only runs when the plugin is installed and
   enabled; if it was just installed, a Claude Code restart may be needed for the hook to load.
   The state file is per-project, so the mode is scoped to the current project.

### `off`
1. Remove the state file:
   ```powershell
   Remove-Item ".claude/state/adversarial-mode.on" -ErrorAction SilentlyContinue
   ```
   ```bash
   rm -f .claude/state/adversarial-mode.on
   ```
2. Confirm mode is OFF.

### `status` (or no clear argument)
Check whether the state file exists and report ON/OFF plus any focus config. If the intent
is ambiguous, report status and ask whether to toggle.

## Notes

- This only changes behavior for the current project (state and hook are project-scoped).
- The mode adds analysis to normal answers; it does not replace them. For a standalone
  critique of one artifact, use `/redteam` instead.
- Respond in the user's language.
