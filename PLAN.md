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

## Latest `ast-merge` Comment Logic Checklist (2026-03-13)
- [x] Shared capability plumbing: `comment_capability`, `comment_augmenter`, normalized region/attachment access
- [x] Document boundary ownership: shebang/prelude/postlude analysis ownership plus merge/emitter parity for comment-only files
- [x] Matched-node fallback: preserve destination leading comments for template-preferred functions/assignments
- [x] Removed-node preservation: keep/promote comments for removed destination-only shell nodes when removal is enabled
- [x] Conservative inline/fixture parity: safe command/assignment inline tracking, template-preferred assignment inline fallback, removed-node inline promotion, and exact-output shared regressions

Current parity status: complete for the conservative Phase 2 scope, including safe boundary, leading-comment, removed-node, and safe inline-comment coverage; broader shell-inline heuristics remain intentionally out of scope.
Next execution target: optional future expansion only if needed for more complex shell syntax (here-docs, continuations, ambiguous quoting), keeping the current conservative guarantees intact.

## Execution Backlog

## Progress
- 2026-03-13: Local workspace-path validation rechecked after modular templating gemfile normalization.
- Replaced direct local `path:` overrides in modular templating gemfiles with the shared `nomono` local-override pattern and reran the full `bash-merge` suite in workspace mode; the suite remains green with the existing backend-availability pending examples only.
- 2026-03-13: Phase 2 / Slice 3 completed.
- Tightened `Bash::Merge::CommentTracker` inline `#` detection so safe command/assignment inline comments are tracked while quoted `#` false positives stay ignored.
- Added backend-shared file-analysis regressions for conservative inline attachment exposure and quoted-hash avoidance.
- Added backend-shared exact-output smart-merger regressions for safe inline command preservation, matched template-preferred assignment inline fallback, template-inline preference, and removed destination-only inline-comment promotion.
- Taught `Bash::Merge::SmartMerger` to preserve destination inline comments for safe matched single-line assignments when template content wins, and to promote safe destination-only inline comments when removal is enabled.
- Revalidated focused `comment_tracker_spec`, `file_analysis_spec`, and `smart_merger_spec`, then revalidated the full `bash-merge` suite under `KETTLE_RB_DEV=/home/pboling/src/kettle-rb` (`420 examples, 0 failures, 99 pending` focused; `637 examples, 0 failures, 99 pending` full).
- 2026-03-13: Phase 2 / Slices 1-2 completed.
- Switched `gemfiles/modular/tree_sitter.gemfile` to the shared `nomono` local-path pattern and added `gemfiles/modular/tree_sitter_local.gemfile`, fixing sibling `ast-merge` / `tree_haver` resolution for `KETTLE_RB_DEV=/home/pboling/src/kettle-rb` workspace runs.
- Updated the focused file-analysis expectations so the first owner’s leading comments are treated as attachments rather than duplicated document preamble.
- Taught `Bash::Merge::SmartMerger` to preserve shebang/header/footer/comment-only document boundaries, matched template-preferred leading comment fallback, and removed destination-only node comment promotion while keeping node bodies removable.
- Added backend-shared exact-output smart-merger regressions for document boundaries, matched function/assignment leading comments, and removed-node comment preservation.
- Revalidated focused `comment_tracker_spec`, `file_analysis_spec`, and `smart_merger_spec`, then revalidated the full `bash-merge` suite under `KETTLE_RB_DEV=/home/pboling/src/kettle-rb`.
- 2026-03-11: Phase 2 / Slice 1 started.
- Added shared comment capability plumbing in `Bash::Merge::FileAnalysis` (`comment_capability`, `comment_nodes`, `comment_node_at`, `comment_region_for_range`, `comment_attachment_for`, `comment_augmenter`).
- Extended `Bash::Merge::CommentTracker` with shared region/attachment/augmenter helpers and compatibility fallback objects when newer `ast-merge` comment classes are unavailable.
- Added backend-shared file-analysis regressions for shared comment capability exposure and document-boundary prelude/postlude regions.
- Validated focused FileAnalysis/comment-tracker specs under current local backend availability.
- The earlier Slice 1 merge-path gap is now closed; any remaining work is focused on conservative inline-comment handling.

### Slice 1 — Safe document and prologue support
- Add `comment_capability`, `comment_augmenter`, and document-boundary region support.
- Preserve shebangs, header comments, footer comments, and comment-only files.
- Add focused specs for file-level behavior before attempting inline comment support.

### Slice 2 — Leading comments for matched and removed nodes
- Preserve leading comments for matched functions and assignments when template-preferred nodes win.
- Preserve comments for removed destination-only functions and assignments when removal is enabled.
- Add focused smart-merger and emitter regressions using simple, safe shell shapes.

### Slice 3 — Conservative inline comments + fixtures
- Add safe inline-comment handling only for clearly understood command/assignment forms. ✅
- Avoid broad heuristics for here-docs, complex expansions, or ambiguous quoting in the first pass. ✅
- Promote high-value safe cases into reproducible exact-output shared regressions. ✅

## Dependencies / Resume Notes
- Start in `lib/bash/merge/file_analysis.rb` and any existing comment tracker implementation.
- Use `psych-merge` as the model for boundary and removed-node behavior, not for syntactic comment detection.
- Inline-comment support should be gated behind proven low-risk shapes.

## Exit Gate For This Plan
- Shebangs, document-level comments, and leading comments for matched/removed shell nodes are preserved safely.
- Inline comment support exists only where correctness is well understood.
