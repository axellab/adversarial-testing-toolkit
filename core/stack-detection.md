# Stack Detection

Before generating or running tests, or tailoring an audit, detect the project's stack
instead of assuming one. This file is the shared procedure every test-oriented agent
follows so behavior is consistent across the toolkit.

**Rule:** detect, then adapt. Never hardcode a framework. Never invent a test command —
discover the real one. If detection is ambiguous, state what you found and ask the user
rather than guessing.

---

## Detection procedure

Work top-down; stop when you have enough to act.

1. **Manifest & lockfiles** — identify language and package manager:
   - `package.json` (+ `pnpm-lock.yaml` / `yarn.lock` / `package-lock.json`) → JS/TS.
   - `pyproject.toml` / `setup.py` / `requirements.txt` / `Pipfile` → Python.
   - `*.csproj` / `*.sln` / `Directory.Build.props` → .NET / C#.
   - `go.mod` → Go. `Cargo.toml` → Rust. `pom.xml` / `build.gradle` → JVM.
   - `Gemfile` → Ruby. `composer.json` → PHP.

2. **Test framework** — infer from dependencies and config, then confirm:
   - JS/TS: `jest`, `vitest`, `mocha`, `@playwright/test`, `cypress`, `node:test`.
   - Python: `pytest`, `unittest`, `nose`; look at `pytest.ini` / `tox.ini` / `pyproject`.
   - .NET: `xunit`, `nunit`, `mstest`.
   - Go: standard `testing` + `go test`. Rust: `#[test]` + `cargo test`. JVM: JUnit/TestNG.

3. **Test command** — find the real one, don't assume:
   - Read `scripts.test` in `package.json`, `[tool.*]` sections, `Makefile` targets,
     CI configs (`.github/workflows/*`, `.gitlab-ci.yml`, `azure-pipelines.yml`).
   - CI files are the most reliable source of the canonical build/test/lint invocation.

4. **Existing test conventions** — read a few existing tests before writing new ones:
   - Directory layout (`__tests__/`, `tests/`, `test/`, `*.spec.ts`, `*_test.go`).
   - Naming, assertion style, fixture/mock patterns, setup/teardown helpers.
   - Factory/builder utilities already in the repo — reuse them.

5. **Runtime & boundaries** — note what shapes the risk surface:
   - HTTP framework, DB/ORM, message queue, external APIs, auth mechanism.
   - Whether it's a library, service, CLI, frontend, or LLM-powered app (look for
     `openai`/`@anthropic-ai`/`langchain`/prompt files → apply the LLM dimension).

---

## Adapting output to the stack

- **Match existing conventions.** New tests must look like the repo's tests: same runner,
  same assertion library, same file placement, same mocking approach. Consistency beats
  personal preference.
- **Use the project's own tooling.** Run the discovered test/lint/typecheck commands;
  don't introduce a new framework or dependency without asking.
- **Respect isolation.** Don't let generated tests hit real networks, real DBs, or real
  paid APIs unless the repo's tests already do and the user is fine with it. Prefer the
  project's established mocking/fixture strategy.
- **Windows-aware.** This toolkit's author runs Windows/PowerShell. Prefer cross-platform
  invocations; when shelling out, remember paths and separators differ.

---

## When detection fails

If you can't confidently determine the framework or command:
- Report exactly what you found and what's missing.
- Propose the most likely command and ask the user to confirm before running.
- Never fabricate a passing test run — if you couldn't execute, say the tests were
  generated but not run, and why.
