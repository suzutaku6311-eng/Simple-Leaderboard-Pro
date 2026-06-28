# Simple Leaderboard Pro - Backend Setup Guide

**Simple Leaderboard Pro** のバックエンドは **Cloudflare Workers + D1** を使用しています。
維持費は**完全無料**で、わずか3ステップ・約1分でデプロイが完了します。

---

## 🚀 1分セットアップ手順

### Step 1. Cloudflare にログイン＆データベース作成
1. ターミナルで以下のコマンドを実行し、Cloudflareにログインします。
   ```bash
   npx wrangler login
   ```
2. 新しいデータベースを作成します。
   ```bash
   npx wrangler d1 create leaderboard_db
   ```
   出力された `database_id = "xxxx-xxxx-xxxx"` をコピーし、`wrangler.toml` に貼り付けます。

### Step 2. テーブル（スキーマ）の初期化
本番環境のデータベースにテーブルを作成します。
```bash
npm run db:init:prod
```

### Step 3. デプロイ
以下のコマンドでサーバーレスAPIをCloudflareにデプロイします！
```bash
npm run deploy
```
デプロイが完了すると、`https://simple-leaderboard-pro-backend.<your-subdomain>.workers.dev` のような URL が発行されます。これがあなたの **API URL** です。

Godot や Unity の LeaderboardManager のプロパティにこの URL を貼り付ければ、ランキング機能の導入は完了です！ 🎉
