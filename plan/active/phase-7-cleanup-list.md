# Phase 7 成果物: 不要ファイル選定と削除計画

> **playbook-current-implementation-redesign Phase 7**
>
> 日時: 2025-12-09
> 目的: 削除しても仕組みが動くファイルを特定し、削除計画を作成

---

## 1. 現在のファイル構成

### 1.1 .archive/ 内のファイル

| ファイル | サイズ | 状態 | 削除可否 |
|---------|-------|------|---------|
| CONTEXT.md | 16KB | 廃止済み | ✅ 削除可 |
| CONTRIBUTING.md | 1.6KB | 貢献ガイド | ⚠️ 保留 |
| QUICKSTART.md | 1.7KB | クイックスタート | ⚠️ 保留 |
| file-dependencies.yaml | 5.5KB | 古い依存関係定義 | ✅ 削除可 |
| requirements.yaml | 11KB | 古い要件定義 | ✅ 削除可 |
| spec.yaml | 95KB | 古い仕様（廃止） | ✅ 削除可 |

### 1.2 .archive/plan/ 内のファイル

| ファイル | サイズ | 状態 | 削除可否 |
|---------|-------|------|---------|
| meta-roadmap.md | 11KB | 開発履歴 | ⚠️ 保留（参考用） |
| roadmap.md | 12KB | 開発履歴 | ⚠️ 保留（参考用） |
| vision.md | 12KB | 開発履歴 | ⚠️ 保留（参考用） |
| playbook-3layer-plan.md | 7KB | 完了済み playbook | ✅ 削除可 |
| playbook-auto-clear.md | 5KB | 完了済み playbook | ✅ 削除可 |
| playbook-claude-hook-integration.md | 10KB | 完了済み playbook | ✅ 削除可 |
| playbook-claude-improvement.md | 3KB | 完了済み playbook | ✅ 削除可 |
| playbook-mechanism-completion.md | 8KB | 完了済み playbook | ✅ 削除可 |
| playbook-regression-test.md | 4KB | 完了済み playbook | ✅ 削除可 |
| playbook-rollback.md | 9KB | 完了済み playbook | ✅ 削除可 |
| playbook-system-improvements.md | 13KB | 完了済み playbook | ✅ 削除可 |
| project-dev.md | 2KB | 開発履歴 | ✅ 削除可 |
| rollback-design.md | 8KB | 設計ドキュメント | ⚠️ 保留（参考用） |
| test-history.md | 1KB | テスト履歴 | ✅ 削除可 |

### 1.3 plan/active/ 内のファイル

| ファイル | サイズ | 状態 | 削除可否 |
|---------|-------|------|---------|
| .gitkeep | 0B | 必要 | ❌ 保持 |
| phase-1-mapping.md | 16KB | Phase 成果物 | ⚠️ P8 で統合後削除 |
| phase-2-inventory.md | 20KB | Phase 成果物 | ⚠️ P8 で統合後削除 |
| phase-3-flow.md | 30KB | Phase 成果物 | ⚠️ P8 で統合後削除 |
| phase-4-justification.md | 20KB | Phase 成果物 | ⚠️ P8 で統合後削除 |
| phase-5-dependencies.md | 24KB | Phase 成果物 | ⚠️ P8 で統合後削除 |
| phase-6-recovery.md | 10KB | Phase 成果物 | ⚠️ P8 で統合後削除 |
| phase-7-cleanup-list.md | - | 本ファイル | ⚠️ P8 で統合後削除 |
| playbook-action-based-guards.md | 6KB | 完了済み | ✅ アーカイブ可 |
| playbook-consent-integration.md | 11KB | 完了済み | ✅ アーカイブ可 |
| playbook-current-implementation-redesign.md | 13KB | **進行中** | ❌ 保持 |
| playbook-implementation-validation.md | 30KB | 完了済み | ✅ アーカイブ可 |
| playbook-plan-chain.md | 8KB | 完了済み | ✅ アーカイブ可 |
| playbook-session-redesign.md | 10KB | 完了済み | ✅ アーカイブ可 |
| playbook-structure-optimization.md | 4KB | 完了済み | ✅ アーカイブ可 |
| playbook-trinity-validation.md | 99KB | 完了済み | ✅ アーカイブ可 |

### 1.4 docs/ 内のファイル

| ファイル | サイズ | 状態 | 削除可否 |
|---------|-------|------|---------|
| current-implementation.md | 56KB | **リプレース予定** | ✅ P8 で置換 |
| extension-system.md | 12KB | 公式仕様参照 | ❌ 保持 |
| test-results.md | 10KB | テスト結果 | ⚠️ 保留 |

---

## 2. 削除計画

### 2.1 即時削除可能（開発履歴、動作に影響なし）

```bash
# .archive/ 内の廃止ファイル
rm .archive/CONTEXT.md
rm .archive/file-dependencies.yaml
rm .archive/requirements.yaml
rm .archive/spec.yaml

# .archive/plan/ 内の完了済み playbook
# 注: 参考用に残す場合は削除しない
rm .archive/plan/playbook-3layer-plan.md
rm .archive/plan/playbook-auto-clear.md
rm .archive/plan/playbook-claude-hook-integration.md
rm .archive/plan/playbook-claude-improvement.md
rm .archive/plan/playbook-mechanism-completion.md
rm .archive/plan/playbook-regression-test.md
rm .archive/plan/playbook-rollback.md
rm .archive/plan/project-dev.md
rm .archive/plan/test-history.md
```

