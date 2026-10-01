---
name: blastoff-parity
description: Maintain the same Blastoff behavior across Bash and native PowerShell, with Bash/Zsh/Fish completions. Use for argument forwarding, output, exit status, picker, shell integration or performance changes.
---
# Keep entry points aligned

Read `../../../docs/CLI-CONTRACT.md` and `../../../docs/STATUS.md`.
Keep application logic in `../../../lib/blastoff.py`; wrappers only resolve
that core/runtime and forward arguments. Keep old aliases explicit and bounded.

Compare help/version, JSON, usage errors, paths with spaces/quotes/Unicode,
missing dependencies, nonempty config overrides, valid mutations, failures and
cancellation. Verify stdout/stderr and PowerShell `$LASTEXITCODE` as well as the
Bash process code. Test native PowerShell without Bash/WSL dependencies.
Run `../../../tests/parity.ps1` on a native PowerShell host.

Keep JSON, pipes and completion free of decoration. Honor NO_COLOR.
Keep fzf/gum optional and offer a numbered interactive fallback; cancellation
must leave files untouched. Do not execute Starship/custom commands in previews.
Complete static commands/options and local filenames without launching Blastoff,
Starship, services or network requests. Validate in each actual target shell,
including fzf-tab behavior and argument positions; syntax checks alone are partial.

Measure wrapper and core startup separately using
`../../../scripts/benchmark.py`. Record host/runtime/sample count and p50/p95.
Do not substitute Linux results for native Termux or Windows results.
Report parity findings and pending host/interactive checks honestly.
