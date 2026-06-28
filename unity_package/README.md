# Simple Leaderboard Pro - Unity Package

**Simple Leaderboard Pro** は、Unity 2021.3 以降に対応したクロスプラットフォーム・オンラインランキングシステムです。
Prefab を 1 つシーンに配置するだけで、美しいポップ系 UI 付きのリーダーボードが即座に動作します。

---

## 📦 導入方法 (インストール)

1. Unity エディタのメニューバーから `Window` > `Package Manager` を開きます。
2. 左上の `+` ボタンをクリックし、`Add package from disk...` を選択します。
3. このフォルダ内の `package.json` を選択してインポートします。

---

## 🛠️ 使い方 (クイックスタート)

1. シーンに `LeaderboardManager` コンポーネントをアタッチした空のゲームオブジェクトを配置します。
2. インスペクターの `Api Url` に、デプロイした Cloudflare Workers の URL を貼り付けます（例: `https://your-app.workers.dev`）。
3. 用意されている `LeaderboardUI` プレハブを Canvas 配下に配置して実行するだけで完成です！

### スコア送信をスクリプトから呼び出す例
ゲームクリア時やゲームオーバー時に以下を1行呼び出すだけです：

```csharp
SimpleLeaderboardPro.LeaderboardManager.Instance.SubmitScore("user_123", "勇者タロウ", 9999);
```
