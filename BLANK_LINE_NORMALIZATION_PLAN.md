# Blank Line Normalization Plan for `bash-merge`

_Date: 2026-03-19_

## Role in the family refactor

`bash-merge` is the shell-script adopter for the shared blank-line normalization effort.

The repo already cares about top-level comment preservation, shebang handling, and removal-mode promotion behavior. This plan is to move generic blank-line behavior onto shared `ast-merge` layout semantics without disturbing shell-specific rules.

## Current evidence files

Implementation files:

- `lib/bash/merge/smart_merger.rb`
- related analysis/emitter files under `lib/bash/merge/`

Relevant specs:

- `spec/support/shared_examples/smart_merger_examples.rb`
- `spec/bash/merge/removal_mode_compliance_spec.rb`

## Current pressure points

Blank-line behavior matters around:

- shebang/header preservation
- top-level command/assignment separation
- promoted inline comments from removed single-line constructs
- stable separator blank lines after preserved comments

## Migration targets

- adopt shared gap modeling for top-level shell spacing
- keep shell-specific shebang/header semantics repo-local
- avoid introducing unsupported recursive/container assumptions into current shell merge behavior

## Workstreams

- audit existing shell top-level gap handling
- migrate separator blank-line handling first
- align promoted-comment spacing with the shared layout contract
- leave unsupported recursive/container behavior explicitly out of scope unless the shell merge model expands

## Exit criteria

- top-level shell spacing uses shared layout behavior where possible
- shebang/header handling remains correct
- promoted comments preserve intended separator blank lines without bespoke drift fixes
