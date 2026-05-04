## ⬢ hex_cell.gd ⬢
## Visual and interactive representation of a grid coordinate.
extends Area2D

signal cell_clicked(p_coords: Vector3i)

# --- NODES ---

@onready var shape: Polygon2D = $HexShape
@onready var portrait: Sprite2D = $HexShape/HexPortrait
@onready var border: Line2D = $HexBorder
@onready var collision: CollisionPolygon2D = $HexCollision
@onready var flow_line: Line2D = Line2D.new()

# --- UI NODES ---
@onready var energy_top: Label = $EnergyTop
@onready var energy_mid: Label = $EnergyMid
@onready var energy_bot: Label = $EnergyBot
@onready var x_icon: Label = Label.new() # Simple "X" placeholder

# --- STATE ---

var hex_data: HexData
var is_hovered := false
var target_cell: Area2D = null

# --- ENGINE CORES ---

func _ready() -> void:
	_setup_flow_line()
	_setup_feedback_ui()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			cell_clicked.emit(hex_data.cube_coords)

# --- INITIALIZATION ---

## Connects the data resource and triggers initial draw.
func setup(p_data: HexData) -> void:
	hex_data = p_data
	_update_geometry()
	_update_visuals()

# --- DRAWING ---

## Calculates the points for the hexagon, collision and closed border.
func _update_geometry() -> void:
	var points := PackedVector2Array()
	for i in range(6):
		var angle_rad := deg_to_rad(60 * i + 30)
		points.append(Vector2(GlobalSettings.HEX_RADIUS * cos(angle_rad), GlobalSettings.HEX_RADIUS * sin(angle_rad)))
	
	shape.polygon = points
	collision.polygon = points
	
	var b_points := points
	b_points.append(points[0]) # Close the loop
	
	border.points = b_points
	border.joint_mode = Line2D.LINE_JOINT_ROUND
	border.antialiased = true

## Synchronizes the cell visuals with the current spectral resonance.
func _update_visuals() -> void:
	if not hex_data: return
	
	# 1. Spectral Color Mixing
	var final_color := Color(0, 0, 0, 0)
	var total_energy = hex_data.get_total_energy()
	
	if total_energy > 0:
		for role in hex_data.resonance:
			var weight = hex_data.resonance[role] / total_energy
			var g_color = GlobalSettings.COLORS.get(HexData.Owner.keys()[role], Color.WHITE)
			final_color = final_color.lerp(g_color, weight)
	else:
		final_color = GlobalSettings.COLORS["NEUTRAL"]

	# --- Visual Application ---
	shape.color = final_color
	shape.color.a = 0.5 if is_hovered else 0.3
	
	# RE-INTEGRATED BORDER:
	if border:
		border.default_color = final_color
		border.width = 9.0 if is_hovered else 4.5
		border.modulate.a = 6.0 if is_hovered else 3.0
	
	# 2. Update Portraits and Labels
	_apply_portrait()
	_update_labels()
	queue_redraw()

# --- UI & EFFECTS ---

## Updates the three-tier energy display.
func _update_labels() -> void:
	var active_energies := []
	for role in hex_data.resonance:
		if role != HexData.Owner.NEUTRAL and hex_data.resonance[role] > 0.5:
			active_energies.append({"role": role, "val": hex_data.resonance[role]})
	
	var labels = [energy_top, energy_mid, energy_bot]
	for l in labels: l.text = "" # Reset
	
	active_energies.sort_custom(func(a, b): return a.val > b.val)
	
	for i in range(min(active_energies.size(), 3)):
		labels[i].text = str(int(active_energies[i].val))
		labels[i].modulate = GlobalSettings.COLORS[HexData.Owner.keys()[active_energies[i].role]]

## Sets the portrait of the dominant owner.
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

# --- TARGETING & FLOW ---

func _setup_flow_line() -> void:
	if not has_node("FlowLine"):
		flow_line.name = "FlowLine"
		add_child(flow_line)
	flow_line.width = 5.0
	flow_line.default_color = Color.WHITE
	flow_line.visible = false
	flow_line.z_index = 10
	flow_line.joint_mode = Line2D.LINE_JOINT_ROUND

func set_target(p_target: Area2D) -> void:
	target_cell = p_target
	if target_cell:
		flow_line.modulate.a = 1.0
		flow_line.points = PackedVector2Array([Vector2.ZERO, to_local(target_cell.global_position)])
		flow_line.visible = true
	else:
		flow_line.visible = false

func flash_transfer() -> void:
	if not flow_line.visible: return
	var tween = create_tween()
	tween.tween_property(flow_line, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func(): if target_cell == null: flow_line.visible = false)

# --- SIGNALS ---

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_visuals()

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_visuals()

func _setup_feedback_ui() -> void:
	add_child(x_icon)
	x_icon.text = "X"
	x_icon.visible = false
	x_icon.modulate = Color.WHITE

func set_feedback(p_valid: bool) -> void:
	if p_valid:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
		border.default_color = Color.WHITE
		x_icon.visible = false
	else:
		scale = Vector2.ONE
		x_icon.visible = true
		# Red dashed line and flickering logic would be handled in grid's drag_line