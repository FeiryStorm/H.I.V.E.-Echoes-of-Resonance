## ⬢ ability_hex.gd ⬢
## Specialized Hexagonal Button Component used inside the RadialMenu.
## Runs in-editor (@tool) for instant visual fine-tuning of bounds, shapes, and icons.
@tool
extends Area2D
class_name AbilityHex

signal ability_pressed(p_name: String)
signal ability_hovered(p_name: String, p_description: String)
signal ability_unhovered()

# --- CONFIGURATION & EXPORTS ---

@export_group("Ability Data")
@export var ability_name: String = "Active":
	set(p_val):
		ability_name = p_val

@export_multiline var ability_description: String = "Description":
	set(p_val):
		ability_description = p_val

@export var icon_texture: Texture2D:
	set(p_val):
		icon_texture = p_val
		if is_node_ready() and has_node("HexShape/Icon"):
			var icon_sprite := get_node("HexShape/Icon") as Sprite2D
			if icon_sprite:
				icon_sprite.texture = p_val

@export_group("Fine Tuning")
@export var radius: float = 40.0:
	set(p_val):
		radius = p_val
		_update_geometry()

@export var icon_scale: Vector2 = Vector2(0.15, 0.15):
	set(p_val):
		icon_scale = p_val
		if is_node_ready() and has_node("HexShape/Icon"):
			var icon_sprite := get_node("HexShape/Icon") as Sprite2D
			if icon_sprite:
				icon_sprite.scale = p_val

@export var icon_offset: Vector2 = Vector2.ZERO:
	set(p_val):
		icon_offset = p_val
		if is_node_ready() and has_node("HexShape/Icon"):
			var icon_sprite := get_node("HexShape/Icon") as Sprite2D
			if icon_sprite:
				icon_sprite.position = p_val

# --- ENGINE CORES ---

func _ready() -> void:
	# --- BESTAGON SECURE SHIELD ---
	input_pickable = true # Zwingt die Area2D, auf die Maus zu reagieren!
	
	# Signale mit uns selbst verbinden
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	_update_geometry()
	_apply_initial_node_states()

# --- INTERNAL METHODS ---

## Safeguards node states and textures upon initialization.
func _apply_initial_node_states() -> void:
	if has_node("HexShape/Icon"):
		var icon_sprite := get_node("HexShape/Icon") as Sprite2D
		if icon_sprite:
			icon_sprite.texture = icon_texture
			icon_sprite.scale = icon_scale
			icon_sprite.position = icon_offset
			
	if has_node("HexShape"):
		var shape_poly := get_node("HexShape") as Polygon2D
		if shape_poly:
			shape_poly.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

## Procedurally calculates and draws the hexagonal button collision boundaries.
func _update_geometry() -> void:
	if not has_node("HexShape") or not has_node("HexCollision"): 
		return
	
	var shape_poly := get_node("HexShape") as Polygon2D
	var coll_poly := get_node("HexCollision") as CollisionPolygon2D
	
	if not shape_poly or not coll_poly:
		return
		
	var points := PackedVector2Array()
	for i in range(6):
		var angle_rad: float = deg_to_rad(60.0 * i + 30.0)
		points.append(Vector2(radius * cos(angle_rad), radius * sin(angle_rad)))
	
	shape_poly.polygon = points
	coll_poly.polygon = points
	
	if has_node("HexBorder"):
		var border_line := get_node("HexBorder") as Line2D
		if border_line:
			var b_points: PackedVector2Array = points.duplicate()
			b_points.append(points[0]) # Properly close the Line2D loop
			border_line.points = b_points

# --- SIGNAL INTERACTIONS ---

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			ability_pressed.emit(ability_name)

func _on_mouse_entered() -> void:
	ability_hovered.emit(ability_name, ability_description)

func _on_mouse_exited() -> void:
	ability_unhovered.emit()
