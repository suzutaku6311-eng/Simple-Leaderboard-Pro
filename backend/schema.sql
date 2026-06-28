-- Simple Leaderboard Pro - Database Schema (Cloudflare D1 / SQLite)

CREATE TABLE IF NOT EXISTS scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    board_id TEXT NOT NULL DEFAULT 'default', -- リーダーボードの種類 (例: 'normal', 'hard', 'stage1')
    player_id TEXT NOT NULL,                  -- プレイヤーの一意の識別子 (UUID や デバイスID等)
    player_name TEXT NOT NULL,                -- プレイヤーの表示名
    score INTEGER NOT NULL,                   -- スコア
    metadata TEXT DEFAULT '{}',               -- 追加データ (アイコンID、キャラ名などのJSON)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 高速ランキング取得用のインデックス
CREATE INDEX IF NOT EXISTS idx_scores_ranking ON scores (board_id, score DESC, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_scores_player ON scores (board_id, player_id);
