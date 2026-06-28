extends Control

@onready var manager: LeaderboardManager = $LeaderboardManager
@onready var main_panel: PanelContainer = $CenterContainer/MainPanel
@onready var tab_today: Button = $CenterContainer/MainPanel/VBox/Tabs/BtnToday
@onready var tab_weekly: Button = $CenterContainer/MainPanel/VBox/Tabs/BtnWeekly
@onready var tab_monthly: Button = $CenterContainer/MainPanel/VBox/Tabs/BtnMonthly
@onready var tab_all: Button = $CenterContainer/MainPanel/VBox/Tabs/BtnAll
@onready var list_container: VBoxContainer = $CenterContainer/MainPanel/VBox/ScrollContainer/ListContainer
@onready var status_label: Label = $CenterContainer/MainPanel/VBox/StatusLabel

# デモ用送信フォーム
@onready var input_name: LineEdit = $CenterContainer/MainPanel/VBox/SubmitBox/InputName
@onready var input_score: SpinBox = $CenterContainer/MainPanel/VBox/SubmitBox/InputScore
@onready var btn_submit: Button = $CenterContainer/MainPanel/VBox/SubmitBox/BtnSubmit

const RANK_ITEM_SCENE = preload("res://addons/simple_leaderboard_pro/rank_item.tscn")

## 開発テスト確認用の送信フォームを表示するか（ゲーム本番へ組み込む際は false にチェックを外します）
@export var show_demo_form: bool = false

var current_period: String = "all"

func _ready() -> void:
	# テスト用フォームの表示／非表示切り替え
	$CenterContainer/MainPanel/VBox/SubmitBox.visible = show_demo_form

	# レスポンシブ対応 (スマホ等の画面変化に自動フィット)
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()

	# ポップインアニメーション (画面開いたときにポヨンと大きくなる)
	main_panel.pivot_offset = main_panel.custom_minimum_size / 2.0
	main_panel.scale = Vector2(0.8, 0.8)
	main_panel.modulate.a = 0.0
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(main_panel, "scale", Vector2.ONE, 0.4)
	tween.tween_property(main_panel, "modulate:a", 1.0, 0.3)

	# シグナル接続
	manager.leaderboard_loaded.connect(_on_leaderboard_loaded)
	manager.score_submitted.connect(_on_score_submitted)
	
	tab_today.pressed.connect(func(): _switch_tab("today", tab_today))
	tab_weekly.pressed.connect(func(): _switch_tab("weekly", tab_weekly))
	tab_monthly.pressed.connect(func(): _switch_tab("monthly", tab_monthly))
	tab_all.pressed.connect(func(): _switch_tab("all", tab_all))
	
	btn_submit.pressed.connect(_on_submit_pressed)
	$CenterContainer/MainPanel/VBox/Header/BtnClose.pressed.connect(_on_close_pressed)

	# タイトルロゴにポップな極太＆縁取りフォントを適用
	var pop_font = SystemFont.new()
	pop_font.font_names = PackedStringArray(["Arial Rounded MT Bold", "Hiragino Maru Gothic ProN", "Meiryo", "Sans-Serif"])
	pop_font.font_weight = 800
	
	var title_label = $CenterContainer/MainPanel/VBox/Header/TitleLabel
	title_label.add_theme_font_override("font", pop_font)
	title_label.add_theme_constant_override("outline_size", 10)
	title_label.add_theme_color_override("font_outline_color", Color(0.2, 0.05, 0.35, 1.0))

	# 送信ボタン等の文字は見やすさ重視ですっきりさせる
	btn_submit.add_theme_font_size_override("font_size", 18)

	# 初期表示は全期間
	_switch_tab("all", tab_all)

func _switch_tab(period: String, active_btn: Button) -> void:
	current_period = period
	status_label.text = "Loading..."
	status_label.show()
	
	# タブの見た目更新
	for btn in [tab_today, tab_weekly, tab_monthly, tab_all]:
		btn.modulate = Color(1.0, 1.0, 1.0, 0.5) if btn != active_btn else Color(1.0, 1.0, 1.0, 1.0)
		if btn == active_btn:
			var t = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			btn.scale = Vector2(1.1, 1.1)
			t.tween_property(btn, "scale", Vector2.ONE, 0.2)
	
	# リストをクリア
	for child in list_container.get_children():
		child.queue_free()
		
	manager.fetch_leaderboard(period)

func _on_leaderboard_loaded(period: String, data: Array) -> void:
	if period != current_period:
		return
		
	status_label.hide()
	for child in list_container.get_children():
		child.queue_free()
		
	if data.is_empty():
		status_label.text = "No scores yet! Be the first challenger!"
		status_label.show()
		return
		
	for item in data:
		var rank_node = RANK_ITEM_SCENE.instantiate()
		list_container.add_child(rank_node)
		rank_node.setup(item.get("rank", 0), item.get("player_name", "Unknown"), int(item.get("score", 0)))
		# アニメーションで順次表示
		rank_node.modulate.a = 0.0
		var t = create_tween()
		t.tween_property(rank_node, "modulate:a", 1.0, 0.2)

func _on_submit_pressed() -> void:
	var player_name = input_name.text.strip_edges()
	if player_name.is_empty():
		player_name = "Player_" + str(randi() % 1000)
	var score = int(input_score.value)
	
	btn_submit.disabled = true
	btn_submit.text = "Sending..."
	
	# プレイヤーIDとして名前のMD5ハッシュ文字列を使う
	var player_id = "user_" + player_name.md5_text()
	manager.submit_score(player_id, player_name, score)

func _on_score_submitted(success: bool, message: String) -> void:
	btn_submit.disabled = false
	btn_submit.text = "SUBMIT!"
	if success:
		status_label.text = "🎉 Score submitted!"
		status_label.show()
		_switch_tab(current_period, _get_btn_by_period(current_period))
	else:
		status_label.text = "Error: " + message
		status_label.show()

func _get_btn_by_period(p: String) -> Button:
	match p:
		"today": return tab_today
		"weekly": return tab_weekly
		"monthly": return tab_monthly
		_: return tab_all

func _on_close_pressed() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(main_panel, "scale", Vector2(0.8, 0.8), 0.2)
	tween.tween_property(main_panel, "modulate:a", 0.0, 0.2)
	tween.finished.connect(queue_free)

## 画面サイズ（スマホ／PC）に合わせたレスポンシブ自動縮尺・拡大
func _on_viewport_resized() -> void:
	if not is_instance_valid(main_panel): return
	var vp_size = get_viewport_rect().size
	# 中身のリストや余白をすべて合計した「本当の必要サイズ」を取得（これで計算ズレによる見切れを根絶）
	var panel_size = main_panel.get_combined_minimum_size()
	# 画面全体に対して横92%、縦88%（上下に美しい余白を確保）で迫力ある最大サイズに自動調整
	var target_scale = min((vp_size.x * 0.92) / panel_size.x, (vp_size.y * 0.88) / panel_size.y)
	main_panel.scale = Vector2(target_scale, target_scale)
	main_panel.pivot_offset = panel_size / 2.0
