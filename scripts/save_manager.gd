## ⬢ save_manager.gd ⬢
## Autoload Singleton managing player profile persistence and game state serialization.
extends Node

# --- CONFIGURATION ---
const SAVE_PATH: String = "user://hive_profile.save"

# --- STATE ---
var player_data: Dictionary = {
	"last_guardian": HexData.Owner.WOLF,
	"unlocked_lore": [],
	"high_score": 0
}

# --- PUBLIC METHODS ---

## Serializes and writes player profile data to secure user storage.
func save_profile() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(player_data)
		file.close()
		print("⬢ Save | Profile synchronized successfully.")
	else:
		push_error("⬢ Save | Failed to open save path: " + SAVE_PATH)

## Loads and deserializes player profile data from user storage if it exists.
func load_profile() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var loaded_data = file.get_var()
			file.close()
			
			if loaded_data is Dictionary:
				player_data = loaded_data
				print("⬢ Save | Welcome back, Guardian.")
			else:
				push_warning("⬢ Save | Corrupted save file data structure. Utilizing default profile.")
		else:
			push_error("⬢ Save | Failed to read save file at: " + SAVE_PATH)
	else:
		print("⬢ Save | No profile found. Initializing new player matrix.")