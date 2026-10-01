---
name: blastoff-release
description: Check Blastoff release readiness, checksums, version consistency, installation and uninstall recovery. Use before packaging, version bumps, release review or lifecycle changes.
---
# Verify a reviewable release

Read `../../../docs/IMPLEMENTATION-PLAN.md`, `STATUS.md` and
`INSTALLATION.md` from that docs directory. Inspect repository status/remotes.
Keep core version, VERSION, PowerShell manifest, man page and changelog aligned.
Verify source ownership and preserve the actual repository license.

Run isolated core/lifecycle tests and available shell/manual checks.
Run native Termux and native Windows wrapper/filesystem checks independently.
Retain pending gates; never claim fixtures, syntax or cross-builds prove them.
Review performance measurements and host-specific budgets.

Verify `--dry-run`, unowned/modified-file refusal, versioned payload integrity,
interrupted operation recovery and uninstall retention of themes/modules/backups,
active config, shell profiles and unrelated prefix files. Never use a live
installation prefix for tests.

Run `../../../scripts/package.py`, then `verify.py` in the same scripts
directory. Verify the final archives and their outer SHA-256 sums. Update help,
manual, completions, changelog, contract and evidence for changed behavior.

Deliver readiness findings and exact unresolved gates. Do not install into the
user's real prefix, commit/push, move tags or publish unless explicitly requested.
