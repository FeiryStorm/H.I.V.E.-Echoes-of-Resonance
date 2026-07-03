## ⬢ game_world.gd ⬢
## The top-level world controller orchestrating match state, cameras, and persistent HUD displays.
extends Node2D
class_name GameWorld

# --- NODES ---
@onready var camera: Camera2D = $WorldCamera as Camera2D
@onready var grid: HexGrid = $HexGrid as HexGrid
@onready var passive_display: AbilityHex = $CanvasLayer/GuardianInfo/PassiveDisplay as AbilityHex

# --- ENGINE CORES ---

func _ready() -> void:
	print("⬢ World | Initializing game arena.")
	_setup_camera()
	
	# Wait for grid nodes to settle before binding global configurations
	await get_tree().process_frame
	_sync_global_guardian_info()

# --- LOGICAL CORE METHODS ---

## Centers the viewport camera perfectly onto the center of the hex grid.
func _setup_camera() -> void:
	if camera and grid:
		camera.make_current()
		# Snap camera to grid origin point
		camera.global_position = grid.global_position
		camera.zoom = Vector2(1.0, 1.0)
		print("⬢ Camera | Centered on Grid at position: ", grid.global_position)
	else:
		push_warning("⬢ Camera | Setup failed: Camera or Grid reference is missing!")

## Configures the persistent passive capability hud display at the screen edge.
func _sync_global_guardian_info() -> void:
	if not passive_display or not grid:
		push_warning("⬢ World | HUD Synchronization aborted: UI or Grid not ready!")
		return
		
	var active_resource: GuardianResource = null
	
	# Determine active configuration straight from selected metadata
	match GlobalSettings.selected_animal:
		HexData.Owner.WOLF:
			active_resource = grid.wolf_resource
		HexData.Owner.SHARK:
			active_resource = grid.shark_resource
		_:
			push_warning("⬢ World | No active player guardian selected. Passive HUD hidden.")
			passive_display.visible = false
			return

	if active_resource:
		passive_display.visible = true
		passive_display.ability_name = active_resource.passive_name
		# 🌀 DYNAMIC: Fetches the dynamically formatted description string
		passive_display.ability_description = active_resource.get_formatted_passive_description()
		passive_display.icon_texture = active_resource.passive_icon
		
		# Apply procedural fine-tuning offsets direct from resource
		passive_display.radius = active_resource.passive_icon_radius
		passive_display.icon_scale = active_resource.passive_icon_scale
		passive_display.icon_offset = active_resource.passive_icon_offset
		
		# --- HARMONIC HOVER CONNECTIONS (Radial Menu Style) ---
		# Input detection override for physics-picking Area2D nodes
		passive_display.input_pickable = true
		
		# Safe hover signal wiring cleanup
		if passive_display.mouse_entered.is_connected(_on_passive_hover_start):
			passive_display.mouse_entered.disconnect(_on_passive_hover_start)
		passive_display.mouse_entered.connect(_on_passive_hover_start)
		
		if passive_display.mouse_exited.is_connected(_on_passive_hover_end):
			passive_display.mouse_exited.disconnect(_on_passive_hover_end)
		passive_display.mouse_exited.connect(_on_passive_hover_end)
		
		# Force refresh to redraw the hex button layout
		if passive_display.has_method("_update_geometry"):
			passive_display._update_geometry()

# --- SIGNALS & HOVER CORES FOR PASSIVE HUD ---

func _on_passive_hover_start() -> void:
	var central_label := $CanvasLayer/GuardianInfo/AbilityDescriptionLabel as Label
	if central_label and passive_display:
		central_label.text = str(passive_display.ability_name) + "\n" + str(passive_display.ability_description)

func _on_passive_hover_end() -> void:
	var central_label := $CanvasLayer/GuardianInfo/AbilityDescriptionLabel as Label
	if central_label:
		central_label.text = ""