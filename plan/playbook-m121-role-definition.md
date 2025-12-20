# playbook-m121-role-definition.md

> **M121: 役割定義の明確化 - code_reviewer / playbook_reviewer を追加**

---

## meta

```yaml
schema_version: v2
project: thanks4claudecode
branch: feat/layer-architecture
created: 2025-12-21
issue: null
derives_from: M121
reviewed: false
```

---

## goal

```yaml
summary: "役割定義を明確化し、code_reviewer と playbook_reviewer を追加する"
done_when:
  - docs/ai-orchestration.md に code_reviewer と playbook_reviewer が定義されている
  - role-resolver.sh が code_reviewer と playbook_reviewer を解決できる
  - plan/template/playbook-format.md に新役割が記載されている
```

---

## phases

### p1: ドキュメント更新

**goal**: docs/ai-orchestration.md の役割定義テーブルを更新する

#### subtasks

- [x] **p1.1**: docs/ai-orchestration.md の役割テーブルに code_reviewer が追加されている
  - executor: claudecode
  - test_command: `grep -q 'code_reviewer' docs/ai-orchestration.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep コマンドが正常に動作"
    - consistency: "PASS - 役割定義テーブルの形式が一貫"
    - completeness: "PASS - Toolstack A/B/C 全てに記載"
  - validated: 2025-12-21T02:00:00

- [x] **p1.2**: docs/ai-orchestration.md の役割テーブルに playbook_reviewer が追加されている
  - executor: claudecode
  - test_command: `grep -q 'playbook_reviewer' docs/ai-orchestration.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep コマンドが正常に動作"
    - consistency: "PASS - worker の逆として定義"
    - completeness: "PASS - 警告表示の注釈あり"
  - validated: 2025-12-21T02:00:00

**status**: done
**max_iterations**: 5

---

### p2: role-resolver.sh 更新

**goal**: role-resolver.sh に code_reviewer と playbook_reviewer の解決ロジックを追加する

**depends_on**: [p1]

#### subtasks

- [x] **p2.1**: role-resolver.sh が code_reviewer を有効な役割として認識する
  - executor: claudecode
  - test_command: `bash .claude/hooks/role-resolver.sh code_reviewer && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - claudecode を返す"
    - consistency: "PASS - reviewer のエイリアスとして動作"
    - completeness: "PASS - 全 Toolstack で解決"
  - validated: 2025-12-21T02:00:00

- [x] **p2.2**: role-resolver.sh が playbook_reviewer を解決できる
  - executor: claudecode
  - test_command: `bash .claude/hooks/role-resolver.sh playbook_reviewer && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - claudecode を返す"
    - consistency: "PASS - worker の逆を返す"
    - completeness: "PASS - Toolstack A で警告表示"
  - validated: 2025-12-21T02:00:00

- [x] **p2.3**: Toolstack A で playbook_reviewer を解決すると警告が表示される
  - executor: claudecode
  - test_command: `TOOLSTACK=A bash .claude/hooks/role-resolver.sh playbook_reviewer 2>&1 | grep -q 'fallback\|警告\|warning' && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - WARNING メッセージが stderr に出力"
    - consistency: "PASS - claudecode にフォールバック"
    - completeness: "PASS - 理由が明示"
  - validated: 2025-12-21T02:00:00

**status**: done
**max_iterations**: 5

---

### p3: playbook テンプレート更新

**goal**: plan/template/playbook-format.md に新役割を追加する

**depends_on**: [p1]

#### subtasks

- [x] **p3.1**: playbook-format.md の executor 判定ガイドに code_reviewer が記載されている
  - executor: claudecode
  - test_command: `grep -q 'code_reviewer' plan/template/playbook-format.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep コマンドが正常に動作"
    - consistency: "PASS - 既存の形式と一致"
    - completeness: "PASS - 説明・解決先・注意が記載"
  - validated: 2025-12-21T02:00:00

- [x] **p3.2**: playbook-format.md の executor 判定ガイドに playbook_reviewer が記載されている
  - executor: claudecode
  - test_command: `grep -q 'playbook_reviewer' plan/template/playbook-format.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - grep コマンドが正常に動作"
    - consistency: "PASS - worker の逆を明記"
    - completeness: "PASS - 詳細な注意書きあり"
  - validated: 2025-12-21T02:00:00

**status**: done
**max_iterations**: 5

---

### p_final: 完了検証

**goal**: done_when の全項目が満たされていることを検証する

**depends_on**: [p1, p2, p3]

#### subtasks

- [x] **p_final.1**: docs/ai-orchestration.md に code_reviewer と playbook_reviewer が定義されている
  - executor: claudecode
  - test_command: `grep -q 'code_reviewer' docs/ai-orchestration.md && grep -q 'playbook_reviewer' docs/ai-orchestration.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 両方の役割が存在"
    - consistency: "PASS - テーブル形式で正しく定義"
    - completeness: "PASS - Toolstack A/B/C 全て記載"
  - validated: 2025-12-21T02:00:00

- [x] **p_final.2**: role-resolver.sh が code_reviewer と playbook_reviewer を解決できる
  - executor: claudecode
  - test_command: `bash .claude/hooks/role-resolver.sh code_reviewer >/dev/null && bash .claude/hooks/role-resolver.sh playbook_reviewer >/dev/null && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 両役割でエラーなく実行"
    - consistency: "PASS - 期待する executor を返す"
    - completeness: "PASS - 全 Toolstack で動作"
  - validated: 2025-12-21T02:00:00

- [x] **p_final.3**: plan/template/playbook-format.md に新役割が記載されている
  - executor: claudecode
  - test_command: `grep -q 'code_reviewer' plan/template/playbook-format.md && grep -q 'playbook_reviewer' plan/template/playbook-format.md && echo PASS || echo FAIL`
  - validations:
    - technical: "PASS - 両方の役割が存在"
    - consistency: "PASS - 既存の形式と統一"
    - completeness: "PASS - 用途と例が含まれる"
  - validated: 2025-12-21T02:00:00

**status**: done
**max_iterations**: 3

---

## final_tasks

- [ ] **ft1**: 変更を全てコミットする
  - command: `git add -A && git commit -m "feat(M121): add code_reviewer and playbook_reviewer roles"`
  - status: pending

- [ ] **ft2**: main ブランチにマージする
  - command: `git checkout main && git merge feat/layer-architecture --no-edit`
  - status: pending
  - note: playbook.active 設定中に実行必須

- [ ] **ft3**: playbook をアーカイブする
  - command: `mkdir -p plan/archive && mv plan/playbook-m121-role-definition.md plan/archive/`
  - status: pending

- [ ] **ft4**: state.md を更新する
  - command: `# playbook.active を null に、last_archived を更新`
  - status: pending
