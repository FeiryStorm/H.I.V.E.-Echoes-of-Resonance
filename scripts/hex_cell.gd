## ⬢ hex_cell.gd ⬢
## Visual and interactive representation of a single grid coordinate cell.
## Decoupled from specific guardian logic classes via dynamic injection.
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
@onready var x_icon: Label = Label.new()

# --- STATE ---
var hex_data: HexData
var is_hovered: bool = false
var guardian_logic: GuardianLogic = null # SRP: Injected from the outside (RefCounted)
var active_buffs: Dictionary = {}
var press_time: float = 0.0
var target_cell: Area2D = null

const TAP_THRESHOLD: float = 0.2

# --- UI CONFIG ---
var radial_menu_scene: PackedScene = preload("res://scenes/radial_menu.tscn")

# --- ENGINE CORES ---

func _ready() -> void:
	_setup_flow_line()
	_setup_feedback_ui()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		# LEFT CLICK: Drag-to-Flow input initialization
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				cell_clicked.emit(hex_data.cube_coords)
		
		# RIGHT CLICK: Toggle the tactical radial menu open
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if hex_data.current_owner == GlobalSettings.selected_animal:
				_show_radial_menu()

func _on_tap() -> void:
	if hex_data.current_owner == GlobalSettings.selected_animal:
		_show_radial_menu()

# --- RADIAL UI SYSTEMS ---

## Cleans duplicate menus and opens the action ring centered on this cell position.
func _show_radial_menu() -> void:
	if hex_data.current_owner != GlobalSettings.selected_animal:
		return
		
	var existing_menu: Node = get_tree().current_scene.get_node_or_null("RadialMenu")
	if existing_menu: 
		existing_menu.queue_free()
		
	var menu: Control = radial_menu_scene.instantiate() as Control
	menu.name = "RadialMenu"
	
	get_tree().current_scene.add_child(menu)
	menu.global_position = global_position
	
	if not menu.action_selected.is_connected(_on_radial_menu_action):
		menu.action_selected.connect(_on_radial_menu_action)
	
	# Pass the dynamic resource to keep the menu completely decoupled from cell structure
	if guardian_logic and guardian_logic.res:
		menu.setup_with_resource(guardian_logic.res)
		
	menu.open()

## Interprets selected radial actions and delegates execution to the logic component.
func _on_radial_menu_action(p_action: String) -> void:
	if not guardian_logic:
		push_warning("⬢ Cell | No logic component bound to process action: " + p_action)
		return
	
	match p_action:
		"Active":
			var success: bool = guardian_logic.activate_ability()
			print("⬢ Cell | Active ability triggered. Success: ", success)
		"Ultimate":
			var success: bool = guardian_logic.activate_ultimate()
			print("⬢ Cell | Ultimate ability triggered. Success: ", success)
		"Cancel":
			pass
			
	_update_visuals()

# --- INITIALIZATION & DRAWING ---

## Binds the HexData resource and calculates initial visual layouts.
func setup(p_data: HexData) -> void:
	hex_data = p_data
	_update_geometry()
	_update_visuals()

## Procedurally draws the hexagonal boundaries and aligns the collision polygon shape.
func _update_geometry() -> void:
	var points := PackedVector2Array()
	for i in range(6):
		var angle_rad: float = deg_to_rad(60.0 * i + 30.0)
		points.append(Vector2(GlobalSettings.HEX_RADIUS * cos(angle_rad), GlobalSettings.HEX_RADIUS * sin(angle_rad)))
	
	shape.polygon = points
	collision.polygon = points
	
	var b_points := points
	b_points.append(points[0]) # Close the Line2D border loop
	
	border.points = b_points
	border.joint_mode = Line2D.LINE_JOINT_ROUND
	border.antialiased = true

