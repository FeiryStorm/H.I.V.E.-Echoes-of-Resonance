# ## ⬢ hex_cell.gd ⬢
## The physical representative of a grid coordinate.
extends Area2D

signal cell_clicked(p_coords: Vector3i)

@onready var shape: Polygon2D = $HexShape
@onready var portrait: Sprite2D = $HexShape/HexPortrait
@onready var border: Line2D = $HexBorder
@onready var collision: CollisionPolygon2D = $HexCollision

var hex_data: HexData
var is_hovered := false

# --- INITIALIZATION ---

## Connects the data resource and triggers initial draw.
func setup(p_data: HexData) -> void:
	hex_data = p_data
	_update_geometry()
	_update_visuals()

# --- DRAWING ---

## Calculates the points for the hexagon and collision.
func _update_geometry() -> void:
	var points := PackedVector2Array()
	for i in range(6):
		var angle_rad := deg_to_rad(60 * i + 30)
		points.append(Vector2(GlobalSettings.HEX_RADIUS * cos(angle_rad), GlobalSettings.HEX_RADIUS * sin(angle_rad)))
	
	shape.polygon = points
	collision.polygon = points
	
	# FIX: Explicitly append the FIRST point to the end to close the Line2D loop
	var b_points := points
	b_points.append(points[0]) # This adds the first Vector2 at the end
	
	border.points = b_points
	border.joint_mode = Line2D.LINE_JOINT_ROUND
	border.antialiased = true

## Refreshes colors and portraits based on HexData.
func _update_visuals() -> void:
	if not hex_data: return
	
	var owner_name: String = HexData.Owner.keys()[hex_data.current_owner]
	var base_color: Color = GlobalSettings.COLORS.get(owner_name, Color.WHITE)
	
	# Apply Colors
	shape.color = base_color
	shape.color.a = 0.5 if is_hovered else 0.2
	
	border.default_color = base_color
	border.width = 4.0 if is_hovered else 1.5
	border.modulate.a = 1.0 if is_hovered else 0.4
	
	_apply_portrait()

## Manages the portrait texture (similar to button logic).
func _apply_portrait() -> void:
	if hex_data.current_owner == HexData.Owner.NEUTRAL:
		portrait.visible = false
		return
		
	portrait.visible = true
	portrait.texture = load("res://assets/ui/guardian_portraits.png")
	portrait.region_enabled = true
	# Use standard scale for in-game cells
	portrait.scale = Vector2(0.2, 0.2) 
	
	match hex_data.current_owner:
		HexData.Owner.WOLF:    portrait.region_rect = Rect2(20, 11, 256, 308)
		HexData.Owner.SHARK:   portrait.region_rect = Rect2(543, 11, 256, 308)
		HexData.Owner.BEE:     portrait.region_rect = Rect2(20, 328, 256, 308)
		HexData.Owner.PHOENIX: portrait.region_rect = Rect2(362, 210, 256, 308)
		HexData.Owner.SPIDER:  portrait.region_rect = Rect2(690, 270, 258, 308)
		HexData.Owner.EAGLE:   portrait.region_rect = Rect2(362, 500, 256, 308)

# --- INPUT & SIGNALS ---

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_visuals()

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_visuals()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			cell_clicked.emit(hex_data.cube_coords)
