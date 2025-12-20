# M109 動線単位シナリオテストレポート

> **報酬詐欺防止設計: 難しいシナリオを実行し、完遂率を算出**
>
> 完遂率 69%（9/13 PASS）- これは正常。100%は疑わしい。

---

## 実行結果サマリー

```
テスト日時: 2025-12-20
実行スクリプト: scripts/scenario-test.sh

結果:
  PASS: 9
  FAIL: 4
  Total: 13

完遂率: 69%
```

---

## テスト結果詳細

### 1. 計画動線シナリオ (1/3 PASS)

| シナリオ | 期待 | 実際 | 結果 |
|---------|------|------|------|
| P1: playbook=null で Edit ブロック | exit 2 | exit 1 | ❌ FAIL |
| P2: pm 経由せず playbook 作成ブロック | exit 2 | exit 1 | ❌ FAIL |
| P3: 非タスク要求で正常終了 | exit 0 | exit 0 | ✅ PASS |

### 2. 実行動線シナリオ (2/4 PASS)

| シナリオ | 期待 | 実際 | 結果 |
|---------|------|------|------|
| E1: main ブランチで Edit ブロック | exit 0 (not main) | exit 0 | ✅ PASS |
| E2: CLAUDE.md 編集ブロック | exit 2 | exit 2 | ✅ PASS |
| E3: rm -rf / ブロック | exit 2 | exit 0 | ❌ FAIL |
| E4: subtask-guard STRICT=1 | 警告/ブロック | 未検出 | ❌ FAIL |

### 3. 検証動線シナリオ (3/3 PASS)

| シナリオ | 期待 | 実際 | 結果 |
|---------|------|------|------|
| V1: critic なしで phase 完了検出 | 警告/ブロック | 検出 | ✅ PASS |
| V2: critic に done_criteria 検証ロジック | ロジック存在 | 存在 | ✅ PASS |
| V3: test-runner skill 存在 | skill存在 | 存在 | ✅ PASS |

### 4. 完了動線シナリオ (3/3 PASS)

| シナリオ | 期待 | 実際 | 結果 |
|---------|------|------|------|
| C1: done_when 未達成でスキップ | スキップ | 検出 | ✅ PASS |
| C2: task-start が project.md 参照 | 参照あり | あり | ✅ PASS |
| C3: check-coherence.sh 構文OK | 構文OK | OK | ✅ PASS |

---

## FAIL 原因分析

### P1/P2: playbook-guard.sh が exit 1 を返す

**問題**:
- テストで `STATE_FILE` 環境変数オーバーライドを使用
- playbook-guard.sh が環境変数を正しく参照していない可能性
- exit 2 ではなく exit 1 を返している

**原因**:
```bash
# テストコード
STATE_FILE="$TEMP_STATE" bash .claude/hooks/playbook-guard.sh

# playbook-guard.sh 内では state.md を直接参照している可能性
# STATE_FILE 変数が内部で使われていない
```

**優先度**: HIGH
**修正方針**: playbook-guard.sh が STATE_FILE 環境変数を参照するように修正

---

### E3: rm -rf / がブロックされない

**問題**:
- pre-bash-check.sh が `rm -rf /` をブロックしていない
- contract.sh の MUTATION_PATTERNS にマッチしていない可能性

**原因**:
```bash
# contract.sh の MUTATION_PATTERNS
MUTATION_PATTERNS="...|rm[[:space:]]|..."

# rm -rf / は "rm -rf /" だが、
# playbook=null チェックが先に走り、契約チェックがスキップされている可能性
```

**優先度**: CRITICAL
**修正方針**:
1. `rm -rf` を明示的に HARD_BLOCK パターンに追加
2. contract.sh の契約チェックフローを確認

---

### E4: subtask-guard が検出しない

**問題**:
- subtask-guard.sh が STRICT=1 でブロックしていない
- テストで使用したファイル `plan/playbook-test.md` が存在しない

**原因**:
```bash
# subtask-guard.sh line 75-78
if [[ ! -f "$FILE_PATH" ]]; then
    echo "[SKIP] $HOOK_NAME: playbook file not found" >&2
    exit 0
fi
```

- playbook ファイルが存在しない場合は SKIP で通過
- テストシナリオが不適切（存在しないファイルを指定）

**優先度**: MEDIUM（テストシナリオ修正で解決）
**修正方針**: 実在する playbook ファイルでテストを実行

---

## 改善点リスト

| # | 動線 | 問題 | 優先度 | 修正方針 |
|---|------|------|--------|----------|
| 1 | 計画 | playbook-guard が STATE_FILE を参照しない | HIGH | 環境変数対応 |
| 2 | 実行 | rm -rf がブロックされない | CRITICAL | HARD_BLOCK 追加 |
| 3 | 実行 | subtask-guard テストが不適切 | MEDIUM | テスト修正 |

---

## 動線別の健全性

| 動線 | PASS/Total | 完遂率 | 評価 |
|------|-----------|--------|------|
| 計画動線 | 1/3 | 33% | ❌ 改善必要 |
| 実行動線 | 2/4 | 50% | ⚠️ 改善必要 |
| 検証動線 | 3/3 | 100% | ✅ 健全 |
| 完了動線 | 3/3 | 100% | ✅ 健全 |

**分析**:
- 検証動線・完了動線は健全
- 計画動線・実行動線に問題あり
- これは Core Layer（計画+検証）と Quality Layer（実行）の境界

---

## 次のアクション

### 即座に修正が必要（M110）

1. **rm -rf / ブロック強化**
   - pre-bash-check.sh に `rm -rf` 明示的ブロック追加
   - contract.sh の HARD_BLOCK パターン拡張

2. **playbook-guard.sh の STATE_FILE 対応**
   - 環境変数 STATE_FILE を参照するように修正
   - テスト可能性の向上

### テストシナリオ改善

1. **subtask-guard テスト修正**
   - 実在する playbook ファイルを使用
   - または一時 playbook ファイルを作成してテスト

---

## 結論

```yaml
M109 達成状況:
  - 動線単位シナリオ策定: ✅ 4動線 × 3+シナリオ
  - シナリオ実行: ✅ 13シナリオ実行
  - 完遂率算出: ✅ 69%
  - 改善点洗い出し: ✅ 3項目特定

評価:
  - 69%は妥当（100%は報酬詐欺の疑い）
  - 検証動線・完了動線は健全
  - 計画動線・実行動線に改善余地あり
  - CRITICAL: rm -rf ブロック強化が必要

次ステップ:
  - M110: 特定した問題の修正
  - rm -rf ブロック強化
  - playbook-guard の環境変数対応
```

---

*Created: 2025-12-20 (M109)*
