extends PanelContainer

@onready var rank_label: Label = $HBox/RankLabel
@onready var name_label: Label = $HBox/NameLabel
@onready var score_label: Label = $HBox/ScoreLabel

func setup(rank: int, player_name: String, score: int, is_top_three: bool = false) -> void:
	rank_label.text = str(rank)
	name_label.text = player_name
	score_label.text = str(score)
	
	# ポップ系デザイン：トップ3には特別な色を付ける
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	if rank == 1:
		style.bg_color = Color(1.0, 0.84, 0.0, 0.9) # ゴールド
		style.border_color = Color(1.0, 0.95, 0.4)
		style.border_width_bottom = 4
		rank_label.text = "🥇 " + str(rank)
	elif rank == 2:
		style.bg_color = Color(0.75, 0.78, 0.8, 0.9) # シルバー
		style.border_color = Color(0.9, 0.95, 1.0)
		style.border_width_bottom = 4
		rank_label.text = "🥈 " + str(rank)
	elif rank == 3:
		style.bg_color = Color(0.8, 0.5, 0.2, 0.9) # ブロンズ
		style.border_color = Color(0.95, 0.65, 0.3)
		style.border_width_bottom = 4
		rank_label.text = "🥉 " + str(rank)
	else:
		style.bg_color = Color(0.95, 0.95, 0.98, 0.9) if rank % 2 == 0 else Color(0.88, 0.9, 0.95, 0.9)
		style.border_color = Color(0.7, 0.75, 0.8)
		style.border_width_bottom = 2
	
	add_theme_stylebox_override("panel", style)
	
	# 色調整
	if rank <= 3:
		rank_label.add_theme_color_override("font_color", Color.WHITE)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		score_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		rank_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.3))
		name_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.3))
		score_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.2))

	# ポップ系極太＆縁取りフォントの適用
	var pop_font = SystemFont.new()
	pop_font.font_names = PackedStringArray(["Arial Rounded MT Bold", "Hiragino Maru Gothic ProN", "Meiryo", "Sans-Serif"])
	pop_font.font_weight = 800
	
	for label in [rank_label, name_label, score_label]:
		label.add_theme_font_override("font", pop_font)
		label.add_theme_constant_override("outline_size", 3)
		label.add_theme_color_override("font_outline_color", Color(0.15, 0.1, 0.25, 1.0))

