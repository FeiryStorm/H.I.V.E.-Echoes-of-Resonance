## ⬢ game_world.gd ⬢
## The top-level controller for the active match.
extends Node2D

# --- ENGINE CORES ---

func _ready() -> void:
	print("⬢ H.I.V.E. | Game World initialized.")
	_setup_camera()
	# Call this AFTER the grid has initialized on the next frame
	await get_tree().process_frame
	_sync_global_guardian_info()

# --- LOGIC ---

## Centers the camera on the grid and ensures proper zoom.
func _setup_camera() -> void:
	var camera := $WorldCamera as Camera2D
	var grid := $HexGrid as Node2D
	
	if camera and grid:
		camera.make_current()
		# Synchronize camera position with the grid's offset
		camera.global_position = grid.global_position
		camera.zoom = Vector2(1.0, 1.0)
		print("⬢ Camera centered on Grid at: ", grid.global_position)

func _sync_global_guardian_info() -> void:
	var passive_display = get_node_or_null("CanvasLayer/GuardianInfo/PassiveDisplay")
	var grid = get_node_or_null("HexGrid")
	
	if not passive_display or not grid: return
	
	var active_resource: GuardianResource = null
	
	# Determine which resource to fetch based on player selection
	match GlobalSettings.selected_animal:
		HexData.Owner.WOLF:
			active_resource = grid.wolf_resource
		HexData.Owner.SHARK:
			active_resource = grid.shark_resource
			
# Inject the full resource properties directly into the display cell
	if active_resource:
		passive_display.ability_name = active_resource.passive_name
		# FIX: Ensure it writes to exactly the variables defined in ability_hex.gd
		passive_display.ability_description = active_resource.passive_description
		passive_display.icon_texture = active_resource.passive_icon
		
		# Apply your exact custom fine-tuning values from the resource
		passive_display.radius = active_resource.passive_radius
		passive_display.icon_scale = active_resource.passive_icon_scale
		passive_display.icon_offset = active_resource.passive_icon_offset
		
		# Force refresh so it immediately redraws with text capability
		if passive_display.has_method("_update_visuals"):
			passive_display._update_visuals()





func _on_passive_display_mouse_entered() -> void:
	pass # Replace with function body.

func _on_passive_display_mouse_exited() -> void:
	pass # Replace with function body.
