# PLAN.md

## Goal
Bring the shared Comment AST & Merge capability into `bash-merge` so shell merges preserve comments, prologues, and function/block documentation without breaking script behavior.

`psych-merge` is the reference for the shared comment API, but `bash-merge` needs a more syntax-aware, source-augmented implementation because shell comments are easy to mis-detect.

## Current Status
- `bash-merge` is a useful target because shell scripts often depend on comments for structure and maintainability.
- The gem has the standard merge-gem layout and should stay conservative about output correctness.
- This gem is best treated as a source-augmented comment merger rather than a parser-native comment owner.
- The highest priority is safety: preserve comments only when ownership is reliable enough to avoid changing shell behavior.

## Integration Strategy
- Expose shared comment capability from file analysis and wrapped nodes.
- Use source-aware comment tracking for:
  - shebang and document prelude
  - function-leading comments
  - command / assignment comments where safe
  - document postlude and comment-only sections
- Reuse `psych-merge` behavior for matched-node comment fallback and removed-node comment promotion.
- Keep the first implementation conservative around inline comments in complex shell syntax.

## First Slices
1. Add shared comment capability plumbing and document-boundary comment support.
2. Preserve shebang, header comments, and comment-only files.
3. Preserve leading comments for matched functions and assignments when template content wins.
4. Preserve comments for removed destination-only functions or assignments when removal is enabled.
5. Expand to safe inline-comment handling after leading comments are stable.

## First Files To Inspect
- `lib/bash/merge/file_analysis.rb`
- `lib/bash/merge/node_wrapper.rb`
- `lib/bash/merge/smart_merger.rb`
- `lib/bash/merge/emitter.rb`
- any existing comment tracker under `lib/bash/merge/`

## Tests To Add First
- shebang and file-header comment specs
- smart merger specs for function and assignment comment preservation
- specs for removed-node comment promotion
- comment-only and blank-line-separated section fixtures
- later: targeted inline-comment regressions for safe shell cases

## Risks
- `#` inside quoted strings or parameter expansion must not be treated as comments.
- Here-docs and command continuations can break naive comment tracking.
- Shell readability changes can become behavior changes if whitespace or structure shifts too much.
- Inline comment support should start conservatively.

## Success Criteria
- Shared comment capability is exposed without sacrificing script safety.
- Shebangs and document-level comments remain stable.
- Leading comments for matched and removed shell nodes are preserved reliably.
- Conservative inline comment handling works for safe cases.
- Reproducible fixtures cover realistic shell comment layouts.

## Rollout Phase
- Phase 2 target.
- Recommended after the first config/data adopters because shell syntax makes comment ownership riskier.

## Execution Backlog

### Slice 1 — Safe document and prologue support
- Add `comment_capability`, `comment_augmenter`, and document-boundary region support.
- Preserve shebangs, header comments, footer comments, and comment-only files.
- Add focused specs for file-level behavior before attempting inline comment support.

### Slice 2 — Leading comments for matched and removed nodes
- Preserve leading comments for matched functions and assignments when template-preferred nodes win.
- Preserve comments for removed destination-only functions and assignments when removal is enabled.
- Add focused smart-merger and emitter regressions using simple, safe shell shapes.

### Slice 3 — Conservative inline comments + fixtures
- Add safe inline-comment handling only for clearly understood command/assignment forms.
- Avoid broad heuristics for here-docs, complex expansions, or ambiguous quoting in the first pass.
- Promote high-value safe cases into reproducible fixtures.

## Dependencies / Resume Notes
- Start in `lib/bash/merge/file_analysis.rb` and any existing comment tracker implementation.
- Use `psych-merge` as the model for boundary and removed-node behavior, not for syntactic comment detection.
- Inline-comment support should be gated behind proven low-risk shapes.

## Exit Gate For This Plan
- Shebangs, document-level comments, and leading comments for matched/removed shell nodes are preserved safely.
- Inline comment support exists only where correctness is well understood.
