# post-loop

> **POST_LOOP - playbook 完了後の自動処理**

---

## frontmatter

```yaml
name: post-loop
description: playbook 完了後の自動コミット、マージ、次タスク導出を実行。
triggers:
  - playbook の全 Phase が done になった時
auto_invoke: false  # LOOP 終了時に手動参照
```

---

## トリガー

playbook の全 Phase が done

---

## 行動

```yaml
0. 自動コミット（最終 Phase 分）:
   - `git status --porcelain` で未コミット変更を確認
   - 変更あり → `git add -A && git commit -m "feat: {playbook 名} 完了"`
   - 変更なし → スキップ

0.5. 完了 playbook のアーカイブ:
   - archive-playbook.sh の提案が出力されている場合
   - 以下を実行:
     ```bash
     mkdir -p .archive/plan
     mv plan/active/playbook-{name}.md .archive/plan/
     ```
   - state.md の active_playbooks.{layer} を null に更新
   - 注意: アーカイブ前に git add/commit を完了すること
   - 参照: docs/archive-operation-rules.md

1. 自動マージ:
   ```bash
   BRANCH=$(git branch --show-current)
   git checkout main && git merge $BRANCH --no-edit
   ```
   - コンフリクト発生 → 手動解決を促す

2. project.done_when の更新:
   - derives_from で紐づく done_when.status を achieved に

3. 次タスクの導出（計画の連鎖）★pm 経由必須:
   - pm SubAgent を呼び出す
   - pm が project.md の not_achieved を確認
   - pm が depends_on を分析し、着手可能な done_when を特定
   - pm が decomposition を参照して新 playbook を作成

4. 残タスクあり:
   - ブランチ作成: `git checkout -b feat/{next-task}`
   - pm が playbook 作成: plan/active/playbook-{next-task}.md
   - pm が state.md 更新: active_playbooks.product を更新
   - 即座に LOOP に入る

5. 残タスクなし:
   - 「全タスク完了。次の指示を待ちます。」
```

---

## git 自動操作

```yaml
Phase 完了: 自動コミット（critic PASS 後、LOOP 内で実行）
playbook 完了: 自動マージ（POST_LOOP 行動 1 で実行）
新タスク: 自動ブランチ（POST_LOOP 行動 4 で実行）
```

---

## 禁止

```yaml
- 「報告して待つ」パターン（残タスクがあるのに止まる）
- ユーザーに「次は何をしますか？」と聞く
```
