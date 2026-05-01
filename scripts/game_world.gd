## ⬢ game_world.gd ⬢
## The top-level controller for the active match.
extends Node2D

# --- ENGINE CORES ---

func _ready() -> void:
	print("⬢ H.I.V.E. | Game World initialized.")
	_setup_camera()
	_display_match_info()

# --- LOGIC ---

## Centers the camera on the grid
## ⬢ game_world.gd ⬢
func _setup_camera() -> void:
	var camera := $WorldCamera as Camera2D
	var grid := $HexGrid as Node2D
	
	if camera and grid:
		camera.make_current()
		# Synchronize camera position with the grid's offset
		camera.global_position = grid.global_position
		camera.zoom = Vector2(1.0, 1.0)
		print("⬢ Camera centered on Grid at: ", grid.global_position)



## Debug info about the chosen match
func _display_match_info() -> void:
	var player_name := GlobalSettings.get_owner_name(GlobalSettings.selected_animal)
	print("⬢ Match Started | Player: ", player_name)
	print("⬢ Rivals: ", GlobalSettings.selected_rivals.size())
