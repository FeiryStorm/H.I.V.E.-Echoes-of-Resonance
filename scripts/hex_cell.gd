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
@onready var cell_ui: CellUI = $CellUI
@onready var x_icon: Label = Label.new() # Simple "X" placeholder
@onready var press_start_time := 0.0

# --- STATE ---

var hex_data: HexData
var is_hovered := false
var guardian_logic: GuardianLogic = null # SRP: Logic is outsourced
var active_buffs := {}
var press_time := 0.0
const TAP_THRESHOLD := 0.2
var target_cell: Area2D = null

# --- UI ---
var radial_menu_scene := preload("res://scenes/radial_menu.tscn")

# --- ENGINE CORES ---

func _ready() -> void:
	_setup_flow_line()
	_setup_feedback_ui()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		# LEFT CLICK: Keep for Drag/Flow (Grid-Signals)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				cell_clicked.emit(hex_data.cube_coords)
		
		# RIGHT CLICK: Open Radial Menu
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if hex_data.current_owner == GlobalSettings.selected_animal:
				_show_radial_menu()

func _on_tap() -> void:
	if hex_data.current_owner == GlobalSettings.selected_animal:
		_show_radial_menu()

func _show_radial_menu() -> void:
	if hex_data.current_owner != GlobalSettings.selected_animal:
		return
		
	# Check if a menu is already open to avoid duplicates
	var existing_menu = get_tree().current_scene.get_node_or_null("RadialMenu")
	if existing_menu: existing_menu.queue_free()
		
	var menu_scene = preload("res://scenes/radial_menu.tscn")
	var menu = menu_scene.instantiate()
	menu.name = "RadialMenu"
	
	# Add to GameWorld (current_scene) instead of the cell
	get_tree().current_scene.add_child(menu)
	
	# Align to the cell's screen position
	menu.global_position = global_position
	
	# WICHTIG: Die Verbindung muss VOR dem open() passieren
	if not menu.action_selected.is_connected(_on_radial_menu_action):
		menu.action_selected.connect(_on_radial_menu_action)
		print("⬢ Cell | Signal connected to Menu.") # DEBUG PRINT
	
	menu.setup_for_guardian(hex_data.current_owner)
	menu.open()

func _on_radial_menu_action(p_action: String) -> void:
	print("⬢ Cell | Processing: ", p_action)
	
	# CHECK: Is the brain of the cell initialized?
	# SAFETY: Check if logic exists before calling it
	if not guardian_logic:
		print("⬢ Cell | No logic found. Re-initializing...")
		_ensure_logic_exists()
		if not guardian_logic: return # Still nothing? Abort.
	
	match p_action:
		"Active":
			var success = guardian_logic.activate_ability()
			print("⬢ Cell | Ability Triggered. Success: ", success)
		"Ultimate":
			if guardian_logic.has_method("activate_ultimate"):
				guardian_logic.activate_ultimate()
				print("⬢ H.I.V.E. | Ultimate resonance requested.")
		"Cancel":
			print("⬢ Cell | Action cancelled.")
	
	# Force visual update to show the brown border
	_update_visuals()

## Helper to ensure logic component exists
func _ensure_logic_exists() -> void:
	var role = hex_data.current_owner
	if role == HexData.Owner.NEUTRAL:
		guardian_logic = null
		return
		
	# SRP: Re-assign logic if it's missing but we have an owner
	match role:
		HexData.Owner.WOLF:
			guardian_logic = WolfLogic.new(self)
		# Future-Proof: SHARK, BEE etc. will go here
		_:
			guardian_logic = null


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

func _update_visuals() -> void:
	if not hex_data: return
	
	# --- 1. Spectral Mixing (THE RETURN) ---
	var mixed_color := Color(0, 0, 0, 0)
	var total_energy = hex_data.get_total_energy()
	
	if total_energy > 0:
		for role in hex_data.resonance:
			var weight = hex_data.resonance[role] / total_energy
			var g_color = GlobalSettings.COLORS.get(HexData.Owner.keys()[role], Color.WHITE)
			mixed_color = mixed_color.lerp(g_color, weight)
	else:
		mixed_color = GlobalSettings.COLORS["NEUTRAL"]

	# --- 2. Apply Visuals ---
	shape.color = mixed_color
	shape.color.a = 0.9 if is_hovered else 0.7
	
	if active_buffs.has("ThornWall"):
		border.default_color = Color("8B4513") # SaddleBrown
		border.width = 7.0
		border.modulate.a = 1.0
		shape.modulate = Color(0.7, 0.7, 0.7) # Hardened Look
	else:
		border.default_color = mixed_color # Border also matches spectrum!
		border.width = 4.0 if is_hovered else 1.5
		border.modulate.a = 0.8 if is_hovered else 0.4
		shape.modulate = Color.WHITE
	
	_apply_portrait()
	_update_ui()
	queue_redraw()

# --- UI & EFFECTS ---

## Updates the three-tier energy display.
func _update_ui() -> void:
	if has_node("CellUI"):
		$CellUI.update_energy_labels(hex_data.resonance, active_buffs)

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
		
		# FIX: Ensure the line ALWAYS gets the current guardian color the millisecond it is set
		var owner_name: String = HexData.Owner.keys()[hex_data.current_owner]
		flow_line.default_color = GlobalSettings.COLORS.get(owner_name, Color.WHITE)
		
		flow_line.points = PackedVector2Array([Vector2.ZERO, to_local(target_cell.global_position)])
		flow_line.visible = true
	else:
		flow_line.visible = false

func flash_transfer() -> void:
	if not flow_line.visible: return
	
	# FIX 1: Ensure color matches the guardian during the flash
	var owner_name: String = HexData.Owner.keys()[hex_data.current_owner]
	flow_line.default_color = GlobalSettings.COLORS.get(owner_name, Color.WHITE)
	
	var tween = create_tween()
	tween.tween_property(flow_line, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func(): if target_cell == null: flow_line.visible = false)

# --- TARGETING & FLOW ---

## Animates the flow line to indicate an impending resonance transfer
func start_pulsing_transfer() -> void:
	if not target_cell or not flow_line.visible: return
	
	# 1. Synchronize color with the current dominant guardian
	var owner_name: String = HexData.Owner.keys()[hex_data.current_owner]
	var pulse_color: Color = GlobalSettings.COLORS.get(owner_name, Color.WHITE)
	flow_line.default_color = pulse_color
	flow_line.modulate.a = 1.0
	
	# 2. Setup safe bounding for widths
	var original_width: float = 8.0 # Solid base width
	flow_line.width = original_width
	
	# 3. Create a smooth, subtle breathing pulse (High-Tech-Glow)
	var tween := create_tween().set_loops()
	tween.tween_property(flow_line, "width", original_width * 1.3, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flow_line, "width", original_width, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 4. Clean disconnect upon entering the ECHOING impact phase
	BeatManager.phase_changed.connect(func(p):
		if p == BeatManager.GamePhase.ECHOING:
			if tween.is_valid():
				tween.kill()
			flow_line.width = original_width
	, CONNECT_ONE_SHOT)

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