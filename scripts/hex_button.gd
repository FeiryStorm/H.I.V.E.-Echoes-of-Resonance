## ⬢ hex_button.gd ⬢
## UI Component representing interactive hexagonal buttons used in character selection.
## Designed as an editor tool (@tool) for real-time visual alignment.
@tool
extends Area2D
class_name HexButton

## Signal emitted when the button is clicked, passing the selected guardian role.
signal hex_clicked(p_role: int)

enum SelectionMode { NONE, PLAYER, ENEMY }

# --- EXPORTS ---

@export_group("Guardian Settings")
## The guardian role assigned to this selection button.
@export var role: HexData.Owner = HexData.Owner.NEUTRAL:
	set(p_val): 
		role = p_val
		if is_node_ready():
			_apply_guardian_texture()
			_update_visuals(false)

## The radius of the hexagon shape.
@export var radius: float = 80.0:
	set(p_val):
		radius = p_val
		if is_node_ready(): 
			_update_geometry()

@export_group("Visual Fine Tuning")
## Scale of the portrait inside the hex vessel.
@export var portrait_scale: Vector2 = Vector2(0.25, 0.25):
	set(p_val):
		portrait_scale = p_val
		if is_node_ready(): 
			_apply_guardian_texture()

## Offset positioning of the portrait inside the hex vessel.
@export var portrait_offset: Vector2 = Vector2.ZERO:
	set(p_val):
		portrait_offset = p_val
		if is_node_ready(): 
			_apply_guardian_texture()

# --- INTERNAL STATE ---

var current_mode: SelectionMode = SelectionMode.NONE

# --- ENGINE CORES ---

func _ready() -> void:
	_update_geometry()
	_apply_guardian_texture()
	
	if has_node("HexShape"):
		var shape_node := $HexShape as Polygon2D
		if shape_node:
			shape_node.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	
	if not Engine.is_editor_hint():
		mouse_entered.connect(func() -> void: _update_visuals(true))
		mouse_exited.connect(func() -> void: _update_visuals(false))

# --- LOGICAL METHODS ---

## Recalculates and updates the procedural hexagon geometry and collision bounds.
func _update_geometry() -> void:
	var points := PackedVector2Array()
	for i in range(6):
		var angle_rad: float = deg_to_rad(60.0 * i + 30.0)
		points.append(Vector2(radius * cos(angle_rad), radius * sin(angle_rad)))
	
	if has_node("HexShape"): 
		var shape_node := $HexShape as Polygon2D
		if shape_node:
			shape_node.polygon = points
			
	if has_node("HexCollision"): 
		var coll_node := $HexCollision as CollisionPolygon2D
		if coll_node:
			coll_node.polygon = points
	
	if has_node("HexBorder"):
		var b_points: PackedVector2Array = points.duplicate()
		b_points.append(points[0]) # Properly close the Line2D loop
		
		var border := $HexBorder as Line2D
		if border:
			border.points = b_points
			border.joint_mode = Line2D.LINE_JOINT_ROUND
			border.begin_cap_mode = Line2D.LINE_CAP_ROUND
			border.end_cap_mode = Line2D.LINE_CAP_ROUND
			border.antialiased = true

## Assigns and slices the guardian portrait texture from atlas sheets safely.
func _apply_guardian_texture() -> void:
	var sprite := get_node_or_null("HexShape/HexPortrait") as Sprite2D
	if not sprite: return
	
	sprite.centered = true
	sprite.position = portrait_offset
	sprite.scale = portrait_scale
	
	var portrait_path: String = "res://assets/ui/guardian_portraits.png"
	var logo_path: String = "res://assets/ui/hive_logo.png"
	
	# Fallback to H.I.V.E. Logo if role is set to Neutral
	if role == HexData.Owner.NEUTRAL:
		if ResourceLoader.exists(logo_path):
			sprite.texture = load(logo_path) as Texture2D
			sprite.region_enabled = false
		return

	if ResourceLoader.exists(portrait_path):
		sprite.texture = load(portrait_path) as Texture2D
		sprite.region_enabled = true
		match role:
			HexData.Owner.WOLF:    sprite.region_rect = Rect2(20, 11, 256, 308)
			HexData.Owner.SHARK:   sprite.region_rect = Rect2(543, 11, 256, 308)
			HexData.Owner.BEE:     sprite.region_rect = Rect2(15, 328, 270, 308)
			HexData.Owner.PHOENIX: sprite.region_rect = Rect2(362, 210, 256, 308)
			HexData.Owner.SPIDER:  sprite.region_rect = Rect2(690, 270, 258, 308)
			HexData.Owner.EAGLE:   sprite.region_rect = Rect2(362, 500, 256, 308)

## Updates border highlight colors depending on selection states.
func _update_visuals(p_hovering: bool) -> void:
	if not has_node("HexShape") or not has_node("HexBorder"): return
	
	var shape_node := $HexShape as Polygon2D
	var border_node := $HexBorder as Line2D
	
	if not shape_node or not border_node: return
	
	var role_name: String = HexData.Owner.keys()[role]
	var base_color: Color = GlobalSettings.COLORS.get(role_name, Color.WHITE)
	
	# Adjust border highlights to show player choice feedback
	match current_mode:
		SelectionMode.PLAYER:
			border_node.default_color = Color("ffcc00") # Team Bestagon Gold
			border_node.width = 4.0
			border_node.modulate.a = 1.0
		SelectionMode.ENEMY:
			border_node.default_color = Color("e63946") # Rival Spectrum Red
			border_node.width = 4.0
			border_node.modulate.a = 1.0
		_:
			border_node.default_color = base_color
			border_node.width = 2.0
			border_node.modulate.a = 0.8 if p_hovering else 0.1

	shape_node.color = base_color
	shape_node.color.a = 0.5 if p_hovering else 0.2

# --- SIGNAL EMISSIONS ---

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			hex_clicked.emit(int(role))