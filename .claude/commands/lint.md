---
description: state.md と playbook の整合性チェックを実行。コミット前の検証に使用。
allowed-tools: Read, Bash
---

# /lint - 整合性チェックの実行

state.md と playbook の整合性をチェックしてください。

## 実行内容

```bash
bash .claude/hooks/check-coherence.sh
```

## チェック項目

1. state.md と playbook の整合性
2. focus.current の有効性（setup | product | plan-template）
3. staged ファイルと focus の矛盾検出

---

結果を報告し、問題があれば修正案を提示してください。
