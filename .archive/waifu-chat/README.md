# Waifu Chat

美少女キャラクターと会話できる Web チャットアプリケーション。

## 概要

Waifu Chat は、可愛い美少女キャラクターと自然な会話を楽しめる Web アプリケーションです。
Next.js 14 (App Router) + TypeScript + Tailwind CSS で構築されています。

## 機能

- リアルタイムチャット UI
- 美少女キャラクター表示
- AI 風のモック返答
- 会話履歴の保持
- ローディングインジケータ
- レスポンシブデザイン

## 技術スタック

- **フレームワーク**: Next.js 14 (App Router)
- **言語**: TypeScript
- **スタイリング**: Tailwind CSS
- **API**: Next.js API Routes

## セットアップ

### 1. 依存関係のインストール

```bash
npm install
```

### 2. 開発サーバーの起動

```bash
npm run dev
```

### 3. ブラウザでアクセス

http://localhost:3000 を開いてください。

## ディレクトリ構成

```
src/
├── app/
│   ├── api/chat/route.ts    # AI チャット API
│   ├── globals.css          # グローバルスタイル
│   ├── layout.tsx           # ルートレイアウト
│   └── page.tsx             # メインページ
├── components/
│   ├── ChatInput.tsx        # チャット入力フォーム
│   ├── MessageList.tsx      # メッセージ一覧
│   └── WaifuCharacter.tsx   # キャラクター表示
public/
└── waifu.svg                # キャラクター画像
```

## ライセンス

MIT
