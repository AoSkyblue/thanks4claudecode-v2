# thanks4claudecode コンポーネントカタログ

> **黄金動線単位で整理された全 40 コンポーネント**
>
> Layer = 動線での役割の深さ。Core は全動線に不可欠なもの。

---

# 黄金動線の定義

```
1. 計画動線: /task-start → pm → playbook作成 → state.md更新
2. 実行動線: playbook読込 → subtask → Edit/Write → validations
3. 検証動線: /crit → critic → PASS/FAIL → phase完了
4. 完了動線: 全phase完了 → アーカイブ → 次タスク導出
```

---

# 1. 計画動線（6 コンポーネント）

> `/task-start → pm → playbook作成 → state.md更新`

| 種別 | 名前 | 役割 |
|------|------|------|
| Command | task-start.md | タスク開始の起点。pm を呼び出す |
| Command | playbook-init.md | playbook 作成ウィザード |
| SubAgent | pm.md | playbook 作成・管理。黄金動線の中核 |
| Skill | state | state.md 管理の専門知識 |
| Skill | plan-management | playbook 運用の一貫性 |
| Hook | prompt-guard.sh | タスク要求パターン検出、pm 必須警告 |

---

# 2. 実行動線（11 コンポーネント）

> `playbook読込 → subtask → Edit/Write → validations`

| 種別 | 名前 | 役割 |
|------|------|------|
| Hook | init-guard.sh | 必須ファイル Read 強制 |
| Hook | playbook-guard.sh | playbook=null で Edit/Write ブロック |
| Hook | subtask-guard.sh | subtask 完了時の 3 観点検証強制 |
| Hook | scope-guard.sh | done_criteria/done_when 無断変更検出 |
| Hook | check-protected-edit.sh | HARD_BLOCK ファイル編集防止 |
| Hook | pre-bash-check.sh | 危険 Bash コマンドブロック |
| Hook | consent-guard.sh | 危険操作のユーザー同意取得 |
| Hook | executor-guard.sh | executor に応じたツール呼び出し強制 |
| Hook | check-main-branch.sh | main ブランチでの Edit/Write ブロック |
| Skill | lint-checker | コード品質チェック |
| Skill | test-runner | テスト実行・検証 |

---

# 3. 検証動線（6 コンポーネント）

> `/crit → critic → PASS/FAIL → phase完了`

| 種別 | 名前 | 役割 |
|------|------|------|
| Command | crit.md | 検証起点。critic を呼び出す |
| Command | test.md | done_criteria のテスト実行 |
| Command | lint.md | state.md と playbook の整合性チェック |
| SubAgent | critic.md | done_criteria 検証。報酬詐欺防止 |
| SubAgent | reviewer.md | コード・設計レビュー |
| Hook | critic-guard.sh | phase 完了前の critic 強制 |

---

# 4. 完了動線（8 コンポーネント）

> `全phase完了 → アーカイブ → 次タスク導出`

| 種別 | 名前 | 役割 |
|------|------|------|
| Command | rollback.md | Git ロールバック実行 |
| Command | state-rollback.md | state.md のバックアップと復元 |
| Command | focus.md | focus.current 切り替え |
| Hook | archive-playbook.sh | playbook 完了時のアーカイブ提案 |
| Hook | cleanup-hook.sh | tmp/ クリーンアップ |
| Hook | create-pr-hook.sh | PR 自動作成 |
| Skill | post-loop | playbook 完了後の自動処理 |
| Skill | context-management | /compact 最適化と履歴要約 |

---

# 5. 共通基盤（6 コンポーネント）

> 全動線で使用されるインフラ

| 種別 | 名前 | 役割 |
|------|------|------|
| Hook | session-start.sh | セッション開始時の自己認識形成 |
| Hook | session-end.sh | セッション終了時の整合性チェック |
| Hook | pre-compact.sh | compact 前の状態スナップショット |
| Hook | stop-summary.sh | エージェント停止時の Phase 状態サマリー |
| Hook | log-subagent.sh | SubAgent 呼び出し記録 |
| Skill | consent-process | 合意プロセス（CONSENT）強制 |

---

# 6. 横断的整合性（3 コンポーネント）

> 動線間の整合性を保証

| 種別 | 名前 | 役割 |
|------|------|------|
| Hook | check-coherence.sh | 四項整合性（focus/layer/playbook/branch）検証 |
| Hook | depends-check.sh | playbook 間の依存関係検証 |
| Hook | lint-check.sh | コード変更時の静的解析 |

---

# 統計サマリー

| 動線 | Hooks | SubAgents | Skills | Commands | 合計 |
|------|-------|-----------|--------|----------|------|
| 計画動線 | 1 | 1 | 2 | 2 | 6 |
| 実行動線 | 9 | 0 | 2 | 0 | 11 |
| 検証動線 | 1 | 2 | 0 | 3 | 6 |
| 完了動線 | 3 | 0 | 2 | 3 | 8 |
| 共通基盤 | 5 | 0 | 1 | 0 | 6 |
| 横断的整合性 | 3 | 0 | 0 | 0 | 3 |
| **合計** | **22** | **3** | **7** | **8** | **40** |

---

# Core 候補（複数動線に登場）

黄金動線を成立させるための最小セット：

| コンポーネント | 登場動線 | Core 理由 |
|----------------|----------|-----------|
| pm.md | 計画 + 完了 | playbook 作成・次タスク導出 |
| state (Skill) | 計画 + 完了 | state.md 管理 |
| playbook-guard.sh | 計画 + 実行 | playbook Gate |
| /task-start | 計画 | 黄金動線の起点 |
| /crit + critic | 検証 | 報酬詐欺防止の中核 |

---

*Generated: 2025-12-20 (黄金動線ベースで再整理)*
