## ⬢ save_manager.gd ⬢ - Handles player persistence and echoes of the past
extends Node

const SAVE_PATH := "user://hive_profile.save"

var player_data := {
	"last_guardian": HexData.Owner.WOLF,
	"unlocked_lore": [],
	"high_score": 0
}

func save_profile() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(player_data)
		print("H.I.V.E. | Profile synchronized.")

func load_profile() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		player_data = file.get_var()
		print("H.I.V.E. | Welcome back, Guardian.")
