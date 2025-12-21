# playbook-m148-merge-pending-docs.md

> **MERGE予定ドキュメントの統合と削除**
>
> 3つの MERGE予定ファイルを分析し、適切に処理する。
> - 完全カバー済み: 削除
> - 固有コンテンツあり: 移行後削除
> - 運用参照として有用: 判定保留

---

## meta

```yaml
schema_version: v2
project: context-consolidation
branch: feat/m148-merge-pending-docs
created: 2025-12-21
issue: null
derives_from: M148
reviewed: false
roles:
  worker: claudecode
  reviewer: codex

user_prompt_original: |
  M148: MERGE予定ドキュメントの統合
  - docs/flow-document-map.md → essential-documents.md（削除）
  - docs/ARCHITECTURE.md → layer-architecture-design.md（移行後削除）
  - docs/hook-registry.md → 判定保留（運用参照として有用）
```

---

## goal

```yaml
summary: MERGE予定ファイルを分析し、適切に統合・削除する
done_when:
  - "docs/flow-document-map.md が削除されている（essential-documents.md で完全カバー）"
  - "docs/ARCHITECTURE.md の固有コンテンツが layer-architecture-design.md に移行されている"
  - "docs/ARCHITECTURE.md が削除されている"
  - "docs/hook-registry.md の処理方針が決定されている"
  - "FREEZE_QUEUE が更新されている"
  - "削除後も全テスト（flow-runtime-test）が PASS する"
```

---

## phases

### p1: flow-document-map.md の削除

**goal**: essential-documents.md で完全カバーされているため削除

#### subtasks

- [ ] **p1.1**: essential-documents.md に同等の動線マッピングが存在することを確認
  - executor: claudecode
  - test_command: `grep -q "計画動線" docs/essential-documents.md && grep -q "実行動線" docs/essential-documents.md && echo PASS || echo FAIL`
  - validations:
    - technical: "4動線が essential-documents.md に存在する"
    - consistency: "自動生成により最新状態が維持される"
    - completeness: "flow-document-map.md の情報がカバーされている"

