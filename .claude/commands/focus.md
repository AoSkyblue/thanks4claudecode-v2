---
description: state.md の focus.current を切り替える。setup/product/plan-template の切り替えに使用。
allowed-tools: Read, Edit, Bash
argument-hint: <focus-value>
---

# /focus - フォーカスの切り替え

state.md の `focus.current` を指定した値に変更してください。

## 引数

- `$1`: 切り替え先のフォーカス値（setup | product | plan-template）

## 実行内容

1. 現在の `focus.current` を確認
2. 指定された値に変更
3. 変更結果を報告

## 現在の state.md focus セクション

```
!bash grep -A5 "## focus" state.md
```

## 変更先

`$ARGUMENTS`

---

**注意**: 引数が空の場合は、現在のフォーカスを表示するだけにしてください。
