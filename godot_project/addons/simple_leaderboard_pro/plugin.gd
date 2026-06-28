@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("LeaderboardManager", "Node", preload("res://addons/simple_leaderboard_pro/leaderboard_manager.gd"), null)

func _exit_tree() -> void:
	remove_custom_type("LeaderboardManager")
