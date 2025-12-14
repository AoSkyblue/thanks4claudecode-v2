# playbook-m021-bugfix.md

> **M021: init-guard.sh デッドロック修正 + 整合性チェック強化**
>
> main ブランチからの差分検証で発見された4つのバグを修正する。

---

## meta

```yaml
project: thanks4claudecode
branch: feat/m021-bugfix
created: 2025-12-14
issue: null
derives_from: M021
reviewed: false
```

---

## goal

```yaml
summary: init-guard.sh のデッドロック問題を修正し、state.md 整合性チェックを強化する
done_when:
  - init-guard.sh で基本 Bash コマンドが許可されている
  - state.md 整合性チェックが追加されている
  - session-start.sh に CORE 情報が復元されている
  - 古い playbook がアーカイブされている
  - 全テストが PASS している
```

---

## phases

```yaml
- id: p0
  name: init-guard.sh の Bash 許可リスト追加
  goal: playbook=null 時でも基本 Bash コマンド（sed/grep/cat/echo/ls/wc）を許可

  subtasks:
    - id: p0.1
      criterion: "init-guard.sh L127 に基本コマンドの正規表現が追加されている"
      executor: claudecode
      test_command: "grep -q 'sed\\|grep\\|cat\\|echo\\|ls\\|wc' .claude/hooks/init-guard.sh && echo PASS || echo FAIL"

    - id: p0.2
      criterion: "playbook=null 時に sed コマンドがブロックされない"
      executor: claudecode
      test_command: |
        echo "null" > .claude/.session-init/required_playbook
        echo '{"tool_name": "Bash", "tool_input": {"command": "sed --version"}}' | bash .claude/hooks/init-guard.sh 2>&1
        RESULT=$?
        grep "^active:" state.md | sed 's/active: *//' > .claude/.session-init/required_playbook
        [ $RESULT -eq 0 ] && echo PASS || echo FAIL

  status: done
  max_iterations: 5

- id: p1
  name: state.md 整合性チェック追加
  goal: milestone/phase=null なのに playbook.active がある矛盾を検出
  depends_on: [p0]

  subtasks:
    - id: p1.1
      criterion: "system-health-check.sh に整合性チェックロジックが追加されている"
      executor: claudecode
      test_command: "grep -q 'milestone.*null.*playbook' .claude/hooks/system-health-check.sh && echo PASS || echo FAIL"

    - id: p1.2
      criterion: "矛盾状態検出時に警告メッセージが出力される"
      executor: claudecode
      test_command: "grep -q '不整合\\|inconsistent' .claude/hooks/system-health-check.sh && echo PASS || echo FAIL"

  status: done
  max_iterations: 5

- id: p2
  name: session-start.sh に CORE 情報を復元
  goal: セッション開始時に CORE ルールが LLM に届くようにする
  depends_on: [p1]

  subtasks:
    - id: p2.1
      criterion: "session-start.sh に CORE セクションが存在する"
      executor: claudecode
      test_command: "grep -q 'CORE' .claude/hooks/session-start.sh && echo PASS || echo FAIL"

    - id: p2.2
      criterion: "CORE セクションに pdca/tdd/validation が含まれている"
      executor: claudecode
      test_command: "grep -A10 'CORE' .claude/hooks/session-start.sh | grep -q 'pdca\\|tdd\\|validation' && echo PASS || echo FAIL"

  status: done
  max_iterations: 5

- id: p3
  name: 古い playbook のアーカイブ
  goal: plan/active/ に残存する M011 用 playbook を plan/archive/ に移動
  depends_on: [p2]

  subtasks:
    - id: p3.1
      criterion: "playbook-core-system-completion.md が plan/archive/ に存在する"
      executor: claudecode
      test_command: "test -f plan/archive/playbook-core-system-completion.md && echo PASS || echo FAIL"

    - id: p3.2
      criterion: "playbook-core-system-completion.md が plan/active/ に存在しない"
      executor: claudecode
      test_command: "test ! -f plan/active/playbook-core-system-completion.md && echo PASS || echo FAIL"

  status: done
  max_iterations: 3

- id: p4
  name: 統合テスト
  goal: 全ての修正が正しく動作することを検証
  depends_on: [p3]

  subtasks:
    - id: p4.1
      criterion: "init-guard.sh の構文が正しい"
      executor: claudecode
      test_command: "bash -n .claude/hooks/init-guard.sh && echo PASS || echo FAIL"

    - id: p4.2
      criterion: "session-start.sh の構文が正しい"
      executor: claudecode
      test_command: "bash -n .claude/hooks/session-start.sh && echo PASS || echo FAIL"

    - id: p4.3
      criterion: "system-health-check.sh の構文が正しい"
      executor: claudecode
      test_command: "bash -n .claude/hooks/system-health-check.sh && echo PASS || echo FAIL"

    - id: p4.4
      criterion: "state.md と playbook の整合性がある"
      executor: claudecode
      test_command: |
        PLAYBOOK=$(grep "^active:" state.md | sed 's/active: *//')
        MILESTONE=$(grep "^milestone:" state.md | sed 's/milestone: *//')
        if [[ "$PLAYBOOK" == "null" || -n "$MILESTONE" && "$MILESTONE" != "null" ]]; then
          echo PASS
        else
          echo FAIL
        fi

  status: done
  max_iterations: 5
```

---

## 変更履歴

| 日時 | 内容 |
|------|------|
| 2025-12-14 | 初版作成。M021 対応。main からの差分バグ修正。 |
