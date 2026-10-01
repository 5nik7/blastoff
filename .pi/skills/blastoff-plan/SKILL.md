---
name: blastoff-plan
description: Audit and plan Blastoff changes before implementation. Use for a new command, architecture change, legacy migration, or rebuild integration into the Termux repository.
---
# Plan a Blastoff slice

Read `../../../AGENTS.md`, then read
`../../../docs/PROGRAMMING-PREFERENCES.md`, `CLI-CONTRACT.md`,
`IMPLEMENTATION-PLAN.md` and `STATUS.md` in the same docs directory.
Inspect Git status and existing project instructions before editing.
Inspect `.local/src` for legacy behavior and `.local/logo` for branding when relevant.
Treat those files as references; do not execute them automatically.

Identify the concrete user outcome, commands, paths and native hosts affected.
Check the shared-core decision before choosing implementation languages.
Write a bounded plan with acceptance cases for success, failure and recovery.
Keep explicit user preferences separate from proposed engineering choices.
Carry forward pending native Termux, Windows, shell and interactive gates.

Resolve ordinary reversible choices from project instructions. Ask only when a
missing decision prevents safe progress. Continue independent read-only work.
Do not run real installation, live-config mutation, profile/PATH edits or Git
publication during planning. A plan prompt is not an enforced permission mode.

Deliver the plan, unresolved decisions and the first useful implementation slice.
