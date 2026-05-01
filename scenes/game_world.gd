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
func _setup_camera() -> void:
	var camera := $WorldCamera as Camera2D
	if camera:
		# Ensure the camera is active
		camera.make_current()
		
		# Center the camera based on the viewport size
		# This aligns the grid's (0,0) with the screen center
		var screen_center := get_viewport_rect().size / 2
		camera.offset = Vector2.ZERO # Reset offset
		camera.position = Vector2.ZERO # Grid center is 0,0
		
		# Pro-Tip: If you want to zoom out to see the whole grid:
		camera.zoom = Vector2(0.8, 0.8) 

## Debug info about the chosen match
func _display_match_info() -> void:
	var player_name := GlobalSettings.get_owner_name(GlobalSettings.selected_animal)
	print("⬢ Match Started | Player: ", player_name)
	print("⬢ Rivals: ", GlobalSettings.selected_rivals.size())