- [ ] **p1.2**: docs/flow-document-map.md を削除
  - executor: claudecode
  - test_command: `test ! -f docs/flow-document-map.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "git rm で追跡から除外されている"
    - completeness: "参照エラーがない"

**status**: done
**max_iterations**: 3

---

### p2: ARCHITECTURE.md の移行と削除

**goal**: 固有コンテンツを layer-architecture-design.md に移行し、元ファイルを削除

**depends_on**: [p1]

#### subtasks

- [ ] **p2.1**: ARCHITECTURE.md の固有コンテンツを特定
  - executor: claudecode
  - test_command: `grep -q "エントリーポイント" docs/ARCHITECTURE.md && grep -q "ディレクトリ構成" docs/ARCHITECTURE.md && ! grep -q "エントリーポイント" docs/layer-architecture-design.md && echo PASS || echo FAIL`
  - validations:
    - technical: "固有コンテンツ: ディレクトリ構成、エントリーポイント、統計"
    - consistency: "layer-architecture-design.md にない情報を確認"
    - completeness: "移行対象セクションを列挙"
  - note: |
    移行対象セクション:
    - §2 エントリーポイント（読み込み順序）
    - §3 ディレクトリ構成（ツリー構造）
    - §11 統計（コンポーネント数）

- [ ] **p2.2**: layer-architecture-design.md に「付録: リポジトリ概要」セクションを追加
  - executor: claudecode
  - test_command: `grep -q "付録\|リポジトリ概要\|エントリーポイント" docs/layer-architecture-design.md && echo PASS || echo FAIL`
  - validations:
    - technical: "付録セクションが追加されている"
    - consistency: "ARCHITECTURE.md の固有コンテンツが移行されている"
    - completeness: "エントリーポイント、ディレクトリ構成が含まれている"

- [ ] **p2.3**: docs/ARCHITECTURE.md を削除
  - executor: claudecode
  - test_command: `test ! -f docs/ARCHITECTURE.md && echo PASS || echo FAIL`
  - validations:
    - technical: "ファイルが存在しない"
    - consistency: "git rm で追跡から除外されている"
    - completeness: "参照が更新されている"

**status**: done
**max_iterations**: 5

---

### p3: hook-registry.md の処理方針決定

**goal**: 運用参照としての価値を評価し、処理方針を決定

**depends_on**: [p2]

#### subtasks

- [ ] **p3.1**: hook-registry.md の固有情報を確認
  - executor: claudecode
  - test_command: `grep -q "呼び出し元" docs/hook-registry.md && grep -q "削除可否" docs/hook-registry.md && echo PASS || echo FAIL`
  - validations:
    - technical: "依存関係情報（呼び出し元）が固有"
    - consistency: "削除理由の記載が固有"
    - completeness: "core-manifest.yaml にない情報を確認"
  - note: |
    固有情報:
    - 22 vs 33 の差分説明（内部ライブラリ5 + コマンド用1 + 手動実行5）
    - 各 Hook の「呼び出し元」依存関係
    - 削除可否判定と理由

- [ ] **p3.2**: hook-registry.md を FREEZE_QUEUE から除外し DELETE_LOG に追加、または保留
  - executor: claudecode
  - test_command: `(grep -A30 "FREEZE_QUEUE" state.md | grep -q "hook-registry.md.*保留\|KEEP") || (grep -A30 "DELETE_LOG" state.md | grep -q "hook-registry.md") && echo PASS || echo FAIL`
  - validations:
    - technical: "処理方針が state.md に記録されている"
    - consistency: "FREEZE_QUEUE（保留理由付き）または DELETE_LOG に反映"
    - completeness: "判定理由が記録されている"
  - note: |
    判定基準:
    - 依存関係情報が運用で必要 → 保留（FREEZE_QUEUE 維持 + 理由追記）
    - core-manifest.yaml で代替可能 → 削除（DELETE_LOG へ）

**status**: done
**max_iterations**: 3

---

### p4: state.md と essential-documents.md の更新

**goal**: FREEZE_QUEUE と DELETE_LOG を更新し、essential-documents.md を再生成

**depends_on**: [p3]

#### subtasks

- [ ] **p4.1**: state.md の FREEZE_QUEUE から削除済みファイルを除外
  - executor: claudecode
  - test_command: `! grep -q "flow-document-map.md\|ARCHITECTURE.md" <(grep -A20 "## FREEZE_QUEUE" state.md) && echo PASS || echo FAIL`
  - validations:
    - technical: "FREEZE_QUEUE に削除済みファイルが含まれていない"
    - consistency: "DELETE_LOG に記録されている"
    - completeness: "全ての処理済みファイルが反映されている"

- [ ] **p4.2**: essential-documents.md を再生成
  - executor: claudecode
  - test_command: `bash scripts/generate-essential-docs.sh && echo PASS || echo FAIL`
  - validations:
    - technical: "再生成が成功している"
    - consistency: "削除されたファイルがリストから除外されている"
    - completeness: "最新の state.md を反映している"

**status**: done
**max_iterations**: 3

---

### p_final: 完了検証

**goal**: 全ての done_when が満たされているか最終検証

**depends_on**: [p4]

#### subtasks

- [ ] **p_final.1**: 削除対象ファイルが存在しない
  - executor: claudecode
  - test_command: `test ! -f docs/flow-document-map.md && test ! -f docs/ARCHITECTURE.md && echo PASS || echo FAIL`
  - validations:
    - technical: "2ファイルが存在しない"
    - consistency: "DELETE_LOG に記録されている"
    - completeness: "削除完了"

- [ ] **p_final.2**: layer-architecture-design.md に移行コンテンツが存在
  - executor: claudecode
  - test_command: `grep -q "エントリーポイント\|ディレクトリ" docs/layer-architecture-design.md && echo PASS || echo FAIL`
  - validations:
    - technical: "移行コンテンツが確認できる"
    - consistency: "ARCHITECTURE.md の固有情報が保存されている"
    - completeness: "重要セクションが移行されている"

- [ ] **p_final.3**: テストが全て PASS する
  - executor: claudecode
  - test_command: `bash scripts/flow-runtime-test.sh 2>&1 | grep -q "ALL.*PASS" && echo PASS || echo FAIL`
  - validations:
    - technical: "テストが正常に実行される"
    - consistency: "削除がシステムに悪影響を与えていない"
    - completeness: "主要テストが全て PASS"

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git status`
  - status: pending

---

## rollback

```yaml
手順:
  1. git checkout -- で削除ファイルを復元
     git checkout HEAD -- docs/flow-document-map.md
     git checkout HEAD -- docs/ARCHITECTURE.md

  2. layer-architecture-design.md の変更をリバート
     git checkout HEAD -- docs/layer-architecture-design.md

  3. state.md の FREEZE_QUEUE を復元
     git checkout HEAD -- state.md

注意:
  - ブランチが feat/m148-merge-pending-docs であることを確認
```

---

## notes

### 分析結果

```yaml
flow-document-map.md:
  判定: DISCARD
  理由: essential-documents.md（自動生成）で完全カバー
  固有コンテンツ: なし

ARCHITECTURE.md:
  判定: MIGRATE → DELETE
  理由: 固有コンテンツ（ディレクトリ構成、エントリーポイント）を移行
  移行先: layer-architecture-design.md
  固有コンテンツ:
    - §2 エントリーポイント（読み込み順序）
    - §3 ディレクトリ構成（ツリー構造）
    - §11 統計

hook-registry.md:
  判定: 保留検討
  理由: 依存関係情報と削除理由が運用参照として有用
  固有コンテンツ:
    - 22 vs 33 の差分説明
    - 依存関係（呼び出し元）
    - 削除可否判定
```

### 削減効果

```yaml
削除予定: 2ファイル（flow-document-map.md, ARCHITECTURE.md）
移行: ARCHITECTURE.md → layer-architecture-design.md（付録）
保留: hook-registry.md（運用参照として検討）
M146+M147 からの累計: 17ファイル削減予定
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成。Explore 分析結果を反映。 |
