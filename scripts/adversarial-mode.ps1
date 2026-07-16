# Adversarial persistent-mode hook (UserPromptSubmit)
#
# When adversarial mode is ON, this hook injects an instruction so that EVERY assistant
# response appends a structured "How this can fail" section. The mode is toggled by the
# /adversarial-mode skill, which writes/removes the state file this hook reads. Registered in
# hooks/hooks.json.
#
# State lives in the user's PROJECT (per-project mode): <project>/.claude/state/adversarial-mode.on
# The project dir comes from $env:CLAUDE_PROJECT_DIR (set for plugin hooks); we fall back to the
# cwd field on stdin, then to the process working directory.
#
# Protocol: reads the hook payload as JSON on stdin, emits additionalContext as JSON on stdout,
# exits 0. Any failure exits 0 silently so it can never block the user's prompt.

$ErrorActionPreference = 'Stop'

try {
    $raw = [Console]::In.ReadToEnd()

    # Resolve the project directory: env var first (most reliable under plugins), then stdin cwd.
    $proj = $env:CLAUDE_PROJECT_DIR
    if (-not $proj -and $raw) {
        try { $proj = ($raw | ConvertFrom-Json).cwd } catch { $proj = $null }
    }
    if (-not $proj) { $proj = (Get-Location).Path }

    $stateFile = Join-Path $proj '.claude/state/adversarial-mode.on'
    if (-not (Test-Path $stateFile)) {
        exit 0   # mode off: inject nothing
    }

    # Optional per-project focus/intensity stored in the state file (plain text).
    $config = ''
    try { $config = (Get-Content $stateFile -Raw -ErrorAction SilentlyContinue) } catch {}

    $instruction = @"
[ADVERSARIAL MODE: ON]
The user has enabled persistent adversarial testing. In addition to fully answering the
request above, you MUST end your response with a clearly separated section titled
"## Adversarial review — how this can fail".

In that section, red-team whatever you just produced or were asked to produce (plan, code,
design, spec, prompt, or claim), using the adversarial-testing toolkit's shared knowledge:
- Think like a red team; look for the failure modes in the toolkit's failure taxonomy and
  cite their ids; report per its report format (severity = Impact x Likelihood, concrete
  scenarios, confidence labels). The shared core/*.md files are at the path published by the
  toolkit's SessionStart hook (see the injected core path, or ./core in dev mode).
- Prioritize the few findings that actually matter; do not pad with cosmetic maybes.
- Pair the top findings with the cheapest fix and a regression test.
- Be honest about blind spots; never imply coverage you did not do.
- Write this section in the language the user is speaking. Keep taxonomy ids/severities in English.
- This is analysis only: never perform real attacks or exfiltrate data.
$config
"@

    $out = @{
        hookSpecificOutput = @{
            hookEventName     = 'UserPromptSubmit'
            additionalContext = $instruction
        }
    } | ConvertTo-Json -Depth 5 -Compress

    Write-Output $out
    exit 0
}
catch {
    exit 0
}