## Re-evaluates spectral colors and updates border indicators.
func _update_visuals() -> void:
	if not hex_data: return
	
	# 1. Calculate color blending based on spectral resonance weights
	var mixed_color := Color(0, 0, 0, 0)
	var total_energy: float = hex_data.get_total_energy()
	
	if total_energy > 0.0:
		for role: int in hex_data.resonance:
			var weight: float = hex_data.resonance[role] / total_energy
			var role_name: String = HexData.Owner.keys()[role]
			var g_color: Color = GlobalSettings.COLORS.get(role_name, Color.WHITE)
			mixed_color = mixed_color.lerp(g_color, weight)
	else:
		mixed_color = GlobalSettings.COLORS["NEUTRAL"]

	# 2. Render primary cell visuals
	shape.color = mixed_color
	shape.color.a = 0.9 if is_hovered else 0.7
	
	# Apply active tactical modifiers (e.g. Wolf's ThornWall)
	if active_buffs.has("ThornWall"):
		border.default_color = Color("8B4513") # Hardened wooden barrier boundary look
		border.width = 7.0
		border.modulate.a = 1.0
		shape.modulate = Color(0.7, 0.7, 0.7) 
	else:
		border.default_color = mixed_color 
		border.width = 4.0 if is_hovered else 1.5
		border.modulate.a = 0.8 if is_hovered else 0.4
		shape.modulate = Color.WHITE
	
	_apply_portrait()
	_update_ui()
	queue_redraw()

func _update_ui() -> void:
	if cell_ui:
		cell_ui.update_energy_labels(hex_data.resonance, active_buffs)

## Cuts out the corresponding atlas sub-rectangle for the active guardian portrait.
func _apply_portrait() -> void:
	if hex_data.current_owner == HexData.Owner.NEUTRAL:
		portrait.visible = false
		return
		
	portrait.visible = true
	portrait.texture = load("res://assets/ui/guardian_portraits.png") as Texture2D
	portrait.region_enabled = true
	portrait.scale = Vector2(0.2, 0.2) 
	
	match hex_data.current_owner:
		HexData.Owner.WOLF:    portrait.region_rect = Rect2(20, 11, 256, 308)
		HexData.Owner.SHARK:   portrait.region_rect = Rect2(543, 11, 256, 308)
		HexData.Owner.BEE:     portrait.region_rect = Rect2(20, 328, 256, 308)
		HexData.Owner.PHOENIX: portrait.region_rect = Rect2(362, 210, 256, 308)
		HexData.Owner.SPIDER:  portrait.region_rect = Rect2(690, 270, 258, 308)
		HexData.Owner.EAGLE:   portrait.region_rect = Rect2(362, 500, 256, 308)

# --- SPECTRAL ENERGY FLOWS ---

func _setup_flow_line() -> void:
	if not has_node("FlowLine"):
		flow_line.name = "FlowLine"
		add_child(flow_line)
	flow_line.width = 5.0
	flow_line.default_color = Color.WHITE
	flow_line.visible = false
	flow_line.z_index = 10
	flow_line.joint_mode = Line2D.LINE_JOINT_ROUND

## Focuses connection lines targeting adjacent nodes.
func set_target(p_target: Area2D) -> void:
	target_cell = p_target
	if target_cell:
		flow_line.modulate.a = 1.0
		var owner_name: String = HexData.Owner.keys()[hex_data.current_owner]
		flow_line.default_color = GlobalSettings.COLORS.get(owner_name, Color.WHITE)
		flow_line.points = PackedVector2Array([Vector2.ZERO, to_local(target_cell.global_position)])
		flow_line.visible = true
	else:
		flow_line.visible = false

## Triggers an immediate fading flash feedback upon transfer calculations.
func flash_transfer() -> void:
	if not flow_line.visible: return
	var owner_name: String = HexData.Owner.keys()[hex_data.current_owner]
	flow_line.default_color = GlobalSettings.COLORS.get(owner_name, Color.WHITE)
	
	var tween: Tween = create_tween()
	tween.tween_property(flow_line, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func() -> void: 
		if target_cell == null: 
			flow_line.visible = false
	)

## Activates the dynamic pulse breathing effect hooked safely to EventBus cycles.
func start_pulsing_transfer() -> void:
	if not target_cell or not flow_line.visible: return
	
	var owner_name: String = HexData.Owner.keys()[hex_data.current_owner]
	var pulse_color: Color = GlobalSettings.COLORS.get(owner_name, Color.WHITE)
	flow_line.default_color = pulse_color
	flow_line.modulate.a = 1.0
	
	var original_width: float = 8.0 
	flow_line.width = original_width
	
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(flow_line, "width", original_width * 1.3, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flow_line, "width", original_width, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Connect to the decoupled EventBus signal
	EventBus.phase_changed.connect(func(p_phase: int) -> void:
		if p_phase == BeatManager.GamePhase.ECHOING:
			if tween.is_valid():
				tween.kill()
			flow_line.width = original_width
	, CONNECT_ONE_SHOT)

# --- HOVER & SIGNALS ---

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
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
		border.default_color = Color.WHITE
		x_icon.visible = false
	else:
		scale = Vector2.ONE
		x_icon.visible = true