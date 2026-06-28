extends Node
# class_name LeaderboardManager (AutoLoadのシングルトン名との衝突を避けるため無効化)

signal score_submitted(success: bool, message: String)
signal leaderboard_loaded(period: String, leaderboard_data: Array)

## Cloudflare Workers 等でデプロイしたAPIのURL (末尾スラッシュ無し)
@export var api_url: String = "http://localhost:8787"
## リーダーボード識別子 (例: "default", "hard", "stage1")
@export var board_id: String = "default"

var _http_request: HTTPRequest

func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

## スコアを送信する
func submit_score(player_id: String, player_name: String, score: int, metadata: Dictionary = {}) -> void:
	if api_url.is_empty():
		push_error("LeaderboardManager: API URL is not set!")
		emit_signal("score_submitted", false, "API URL is not configured.")
		return

	var url = api_url + "/api/score"
	var headers = ["Content-Type: application/json"]
	var payload = {
		"board_id": board_id,
		"player_id": player_id,
		"player_name": player_name,
		"score": score,
		"metadata": metadata
	}
	
	var json_str = JSON.stringify(payload)
	var err = _http_request.request(url, headers, HTTPClient.METHOD_POST, json_str)
	if err != OK:
		emit_signal("score_submitted", false, "Failed to send HTTP request.")

## 指定期間のランキングを取得する ("today", "weekly", "monthly", "all")
func fetch_leaderboard(period: String = "all", limit: int = 50) -> void:
	if api_url.is_empty():
		push_error("LeaderboardManager: API URL is not set!")
		emit_signal("leaderboard_loaded", period, [])
		return

	var url = "%s/api/leaderboard?board_id=%s&period=%s&limit=%d" % [api_url, board_id, period, limit]
	var err = _http_request.request(url)
	if err != OK:
		emit_signal("leaderboard_loaded", period, [])

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		emit_signal("score_submitted", false, "Network error.")
		return

	var response_str = body.get_string_from_utf8()
	var json = JSON.parse_string(response_str)
	
	if not json is Dictionary:
		emit_signal("score_submitted", false, "Invalid server response.")
		return

	# エンドポイント判定 (レスポンス内に leaderboard フィールドがあるかどうか)
	if json.has("leaderboard"):
		emit_signal("leaderboard_loaded", json.get("period", "all"), json.get("leaderboard", []))
	elif json.has("success"):
		var success = json.get("success", false)
		var msg = json.get("message", "") if success else json.get("error", "Unknown error")
		emit_signal("score_submitted", success, msg)
