# Document Catalog

> **docs/ 内の全ファイルを評価し、廃棄/統合/維持に分類**
>
> 作成日: 2025-12-21
> マイルストーン: M117

---

## 分類基準

```yaml
廃棄基準 (DISCARD):
  - 古い情報で現在の仕様と矛盾している
  - 他のドキュメントに完全に包含されている
  - 一時的な目的（特定 milestone のみ）で作成され、その役割を終えた
  - 参照されていない孤立ファイル

統合基準 (MERGE):
  - 内容が類似した複数ファイルが存在する
  - 1つのファイルにまとめることで管理効率が上がる
  - 断片的な情報が複数ファイルに分散している

維持基準 (KEEP):
  - 現在も参照されている
  - 独自の役割を持ち、他と重複しない
  - 動線（計画/実行/検証/完了）に紐づく
```

---

## ファイル一覧と評価

### 1. ARCHITECTURE.md
- **説明**: リポジトリの構造と各コンポーネントの関係を文書化
- **行数**: 約300行
- **参照元**: session-start.sh から参照される可能性
- **評価**: **KEEP** - アーキテクチャの全体像を示す重要ドキュメント
- **動線**: 共通基盤

### 2. admin-contract.md
- **説明**: admin モードの権限境界を定義
- **行数**: 約100行
- **参照元**: CLAUDE.md の Admin Mode Contract と関連
- **評価**: **MERGE** - core-contract.md に統合可能
- **動線**: 実行動線

### 3. ai-orchestration.md
- **説明**: 役割ベース executor 抽象化の説明
- **行数**: 約150行
- **参照元**: pm.md, playbook-format.md から参照
- **評価**: **KEEP** - M073 の成果物、executor 設計の核心
- **動線**: 計画動線

### 4. archive-operation-rules.md
- **説明**: playbook 完了時のアーカイブ運用ルール
- **行数**: 約100行
- **参照元**: archive-playbook.sh
- **評価**: **MERGE** - folder-management.md に統合可能
- **動線**: 完了動線

### 5. artifact-management-rules.md
- **説明**: 「仕組みとして参照されないファイル」の防止ルール
- **行数**: 約150行
- **参照元**: playbook-format.md
- **評価**: **MERGE** - folder-management.md に統合可能
- **動線**: 完了動線

### 6. completion-criteria.md
- **説明**: 「完成」の定義 - 5つの動作シナリオ
- **行数**: 約200行
- **参照元**: verification-criteria.md と関連
- **評価**: **MERGE** - verification-criteria.md に統合可能
- **動線**: 検証動線

### 7. core-contract.md
- **説明**: admin モードでも回避不可の核心契約
- **行数**: 約80行
- **参照元**: CLAUDE.md
- **評価**: **KEEP** - 契約の核心、admin-contract.md を統合先として使用
- **動線**: 共通基盤

### 8. core-functions.md
- **説明**: 動線単位でコア機能を確定したドキュメント
- **行数**: 約250行
- **参照元**: check.md, project.md
- **評価**: **KEEP** - M108 成果物、コア機能の定義
- **動線**: 共通基盤

### 9. criterion-validation-rules.md
- **説明**: criterion の検証ルール（曖昧表現の検出・拒否）
- **行数**: 約250行
- **参照元**: playbook-format.md, pm.md
- **評価**: **KEEP** - done_criteria 品質の核心
- **動線**: 検証動線

### 10. current-definitions.md
- **説明**: 最新状態の定義（古い表記を特定するための基準）
- **行数**: 約100行
- **参照元**: deprecated-references.md と対
- **評価**: **DISCARD** - 一時的な整理用、役割終了
- **動線**: なし

### 11. deprecated-references.md
- **説明**: 廃止された表記の参照一覧
- **行数**: 約100行
- **参照元**: current-definitions.md と対
- **評価**: **DISCARD** - 一時的な整理用、役割終了
- **動線**: なし

### 12. extension-system.md
- **説明**: Claude Code 拡張システム体系
- **行数**: 約600行
- **参照元**: 開発者向けリファレンス
- **評価**: **KEEP** - 公式リファレンスに基づく重要情報
- **動線**: 共通基盤

### 13. flow-test-report.md
- **説明**: M107 動線単位テストレポート
- **行数**: 約150行
- **参照元**: project.md M107
- **評価**: **DISCARD** - M107 完了報告、役割終了
- **動線**: なし

### 14. folder-management.md
- **説明**: フォルダ管理ルール（テンポラリ/永続区分）
- **行数**: 約250行
- **参照元**: playbook-format.md, cleanup-hook.sh
- **評価**: **KEEP** - フォルダ管理の核心（統合先として使用）
- **動線**: 完了動線

### 15. freeze-then-delete.md
- **説明**: 安全なファイル削除のための3段階プロセス
- **行数**: 約150行
- **参照元**: state.md FREEZE_QUEUE
- **評価**: **KEEP** - 削除プロセスの核心
- **動線**: 完了動線

### 16. git-operations.md
- **説明**: git 操作の標準手順
- **行数**: 約200行
- **参照元**: CLAUDE.md, playbook-format.md
- **評価**: **KEEP** - git 操作リファレンス
- **動線**: 完了動線

### 17. golden-path-verification-report.md
- **説明**: M105 全40コンポーネントの動作検証結果
- **行数**: 約500行
- **参照元**: project.md M105
- **評価**: **DISCARD** - M105 完了報告、役割終了
- **動線**: なし

### 18. hook-exit-code-contract.md
- **説明**: Hook の出力と exit code の共通契約
- **行数**: 約120行
- **参照元**: 全 Hook スクリプト
- **評価**: **KEEP** - Hook 開発の核心
- **動線**: 実行動線

