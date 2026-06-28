# 🏆 Simple Leaderboard Pro

<p align="center">
  <a href="https://ko-fi.com/suzutaku" target="_blank"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Support on Ko-fi" height="40"></a>
  <a href="https://buymeacoffee.com/suzutaku" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="40"></a>
</p>

**[ 日本語 (Japanese) / English ]**

---

# 🇯🇵 日本語マニュアル

**Godot 4 & Unity 両対応！維持費ゼロの最強サーバーレス・オンラインランキングアセット**

「Simple Leaderboard Pro」は、ゲーム開発者が **「Prefab（ノード）を1つポン置きするだけ」** で、即座に「TODAY（今日）」「WEEKLY（週間）」「MONTHLY（月間）」「ALL-TIME（全期間）」の4つのタブ付きリッチオンラインランキング機能をゲームに組み込めるプロ仕様のプラグインです。

## 🔥 なぜこのアセットが最強なのか？（3つの強み）

### 1. 永久にサーバー維持費ゼロ＆1分でデプロイ！
バックエンドに **Cloudflare Workers + D1 (SQL)** を採用。
クレジットカード不要・月間数百万リクエストまで無料の圧倒的枠組みを利用するため、個人〜中規模ゲームなら**完全無料でサーバー運用が可能**です。

### 2. スタイリッシュでクールな「英語表記のポップ系UI」
海外向けゲームや日本のスタイリッシュなゲームにそのままハマるよう、UIはすべてクールな英語表記（TODAY, WEEKLY, ALL-TIME 等）と、極太フチ取りのポップなアニメーションデザインで構築されています。

### 3. スコア送信も1行コードを書くだけ
* **Godot 4:**
  ```gdscript
  LeaderboardManager.submit_score("player_123", "Taro", 5000)
  ```
* **Unity:**
  ```csharp
  LeaderboardManager.Instance.SubmitScore("player_123", "Taro", 5000);
  ```

💡 **実際のゲームでの一般的な組み込み手順（実践フロー）**
1. 画面下部の入力欄は**開発テスト用**です！本番のゲームに組み込む際は、`LeaderboardUI` ノードのインスペクターにある **「Show Demo Form」** のチェックを外すだけで非表示にできます。
2. ゲームクリア時やゲームオーバー時に、上記スクリプトを1行実行してプログラムから自動でスコアを送信します。
3. その後、この `LeaderboardUI` をポップアップ表示すれば、プレイヤーは自分の順位と最新ランキングを即座に確認できます！

---

# 🇺🇸 English Manual

<p align="center">
  <a href="https://ko-fi.com/suzutaku" target="_blank"><img src="https://ko-fi.com/img/githubbutton_sm.svg" alt="Support on Ko-fi" height="40"></a>
  <a href="https://buymeacoffee.com/suzutaku" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="40"></a>
</p>

**Cross-Platform Serverless Online Leaderboard for Godot 4 & Unity with ZERO Server Maintenance Costs!**

"Simple Leaderboard Pro" is a professional asset that allows game developers to integrate a rich, online leaderboard system simply by **dropping a single node/prefab into their scene**. It natively supports 4 time-filtering tabs: **TODAY**, **WEEKLY**, **MONTHLY**, and **ALL-TIME**.

## 🔥 Why This Asset is the Best

### 1. Zero Forever Maintenance Cost & 1-Minute Deploy
Powered by **Cloudflare Workers + D1 (SQL)**. With Cloudflare's massive free tier (millions of requests/month), indie developers can host their game's backend **completely free forever** with no credit card required.

### 2. Universal Pop-Style English UI
Designed with vivid colors, bold fonts, and playful bouncy micro-animations. Top 3 players receive special Gold 🥇, Silver 🥈, and Bronze 🥉 styling. Ready for global release out of the box!

### 3. Submit Scores with Just One Line of Code
* **Godot 4:**
  ```gdscript
  LeaderboardManager.submit_score("player_123", "Hero", 5000)
  ```
* **Unity:**
  ```csharp
  LeaderboardManager.Instance.SubmitScore("player_123", "Hero", 5000);
  ```

## 📦 インストール＆クイックスタート (Installation & Quick Start)

### 1️⃣ バックエンドのデプロイ (約1分・完全無料)
1. `backend/` フォルダを開き、ターミナルで `npm install` を実行します。
2. `npx wrangler login` で Cloudflare にログインし、`npx wrangler d1 create leaderboard_db` でデータベースを作成します。
3. `npm run db:init:prod` → `npm run deploy` でデプロイ完了！発行された API URL をコピーします。
*(💡 詳細は [backend/README.md](file:///Users/suzutaku/Desktop/game/Simple%20Leaderboard%20Pro/backend/README.md) をご参照ください)*

### 2️⃣ ゲームエンジンへの組み込み

#### 🎮 Godot 4 の場合
1. このリポジトリの `godot_project/addons/simple_leaderboard_pro/` フォルダを、ご自身のプロジェクトの `addons/` フォルダ内にコピーします。
2. プロジェクト設定の「プラグイン」タブから **Simple Leaderboard Pro** を有効化（または AutoLoad / ノード配置）します。
3. シーンに `LeaderboardUI` ノードを配置し、インスペクターの `Api Url` に ①で取得した API URL を貼り付けます。

#### 🕹️ Unity の場合
1. このリポジトリの `unity_package/` フォルダを、ご自身の Unity プロジェクトの `Packages/` または `Assets/` 内にコピーします。
2. シーン内の `LeaderboardManager` （またはプレハブ）の `Api Url` に ①で取得した API URL を貼り付けます。

---

## 📁 Directory Structure / 構成

* `backend/` : Cloudflare Workers + D1 Backend API source code & deploy configs
* `godot_project/` : Godot 4 Demo project & Addon (`addons/simple_leaderboard_pro/`)
* `unity_package/` : Unity Package source code & Prefab scripts

