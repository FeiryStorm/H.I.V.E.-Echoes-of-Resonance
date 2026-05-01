## ⬢ hex_button.gd ⬢
## UI Component for Guardian Selection.
@tool
extends Area2D

## Signal emitted when the button is clicked.
signal hex_clicked(p_role: int)

enum SelectionMode { NONE, PLAYER, ENEMY }

# --- EXPORTS ---

@export_group("Guardian Settings")
## The guardian role assigned to this button.
@export var role: HexData.Owner = HexData.Owner.NEUTRAL:
	set(val): 
		role = val
		if is_node_ready():
			_apply_guardian_texture()
			_update_visuals(false)

## The radius of the hexagon.
@export var radius: float = 80.0:
	set(val):
		radius = val
		if is_node_ready(): _update_geometry()

@export_group("Visual Fine Tuning")
## Scale of the portrait inside the hex.
@export var portrait_scale := Vector2(0.25, 0.25):
	set(val):
		portrait_scale = val
		if is_node_ready(): _apply_guardian_texture()

## Offset of the portrait inside the hex.
@export var portrait_offset := Vector2.ZERO:
	set(val):
		portrait_offset = val
		if is_node_ready(): _apply_guardian_texture()

# --- INTERNAL STATE ---

var current_mode := SelectionMode.NONE

# --- ENGINE CORES ---

func _ready() -> void:
	_update_geometry()
	_apply_guardian_texture()
	
	if has_node("HexShape"):
		$HexShape.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	
	if not Engine.is_editor_hint():
		mouse_entered.connect(func(): _update_visuals(true))
		mouse_exited.connect(func(): _update_visuals(false))

# --- LOGIC ---

## Updates the geometry of the polygon and collision shape.
func _update_geometry() -> void:
	var points := PackedVector2Array()
	for i in range(6):
		var angle_rad := deg_to_rad(60 * i + 30)
		points.append(Vector2(radius * cos(angle_rad), radius * sin(angle_rad)))
	
	if has_node("HexShape"): $HexShape.polygon = points
	if has_node("HexCollision"): $HexCollision.polygon = points
	
	if has_node("HexBorder"):
		var b_points := points
		b_points.append(points[0]) # Perfect loop
		var border := $HexBorder
		border.points = b_points
		# FIX: Smooth corners and antialiasing
		border.joint_mode = Line2D.LINE_JOINT_ROUND
		border.begin_cap_mode = Line2D.LINE_CAP_ROUND
		border.end_cap_mode = Line2D.LINE_CAP_ROUND
		border.antialiased = true

## Sets the texture and region based on the role.
func _apply_guardian_texture() -> void:
	var sprite := get_node_or_null("HexShape/HexPortrait") as Sprite2D
	if not sprite: return
	
	sprite.centered = true
	sprite.position = portrait_offset
	sprite.scale = portrait_scale
	
	var portrait_path := "res://assets/ui/guardian_portraits.png"
	var logo_path := "res://assets/ui/hive_logo.png"
	
	if role == HexData.Owner.NEUTRAL:
		if FileAccess.file_exists(logo_path):
			sprite.texture = load(logo_path)
			sprite.region_enabled = false
		return

	if FileAccess.file_exists(portrait_path):
		sprite.texture = load(portrait_path)
		sprite.region_enabled = true
		match role:
			HexData.Owner.WOLF:    sprite.region_rect = Rect2(20, 11, 256, 308)
			HexData.Owner.SHARK:   sprite.region_rect = Rect2(543, 11, 256, 308)
			HexData.Owner.BEE:     sprite.region_rect = Rect2(15, 328, 270, 308)
			HexData.Owner.PHOENIX: sprite.region_rect = Rect2(362, 210, 256, 308)
			HexData.Owner.SPIDER:  sprite.region_rect = Rect2(690, 270, 258, 308)
			HexData.Owner.EAGLE:   sprite.region_rect = Rect2(362, 500, 256, 308)

## Refreshes the color and border width.
func _update_visuals(p_hovering: bool) -> void:
	if not has_node("HexShape") or not has_node("HexBorder"): return
	
	var role_name: String = HexData.Owner.keys()[role]
	var base_color: Color = GlobalSettings.COLORS.get(role_name, Color.WHITE)
	
	# Handle Border
	match current_mode:
		SelectionMode.PLAYER:
			$HexBorder.default_color = Color("ffcc00") # Gold
			$HexBorder.width = 4.0
			$HexBorder.modulate.a = 1.0
		SelectionMode.ENEMY:
			$HexBorder.default_color = Color("e63946") # Red
			$HexBorder.width = 4.0
			$HexBorder.modulate.a = 1.0
		_:
			$HexBorder.default_color = base_color
			$HexBorder.width = 2.0
			# Subtle border when not selected
			$HexBorder.modulate.a = 0.8 if p_hovering else 0.1

	# Handle Body
	$HexShape.color = base_color
	$HexShape.color.a = 0.5 if p_hovering else 0.2

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			hex_clicked.emit(int(role))
