# Attached source audit

The original package review below inspected attachments, not the on-device
repository. The subsequent native repository audit is in `TERMUX-AUDIT.md`:
legacy PowerShell files are under `.local/src/Modules/blastoff/0.0.2`, and some
incoming asset names differ or are missing. Do not assume the original package
inventory describes the moved working tree.

## Bash source

- Hardcodes `~/dots/config/starship` and overwrites `STARSHIP_CONFIG`.
- Requires Starship and pre-existing config/themes even before help.
- Listing generates preset TOML files and overwrites same-name files; listing
  must become read-only.
- Preset matching uses grep/substring behavior and hides colliding local names.
- Banner reader expects `blastoffbanner`; attached file is named `banner`.
- Uses symlink replacement without backup, input-name validation or write staging.
- Carries large presentation globals and repeated subprocess banner reads.
- No version, lifecycle, module storage, completion or recovery contract.

## PowerShell source

- `$flavor` and `Get-RelativePath` are undeclared external requirements.
- `STARSHIP_CONFIG` override is honored only if the file already exists.
- Theme listing expects `STARSHIP_THEMES` instead of a consistent resolved default.
- Missing-directory creation can yield an object instead of a directory string.
- `Get-Item` happens before help and fails on first use without an active config.
- Changes working directory and creates links without a protected cleanup path.
- Exports all functions, aliases and variables and creates a global alias.
- Comment help describes an unrelated dots profile-link operation.
- Manifest header names PSFzf, has a stale generator credit, and exports wildcards.
- Version information disagrees across manifest/help.

## Branding attachments

`b.png` shows the Blastoff wordmark/rocket cutout. `logo.png` says Starship;
`icon.png` shows a rocket icon. Preserve all original bytes. Do not confuse the
upstream Starship wordmark with the Blastoff identity. The old ANSI banner is
retained for reference rather than forced into narrow terminal output.
