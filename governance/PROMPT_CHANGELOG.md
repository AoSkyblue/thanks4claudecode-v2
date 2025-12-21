# Prompt Changelog

> Change log for CLAUDE.md (Frozen Constitution)
> All changes to CLAUDE.md MUST be recorded here.

---

## [Unreleased] - Planned: 2.0.0 (Final Freeze)

### Pending (requires Change Control)

- **Version bump**: 1.1.0 → 2.0.0
- **Status**: Deep Audit Complete, Repository Frozen

### Deep Audit Summary (M150-M155)

| Milestone | Scope | Files | Status |
|-----------|-------|-------|--------|
| M150 | 計画動線 | 7 | ✅ Completed |
| M151 | 検証動線 | 5 | ✅ Completed |
| M152 | 実行動線 | 10 | ✅ Completed |
| M153 | 完了+共通+横断 | 16 | ✅ Completed |
| M154 | Spec Sync | - | ✅ Completed |
| M155 | Final Freeze | - | 🔄 In Progress |

### Freeze Policy

```yaml
Core Layer (12 components):
  status: Frozen
  changes: bugfix_only
  process: Codex review required

Extension Layer (26 components):
  status: Active
  changes: allowed with review
```

---

## [1.1.0] - 2025-12-18

### Added
- Core Contract section (Section 11)
- Admin Mode Contract section (Section 12)

### Changed
- Clarified that admin mode does NOT bypass Golden Path, Playbook Gate, or HARD_BLOCK
- Added explicit list of what admin CAN and CANNOT bypass

### Rationale
M079 revealed ambiguity about admin mode scope. This change makes it explicit that certain core protections are never bypassable, even in admin mode.

## [1.0.0] - 2025-12-18

### Added
- Initial frozen constitution for Claude (CLAUDE.md)
- 10 sections covering principles, constraints, quality bar, workflow
- Change Control section (Section 10)
- Version history tracking

### Changed
- Reduced from 648 lines to 215 lines
- Extracted all procedures to RUNBOOK.md
- Removed volatile content (specific milestones, tool details)

### Governance Added
- `governance/PROMPT_CHANGELOG.md` (this file)
- `scripts/lint_prompts.py` for automated validation
- `.github/workflows/prompt-lint.yml` for CI enforcement
- `eval/` directory for regression tests

### Rationale
The previous CLAUDE.md was too long (648 lines), contained volatile information that required frequent updates, and had no change control mechanism. This refactor establishes CLAUDE.md as a stable "constitution" that changes rarely, with procedures moved to RUNBOOK.md which can evolve freely.

---

## Template for Future Changes

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New section or rule

### Changed
- Modification to existing content

### Removed
- Deleted content

### Rationale
Why this change was necessary.

### Risk Assessment
Potential impacts of this change.

### Verification
How to verify this change works correctly.
```
