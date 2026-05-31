## ⬢ ability_hex.gd ⬢
## Specialized Hex-Button for Guardian Abilities with instant visual updating.
@tool
extends Area2D

signal ability_pressed(p_name: String)

# --- CONFIGURATION ---
@export_group("Ability Data")
@export var ability_name: String = "Active"
@export var ability_description: String = "Description"

@export var icon_texture: Texture2D:
	set(val):
		icon_texture = val
		if has_node("HexShape/Icon"):
			$HexShape/Icon.texture = val

@export_group("Fine Tuning")
@export var radius: float = 40.0:
	set(val):
		radius = val
		_update_geometry()

@export var icon_scale := Vector2(0.15, 0.15):
	set(val):
		icon_scale = val
		if has_node("HexShape/Icon"):
			$HexShape/Icon.scale = val

@export var icon_offset := Vector2.ZERO:
	set(val):
		icon_offset = val
		if has_node("HexShape/Icon"):
			$HexShape/Icon.position = val

# --- ENGINE CORES ---

func _ready() -> void:
	_update_geometry()
	if has_node("HexShape/Icon"):
		$HexShape/Icon.texture = icon_texture
		$HexShape/Icon.scale = icon_scale
		$HexShape/Icon.position = icon_offset
	if has_node("HexShape"):
		$HexShape.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

func _update_geometry() -> void:
	# Basic check to ensure children exist before manipulating them
	if not has_node("HexShape") or not has_node("HexCollision"): return
	
	var points := PackedVector2Array()
	for i in range(6):
		var angle_rad := deg_to_rad(60 * i + 30)
		points.append(Vector2(radius * cos(angle_rad), radius * sin(angle_rad)))
	
	$HexShape.polygon = points
	$HexCollision.polygon = points
	
	if has_node("HexBorder"):
		var b_points = points
		b_points.append(points[0]) # Properly close the loop
		$HexBorder.points = b_points

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ability_pressed.emit(ability_name)

# ## ⬢ ability_hex.gd ⬢
# ## Specialized Hex-Button for Guardian Abilities.
# @tool
# extends Area2D

# signal ability_pressed(p_name: String)


# @export_group("Ability Data")
# @export var ability_name: String = "Active"
# @export var ability_description: String = "Description"
# @export var icon_texture: Texture2D:
# 	set(val):
# 		icon_texture = val
# 		if is_node_ready(): $HexShape/Icon.texture = val

# @export_group("Fine Tuning")
# @export var radius: float = 40.0: # Kleinere Buttons fürs Menü
# 	set(val):
# 		radius = val
# 		if is_node_ready(): _update_geometry()

# @export var icon_scale := Vector2(0.15, 0.15):
# 	set(val):
# 		icon_scale = val
# 		if has_node("HexShape/Icon"): $HexShape/Icon.scale = val

# @export var icon_offset := Vector2.ZERO:
# 	set(val):
# 		icon_offset = val
# 		if has_node("HexShape/Icon"): $HexShape/Icon.position = val

# func _ready() -> void:
# 	_update_geometry()
# 	$HexShape/Icon.texture = icon_texture
# 	$HexShape/Icon.scale = icon_scale
# 	$HexShape/Icon.position = icon_offset
# 	# WICHTIG: Clipping aktivieren für die Hex-Form
# 	$HexShape.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

# func _update_geometry() -> void:
# 	var points := PackedVector2Array()
# 	for i in range(6):
# 		var angle_rad := deg_to_rad(60 * i + 30)
# 		points.append(Vector2(radius * cos(angle_rad), radius * sin(angle_rad)))
	
# 	$HexShape.polygon = points
# 	$HexCollision.polygon = points # FIX: Das löst den Convex Error!
	
# 	if has_node("HexBorder"):
# 		var b_points = points
# 		b_points.append(points[0])
# 		$HexBorder.points = b_points

# func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
# 	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
# 		ability_pressed.emit(ability_name)

# # --- SIGNALS ---

# func _on_mouse_entered() -> void:
# 	# Search for the central label in the GameWorld's UI layer
# 	var central_label = get_tree().current_scene.get_node_or_null("CanvasLayer/GuardianInfo/AbilityDescriptionLabel")
# 	if central_label:
# 		central_label.text = ability_name + ": " + ability_description

# func _on_mouse_exited() -> void:
# 	var central_label = get_tree().current_scene.get_node_or_null("CanvasLayer/GuardianInfo/AbilityDescriptionLabel")
# 	if central_label:
# 		central_label.text = ""