### 19. hook-registry.md
- **説明**: 全33 Hook の分類台帳
- **行数**: 約150行
- **参照元**: settings.json, generate-repository-map.sh
- **評価**: **MERGE** - repository-map.yaml に統合可能
- **動線**: 共通基盤

### 20. hook-responsibilities.md
- **説明**: 各 Hook の単一責任を明示
- **行数**: 約250行
- **参照元**: Hook 開発時に参照
- **評価**: **KEEP** - SOLID 原則に基づく重要ドキュメント
- **動線**: 実行動線

### 21. layer-architecture-design.md
- **説明**: M104 黄金動線ベースの設計ドキュメント
- **行数**: 約250行
- **参照元**: project.md M104
- **評価**: **KEEP** - Layer アーキテクチャの設計根拠
- **動線**: 共通基盤

### 22. m106-critic-guard-patch.md
- **説明**: M106 の手動修正パッチ
- **行数**: 約100行
- **参照元**: なし（HARD_BLOCK 対応用）
- **評価**: **DISCARD** - M106 完了、役割終了
- **動線**: なし

### 23. orchestration-contract.md
- **説明**: ツールスタック構成と役割分担のルール
- **行数**: 約250行
- **参照元**: ai-orchestration.md と重複
- **評価**: **MERGE** - ai-orchestration.md に統合可能
- **動線**: 計画動線

### 24. playbook-schema-v2.md
- **説明**: Playbook の厳密なフォーマット定義
- **行数**: 約250行
- **参照元**: playbook-format.md, playbook-validator.sh
- **評価**: **KEEP** - Schema v2 の仕様書
- **動線**: 計画動線

### 25. scenario-test-report.md
- **説明**: 動線単位シナリオテストレポート
- **行数**: 約200行
- **参照元**: project.md M110
- **評価**: **DISCARD** - M110 完了報告、役割終了
- **動線**: なし

### 26. session-management.md
- **説明**: セッション管理ガイド（Named Sessions、Plan Mode）
- **行数**: 約100行
- **参照元**: CLAUDE.md
- **評価**: **KEEP** - セッション管理の核心
- **動線**: 共通基盤

### 27. toolstack-patterns.md
- **説明**: 3つのツールスタックパターンと設定ガイド
- **行数**: 約200行
- **参照元**: ai-orchestration.md, state.md
- **評価**: **MERGE** - ai-orchestration.md に統合可能
- **動線**: 計画動線

### 28. verification-criteria.md
- **説明**: 動作確認の判定基準
- **行数**: 約250行
- **参照元**: テストスクリプト
- **評価**: **KEEP** - PASS/FAIL 判定基準（統合先として使用）
- **動線**: 検証動線

### 29. repository-map.yaml
- **説明**: リポジトリ内の全ファイルマッピング（自動生成）
- **行数**: 約400行
- **参照元**: session-start.sh, generate-repository-map.sh
- **評価**: **KEEP** - 自動生成、Single Source of Truth
- **動線**: 共通基盤

### 30. manual-patches/ (ディレクトリ)
- **説明**: 手動パッチ用ディレクトリ
- **評価**: **KEEP** - HARD_BLOCK 対応用
- **動線**: 実行動線

---

## 分類サマリー

| 分類 | 件数 | ファイル |
|------|------|----------|
| **KEEP** | 17 | ARCHITECTURE.md, ai-orchestration.md, core-contract.md, core-functions.md, criterion-validation-rules.md, extension-system.md, folder-management.md, freeze-then-delete.md, git-operations.md, hook-exit-code-contract.md, hook-responsibilities.md, layer-architecture-design.md, playbook-schema-v2.md, session-management.md, verification-criteria.md, repository-map.yaml, manual-patches/ |
| **MERGE** | 7 | admin-contract.md -> core-contract.md, archive-operation-rules.md -> folder-management.md, artifact-management-rules.md -> folder-management.md, completion-criteria.md -> verification-criteria.md, hook-registry.md -> repository-map.yaml, orchestration-contract.md -> ai-orchestration.md, toolstack-patterns.md -> ai-orchestration.md |
| **DISCARD** | 5 | current-definitions.md, deprecated-references.md, flow-test-report.md, golden-path-verification-report.md, m106-critic-guard-patch.md, scenario-test-report.md |

---

## アクションプラン

### Phase 1: 統合 (MERGE)

1. **core-contract.md + admin-contract.md**
   - admin-contract.md の内容を core-contract.md に追記
   - admin-contract.md を FREEZE_QUEUE に追加

2. **folder-management.md + archive-operation-rules.md + artifact-management-rules.md**
   - 2つのファイルの内容を folder-management.md に追記
   - 元ファイルを FREEZE_QUEUE に追加

3. **verification-criteria.md + completion-criteria.md**
   - completion-criteria.md の内容を verification-criteria.md に追記
   - completion-criteria.md を FREEZE_QUEUE に追加

4. **ai-orchestration.md + orchestration-contract.md + toolstack-patterns.md**
   - 2つのファイルの内容を ai-orchestration.md に追記
   - 元ファイルを FREEZE_QUEUE に追加

5. **repository-map.yaml + hook-registry.md**
   - hook-registry.md の台帳情報を repository-map.yaml に統合
   - hook-registry.md を FREEZE_QUEUE に追加

### Phase 2: 廃棄 (DISCARD)

以下のファイルを FREEZE_QUEUE に追加:
- current-definitions.md
- deprecated-references.md
- flow-test-report.md
- golden-path-verification-report.md
- m106-critic-guard-patch.md
- scenario-test-report.md

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-21 | 初版作成。29ファイル + 1ディレクトリを評価。 |
