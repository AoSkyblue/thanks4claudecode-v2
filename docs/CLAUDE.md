# docs/

> **ドキュメント - 仕様書・運用ルール**
>
> ファイル管理は `docs/manifest.yaml` で行う（追加/削除時は必ず更新）

---

## 役割

このフォルダは、プロジェクトの仕様書、運用ルールを保存します。
必要な時にのみ参照され、毎回読まれるわけではありません。

---

## ファイル一覧

### コア仕様

| ファイル | 役割 | 参照タイミング |
|----------|------|----------------|
| current-implementation.md | 現在実装の棚卸し（自動生成） | 構造変更時、復旧時 |
| extension-system.md | Claude Code 公式リファレンス | 拡張機能確認時 |
| feature-map.md | Hooks/SubAgents/Skills 一覧 | 機能確認時 |
| folder-management.md | フォルダ管理ルール | ファイル配置時 |

### 運用ルール

| ファイル | 役割 | 参照タイミング |
|----------|------|----------------|
| git-operations.md | git 操作ガイド | git 操作時 |
| archive-operation-rules.md | アーカイブ操作ルール | アーカイブ時 |
| artifact-management-rules.md | 成果物管理ルール | 成果物操作時 |
| criterion-validation-rules.md | done_criteria 検証ルール | playbook 作成時 |

---

## ファイル管理

```yaml
manifest: docs/manifest.yaml  # 全ファイルのメタデータ

新規作成時:
  1. docs/ にファイルを作成
  2. manifest.yaml に追記
  3. このファイル（CLAUDE.md）を更新

削除時:
  1. ファイルを削除
  2. manifest.yaml から削除
  3. このファイル（CLAUDE.md）を更新
```

---

## 設計原則

```yaml
原則:
  - 必要なドキュメントのみ保持
  - manifest.yaml で一元管理
  - 必要な時にのみ参照される

禁止:
  - テスト目的のファイル配置（tmp/ を使用）
  - 中間成果物の配置（tmp/ を使用）
  - manifest.yaml を更新せずにファイル追加
```

---

## 連携

- **state.md** → 参照ファイル一覧で docs/ を指定
- **CLAUDE.md** → 必要に応じて @参照で呼び出し
- **playbook** → Phase 作業中に必要なドキュメントを参照
- **manifest.yaml** → docs/ 内ファイルのメタデータ管理
