# Set pi up for Blastoff

This setup uses repo context, workflow skills and prompts. It needs no custom
extension, model change, provider change, global skill installation or service.
The instructions are guidance for the agent; they are not filesystem isolation
or an enforced permission boundary. Continue using isolated tests.

## 1. Keep the rebuild package separate at first

Download/extract `blastoff-rebuild-0.1.0.zip` under a staging directory, e.g.
`~/downloads`. The extracted root is `blastoff-rebuild/`.
Do not extract it blindly over the existing repository.

Verify the downloaded archive's SHA-256 against `blastoff-rebuild-0.1.0.SHA256SUMS`,
then verify its contents:

```sh
cd ~/downloads/blastoff-rebuild
python3 scripts/verify.py
python3 -m unittest discover -s tests -v
```

Python 3.11+ is required. This package does not install Python, Starship or pi.
Check availability/version using your normal package manager and `python3
--version`, `starship --version`, `pi --version`; do not infer native support
from a Linux test run. Use `py -3` in place of `python3` on Windows as appropriate.

## 2. Start pi in the actual repository

```sh
cd /data/data/com.termux/files/home/repos/blastoff
pi
```

Paste this initial task (adjust the staging path if needed):

> Read the existing repository guidance and inspect Git status first. Read
> `~/downloads/blastoff-rebuild/AGENTS.md`, its programming-preferences guide,
> CLI contract, implementation plan and status. Compare the supplied rebuild
> against `.local/src` and `.local/logo` in this repo. Preserve all unrelated
> changes and the original source/assets. Make an integration plan, then
> integrate the shared-core Bash/PowerShell implementation and pi guidance in
> bounded steps. Keep tests isolated; do not alter my active Starship config,
> install into my real prefix, edit shell profiles, commit, push or publish.
> Run the tests available on native Termux and update validation evidence.
> Keep Windows/Fish gates pending until actually run in those environments.

If the repository already has `AGENTS.md` or `.pi` files, merge useful content;
never replace existing project rules or settings without examining them.

## 3. Project files pi can use

| File | Role |
|---|---|
| `AGENTS.md` | Always-relevant project priorities, paths, safety and verification |
| `docs/PROGRAMMING-PREFERENCES.md` | Reusable explicit preferences plus labeled inferences |
| `.pi/settings.json` | Relative project resource directories, skill commands enabled |
| `.pi/skills/blastoff-plan/SKILL.md` | Audit and plan a bounded implementation slice |
| `.pi/skills/blastoff-safe-config/SKILL.md` | Implement/review config, backup and module mutations |
| `.pi/skills/blastoff-parity/SKILL.md` | Keep wrappers, output and shell completion aligned |
| `.pi/skills/blastoff-release/SKILL.md` | Verify versioned lifecycle and release readiness |
| `.pi/prompts/plan.md` | `/plan [task]` — a planning workflow, not a built-in sandbox mode |
| `.pi/prompts/implement.md` | `/implement [slice]` — implement an accepted slice |
| `.pi/prompts/review.md` | `/review [focus]` — review changes against the contract |
| `.pi/prompts/checkpoint.md` | `/checkpoint` — record state, evidence and next steps |

After integrating these project files, reload pi resources in the active session
with `/reload`. Invoke a specific skill when needed:

```text
/skill:blastoff-plan integrate the supplied rebuild
/skill:blastoff-safe-config review module-load failure behavior
/skill:blastoff-parity validate native Termux completions
/skill:blastoff-release check readiness without installing
```

Pi advertises skill metadata and loads the body when relevant; descriptions
must be specific. `/skill:name` forces loading. Prompt Markdown filenames become
slash commands. Project resource loading may require project trust in your pi
version. Inspect the files before granting trust. These resources were checked
against official pi docs on 2026-09-30; pi itself was not available for a live
startup/reload check here. Confirm discovery in your installed version.

## 4. Good everyday workflow

Use `/plan` for a new behavior or risky file change; inspect its concrete
acceptance cases. Use `/implement` for the selected slice, then `/review`.
Use `/checkpoint` before pausing or changing models/sessions. Keep the checkpoint
in docs, with exact test commands and unchecked host gates.

The prompts already tell pi to continue authorized reversible work. They do
not require repetitive approval for routine edits. Explicitly authorize a real
install, live-config change, commit/push or release when you want that action.
Do not add third-party agent extensions until a specific need justifies them.

## Official references

- Skills: https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/skills.md
- Prompt templates: https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/prompt-templates.md
- Settings: https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/settings.md
- Pi home: https://pi.dev/

These URLs may redirect as the upstream repository changes. Prefer the docs
bundled with your installed pi version when behavior differs.