### 2.2 Phase 8 完了後に削除

```bash
# plan/active/ 内の Phase 成果物
rm plan/active/phase-1-mapping.md
rm plan/active/phase-2-inventory.md
rm plan/active/phase-3-flow.md
rm plan/active/phase-4-justification.md
rm plan/active/phase-5-dependencies.md
rm plan/active/phase-6-recovery.md
rm plan/active/phase-7-cleanup-list.md

# 完了済み playbook をアーカイブ
mv plan/active/playbook-action-based-guards.md .archive/plan/
mv plan/active/playbook-consent-integration.md .archive/plan/
mv plan/active/playbook-implementation-validation.md .archive/plan/
mv plan/active/playbook-plan-chain.md .archive/plan/
mv plan/active/playbook-session-redesign.md .archive/plan/
mv plan/active/playbook-structure-optimization.md .archive/plan/
mv plan/active/playbook-trinity-validation.md .archive/plan/
```

### 2.3 保留（参考用に残す）

```
.archive/CONTRIBUTING.md       # 貢献ガイド（将来公開時に使用）
.archive/QUICKSTART.md         # クイックスタート（将来公開時に使用）
.archive/plan/meta-roadmap.md  # 開発の経緯を知るため
.archive/plan/roadmap.md       # 開発の経緯を知るため
.archive/plan/vision.md        # 最終目標の参照
.archive/plan/rollback-design.md # ロールバック設計参照
docs/test-results.md           # テスト結果参照
```

---

## 3. 削除の根拠

### 3.1 削除可能ファイルの根拠

| ファイル | 削除根拠 |
|---------|---------|
| CONTEXT.md | CLAUDE.md + state.md + playbook に置換済み |
| file-dependencies.yaml | check-file-dependencies.sh に統合済み |
| requirements.yaml | project.md + playbook に置換済み |
| spec.yaml | extension-system.md + current-implementation.md に置換済み |
| 完了済み playbook | .archive/plan/ にすでにアーカイブ済み playbook と同等 |
| Phase 成果物 | current-implementation.md に統合される |

### 3.2 保持すべきファイルの根拠

| ファイル | 保持根拠 |
|---------|---------|
| extension-system.md | 公式仕様の真実源（復旧に必須） |
| playbook-current-implementation-redesign.md | 進行中の作業 |
| .gitkeep | ディレクトリ維持 |

---

## 4. 削除後のディレクトリ構造（期待）

```
thanks4claudecode/
├── .archive/
│   ├── .claude/                    # 古い設定
│   ├── hooks/                      # 古い Hook
│   ├── plan/
│   │   ├── active/                 # 空
│   │   ├── meta-roadmap.md         # 参考用
│   │   ├── roadmap.md              # 参考用
│   │   ├── vision.md               # 参考用
│   │   ├── rollback-design.md      # 参考用
│   │   ├── playbook-system-improvements.md  # 最新アーカイブ
│   │   └── (他の完了済み playbook)
│   ├── test/                       # 古いテスト
│   ├── CONTRIBUTING.md             # 参考用
│   └── QUICKSTART.md               # 参考用
│
├── .claude/
│   ├── agents/                     # 9 SubAgent
│   ├── commands/                   # 7 Command
│   ├── frameworks/                 # 検証フレームワーク
│   ├── hooks/                      # 21 Hook
│   ├── logs/                       # 実行ログ
│   ├── skills/                     # 9 Skill
│   ├── protected-files.txt
│   └── settings.json
│
├── docs/
│   ├── current-implementation.md   # 新版（P8 で作成）
│   ├── extension-system.md         # 公式仕様参照
│   └── test-results.md             # テスト結果
│
├── plan/
│   ├── active/
│   │   └── (進行中の playbook のみ)
│   ├── template/
│   │   └── playbook-format.md
│   └── project.md
│
├── setup/
│   └── playbook-setup.md
│
├── CLAUDE.md
├── README.md
└── state.md
```

---

## 5. 削除スクリプト

```bash
#!/bin/bash
# cleanup.sh - 不要ファイル削除

set -e

echo "=== 不要ファイル削除開始 ==="

# Phase 1: .archive/ 内の廃止ファイル削除
echo "[1/3] .archive/ 内の廃止ファイル削除..."
rm -f .archive/CONTEXT.md
rm -f .archive/file-dependencies.yaml
rm -f .archive/requirements.yaml
rm -f .archive/spec.yaml
rm -f .archive/plan/project-dev.md
rm -f .archive/plan/test-history.md

# Phase 2: 完了済み playbook を確認（削除はオプション）
echo "[2/3] 完了済み playbook 確認..."
echo "以下の playbook は削除可能ですが、参考用に残すことも可能です："
ls -la .archive/plan/playbook-*.md 2>/dev/null || true

# Phase 3: 確認
echo "[3/3] 削除完了確認..."
echo ".archive/ のサイズ:"
du -sh .archive/

echo "=== 不要ファイル削除完了 ==="
echo "Phase 8 完了後、plan/active/phase-*.md を削除してください。"
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-09 | Phase 7 完了。不要ファイルリスト、削除計画、削除スクリプトを作成。 |

---

**作成日時**: 2025-12-09
**作成者**: Claude Code（P7 実行）
**状態**: ✅ 完了、Phase 8 へ移行可能
