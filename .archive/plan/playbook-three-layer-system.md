# playbook-three-layer-system.md

> **M004「3層構造の自動運用システム」実装 - 自動運用機構の完成**

---

## meta

```yaml
project: thanks4claudecode
branch: refactor/three-layer-system
created: 2025-12-13
issue: null
derives_from: M004
reviewed: false
```

---

## goal

```yaml
summary: playbook 完了時の自動化機構（project 更新・/clear アナウンス）を実装する

done_when:
  - project.milestone の自動更新ロジックが実装されている
  - /clear 推奨のアナウンスメッセージが実装されている
  - 実際に動作確認済み（test_method 実行）
```

---

## phases

### p0: 現状把握と設計

```yaml
id: p0
name: 現状把握と設計
goal: 既存の post-loop skill と check-coherence.sh を理解し、実装計画を立てる
executor: claudecode
priority: high
done_criteria:
  - post-loop skill (skill.md) が読み込まれている
  - check-coherence.sh の現在の実装が把握されている
  - 実装計画が作成されている
  - 実際に動作確認済み（test_method 実行）
test_method: |
  1. .claude/skills/post-loop/skill.md を読み込む
  2. .claude/hooks/ 配下のスクリプト確認
  3. check-coherence.sh の現在の出力を確認
  4. 実装タスクリストを確認
status: done
```

### p1: post-loop skill 拡張 - project 自動更新

```yaml
id: p1
name: post-loop skill 拡張 - project 自動更新
goal: playbook 完了時に project.milestone を自動更新するロジックを実装
executor: claudecode
depends_on: [p0]
priority: high
done_criteria:
  - project.milestone[].status の更新ロジックが実装されている
  - achieved_at フィールドが自動設定される
  - playbooks[] にプロイ playbook 名が追記される
  - 実装が test_method で動作確認済み
test_method: |
  1. post-loop skill の該当セクションを確認
  2. サンプル playbook 完了フロー（シミュレーション）
  3. project.milestone の更新が正しく反映される
status: done
```

### p2: post-loop skill 拡張 - /clear アナウンス

```yaml
id: p2
name: post-loop skill 拡張 - /clear アナウンス
goal: playbook 完了後、ユーザーに /clear タイミングを推奨するメッセージを実装
executor: claudecode
depends_on: [p1]
priority: high
done_criteria:
  - playbook 完了時に /clear 推奨メッセージが出力される
  - メッセージに「コンテキストをリセット」の趣旨が含まれている
  - 実装が test_method で動作確認済み
test_method: |
  1. post-loop skill の該当セクションを確認
  2. アナウンスメッセージの内容を確認
  3. ユーザーに対して分かりやすい案内になっているか確認
status: done
```

### p3: check-coherence.sh 簡略化

```yaml
id: p3
name: check-coherence.sh 簡略化
goal: check-coherence.sh の不要な出力を削除し、重要な警告のみを表示
executor: claudecode
depends_on: [p2]
priority: medium
done_criteria:
  - check-coherence.sh が簡略化されている
  - 重要な整合性チェックのみ残存している
  - 実行結果が明確で読みやすい
  - 実装が test_method で動作確認済み
test_method: |
  1. check-coherence.sh を実行
  2. 出力が簡潔かつ分かりやすいか確認
  3. エラーケースで正しく警告されるか確認
status: done
```

### p4: 統合テストと動作確認

```yaml
id: p4
name: 統合テストと動作確認
goal: 全ての自動化機構が連動して動作することを確認
executor: claudecode
depends_on: [p3]
priority: high
done_criteria:
  - playbook 完了フロー全体（p0-p3）が動作確認済み
  - project.milestone が自動更新される
  - /clear アナウンスが出力される
  - エラーケースで正しく処理される
  - 実装が test_method で動作確認済み
test_method: |
  1. post-loop skill の実装確認
  2. check-coherence.sh の動作確認（実際に実行）
  3. 出力が簡潔で重要な情報のみ表示されるか確認
status: done
```

### p5: ドキュメント更新

```yaml
id: p5
name: ドキュメント更新
goal: 実装内容を CLAUDE.md と関連ドキュメントに反映
executor: claudecode
depends_on: [p4]
priority: medium
done_criteria:
  - CLAUDE.md の POST_LOOP セクションが更新されている
  - 変更内容が明確にドキュメント化されている
  - .claude/skills/post-loop/skill.md が更新されている
  - 実装が test_method で動作確認済み
test_method: |
  1. CLAUDE.md の POST_LOOP セクション確認：215-233行
  2. skill.md の内容確認：64-90行
  3. ドキュメントが実装と一致しているか確認
status: done
```

---

## タイムライン

- **p0**: 15 min（現状把握）
- **p1**: 30 min（project 更新ロジック）
- **p2**: 20 min（/clear アナウンス）
- **p3**: 15 min（check-coherence.sh 簡略化）
- **p4**: 20 min（統合テスト）
- **p5**: 15 min（ドキュメント）

**想定総時間**: 115 min（約2時間）

---

## リスク管理

| リスク | 対策 |
|-------|------|
| project.milestone の更新タイミング不正 | テスト時に全ケース確認 |
| /clear メッセージがユーザーに届かない | 複数の出力方法を検討 |
| 既存フロー への破壊 | post-loop の既存ロジックは変更しない |

---

## 依存ファイル

- `.claude/skills/post-loop/skill.md`
- `.claude/hooks/` 配下のスクリプト
- `plan/project.md`
- `state.md`
- `CLAUDE.md`
- `.claude/hooks/check-coherence.sh`

---

## 参考ドキュメント

- docs/feature-map.md （機能マップ）
- CLAUDE.md （POST_LOOP セクション）
- .claude/skills/post-loop/skill.md （post-loop skill）
