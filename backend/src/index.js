/**
 * Simple Leaderboard Pro - Cloudflare Workers Backend
 * Zero-dependency, Ultra-fast Serverless API
 */

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const method = request.method;

    // CORS ヘッダーの設定 (WebGL / Webアプリ等からのアクセスを許可)
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    };

    // OPTIONS プレフライトリクエストの処理
    if (method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      // API: スコア送信
      if (url.pathname === "/api/score" && method === "POST") {
        return await handlePostScore(request, env, corsHeaders);
      }

      // API: ランキング取得
      if (url.pathname === "/api/leaderboard" && method === "GET") {
        return await handleGetLeaderboard(url, env, corsHeaders);
      }

      // 404 Not Found
      return new Response(JSON.stringify({ error: "Endpoint not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    } catch (err) {
      console.error(err);
      return new Response(JSON.stringify({ error: "Internal Server Error", details: err.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
  },
};

/**
 * スコア送信処理
 */
async function handlePostScore(request, env, corsHeaders) {
  const body = await request.json();
  const { board_id = "default", player_id, player_name, score, metadata = {} } = body;

  // バリデーション
  if (!player_id || !player_name || typeof score !== "number") {
    return new Response(
      JSON.stringify({ error: "Invalid parameters. 'player_id', 'player_name', and numeric 'score' are required." }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  // 文字列トリムおよび長さ制限
  const cleanName = String(player_name).trim().slice(0, 32);
  const cleanMetadata = JSON.stringify(metadata);

  // データベースへの挿入
  await env.DB.prepare(
    `INSERT INTO scores (board_id, player_id, player_name, score, metadata) VALUES (?, ?, ?, ?, ?)`
  )
    .bind(board_id, player_id, cleanName, Math.round(score), cleanMetadata)
    .run();

  return new Response(JSON.stringify({ success: true, message: "Score submitted successfully" }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/**
 * ランキング取得処理
 */
async function handleGetLeaderboard(url, env, corsHeaders) {
  const board_id = url.searchParams.get("board_id") || "default";
  const period = url.searchParams.get("period") || "all"; // 'today', 'weekly', 'monthly', 'all'
  const limit = Math.min(parseInt(url.searchParams.get("limit") || "50", 10), 100);

  let dateCondition = "";
  if (period === "today") {
    dateCondition = "AND created_at >= datetime('now', 'start of day')";
  } else if (period === "weekly") {
    dateCondition = "AND created_at >= datetime('now', '-7 days')";
  } else if (period === "monthly") {
    dateCondition = "AND created_at >= datetime('now', 'start of month')";
  }

  // プレイヤーごとに期間内の最高スコアを取得してソート
  const query = `
    SELECT player_id, player_name, MAX(score) as score, metadata, MIN(created_at) as created_at
    FROM scores
    WHERE board_id = ? ${dateCondition}
    GROUP BY player_id
    ORDER BY score DESC, created_at ASC
    LIMIT ?
  `;

  const { results } = await env.DB.prepare(query).bind(board_id, limit).all();

  // JSON文字列として保存された metadata をパースして返す
  const formattedResults = results.map((row, index) => ({
    rank: index + 1,
    player_id: row.player_id,
    player_name: row.player_name,
    score: row.score,
    metadata: parseJSON(row.metadata),
    created_at: row.created_at,
  }));

  return new Response(JSON.stringify({ success: true, period, board_id, leaderboard: formattedResults }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function parseJSON(str) {
  try {
    return JSON.parse(str);
  } catch {
    return {};
  }
}
