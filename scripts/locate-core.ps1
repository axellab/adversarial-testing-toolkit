# SessionStart hook — publishes the plugin's install path so agents/skills can find core/.
#
# Why this exists: ${CLAUDE_PLUGIN_ROOT} is substituted in hook COMMANDS but NOT inside
# agent/skill markdown bodies. Subagents also run with the user's project as their working
# directory, so they cannot reach the plugin-bundled core/*.md by a relative path. This hook
# runs once at session start (where CLAUDE_PLUGIN_ROOT and CLAUDE_PROJECT_DIR are available),
# and makes the core path discoverable two ways:
#   1. writes it to  <project>/.claude/.adversarial-testing-root  (durable, project-relative,
#      readable by any subagent), and
#   2. injects it into the session context so the main model can thread it to the auditors.
#
# Fails open (exit 0) so it can never block a session from starting.

$ErrorActionPreference = 'SilentlyContinue'

try {
    $root = $env:CLAUDE_PLUGIN_ROOT
    if (-not $root) { exit 0 }   # not running as an installed plugin: nothing to publish

    $proj = $env:CLAUDE_PROJECT_DIR
    if (-not $proj) { $proj = (Get-Location).Path }

    # 1) durable marker in the project
    $dir = Join-Path $proj '.claude'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    Set-Content -Path (Join-Path $dir '.adversarial-testing-root') -Value $root -Encoding utf8

    # 2) context injection for the main model
    $core = "$root/core"
    $ctx = @"
[adversarial-testing] The toolkit's shared reference files are installed at: $core
When any adversarial-testing agent or skill needs the shared taxonomy, report format,
adversarial mindset, stack-detection, output-channels spec, or the HTML report template,
read them from that directory. When you spawn an adversarial-testing auditor subagent, pass
it this core path so it does not have to search for it.
"@

    $out = @{
        hookSpecificOutput = @{
            hookEventName     = 'SessionStart'
            additionalContext = $ctx
        }
    } | ConvertTo-Json -Depth 5 -Compress

    Write-Output $out
    exit 0
}
catch {
    exit 0
}
