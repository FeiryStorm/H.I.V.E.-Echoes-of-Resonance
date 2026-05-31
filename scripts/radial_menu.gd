## ⬢ radial_menu.gd ⬢
## Universal radial menu for guardian abilities.
extends Control

signal action_selected(p_action: String)

# --- CONFIGURATION ---
@export var button_radius: float = 120.0

# --- STATE ---
var current_active_name: String = ""
var current_ulti_name: String = ""

# --- ENGINE CORES ---

func _ready() -> void:
	pass

# --- LOGIC ---

func open() -> void:
	pivot_offset = size / 2
	scale = Vector2.ZERO
	show()
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.3)

## Arranges buttons in a hexagonal ring using your proven layout.
## Arranges buttons in a hexagonal ring using your proven layout.
func _arrange_buttons() -> void:
	var buttons_container := get_node_or_null("Buttons")
	if not buttons_container: 
		print("⬢ ERROR | Buttons container node not found!")
		return
	
	var buttons := buttons_container.get_children()
	print("⬢ Menu | Found ", buttons.size(), " buttons to arrange. Radius is: ", button_radius)
	
	for i in range(buttons.size()):
		var btn = buttons[i]
		
		if btn.name == "Center":
			btn.position = Vector2.ZERO
			print("⬢ Menu | Positioned Center at (0,0)")
			continue
		
		# Your proven 60 degree increments
		var angle := deg_to_rad((i-1) * 60 - 60) 
		var target_pos := Vector2(cos(angle), sin(angle)) * button_radius
		
		# FORCE assignment
		btn.position = target_pos
		
		# ABSOLUTE DEBUG PRINT: Tell us where it went
		print("⬢ Menu | Moving Node [", btn.name, "] to local position: ", target_pos)
		
		# Double check if textures are arriving
		if btn.get("icon_texture") == null:
			print("⬢ WARNING | Node [", btn.name, "] has NO icon_texture loaded!")


## Configures icons and names dynamically from the resource.
func setup_for_guardian_node(p_cell: Area2D) -> void:
	print("⬢⬢⬢ STEP 1: RadialMenu received the command! Checking cell validity...")
	
	if not is_instance_valid(p_cell):
		print("⬢⬢⬢ FAIL A: p_cell is NOT a valid instance!")
		return
		
	print("⬢⬢⬢ STEP 2: Cell is valid. Checking guardian_logic on cell...")
	if p_cell.guardian_logic == null:
		print("⬢⬢⬢ FAIL B: guardian_logic on this cell is NULL!")
		return
		
	print("⬢⬢⬢ STEP 3: guardian_logic exists. Checking resource (.tres)...")
	if p_cell.guardian_logic.res == null:
		print("⬢⬢⬢ FAIL C: GuardianResource (.tres) is MISSING inside the logic component!")
		return
		
	print("⬢⬢⬢ SUCCESS: All checks passed! Loading resource data for: ", p_cell.guardian_logic.res.guardian_name)
	
	# --- AB HIER LÄUFT DEIN BESTEHENDER CODE UNVERÄNDERT ---
	var r: GuardianResource = p_cell.guardian_logic.res
	current_active_name = r.active_name
	current_ulti_name = r.ulti_name
	
	# ... (der Rest der Zuweisungen für North, South, Center und am Ende _arrange_buttons())

	
	var north = get_node_or_null("Buttons/North")
	var south = get_node_or_null("Buttons/South")
	var center = get_node_or_null("Buttons/Center")
	
	if north:
		north.ability_name = r.active_name
		north.ability_description = r.active_description
		north.icon_texture = r.active_icon
		north.radius = r.active_radius
		north.icon_scale = r.active_icon_scale
		north.icon_offset = r.active_icon_offset
		
	if south:
		south.ability_name = r.ulti_name
		south.ability_description = r.ulti_description
		south.icon_texture = r.ulti_icon
		south.radius = r.ulti_radius
		south.icon_scale = r.ulti_icon_scale
		south.icon_offset = r.ulti_icon_offset
		
	if center:
		center.ability_name = "Close"
		center.ability_description = "Cancel selection."
		center.icon_texture = load("res://assets/ui/hive_logo.png")
		center.radius = 60.0
		center.icon_scale = Vector2(0.17, 0.17)
		center.icon_offset = Vector2(-0.5, 3.0)

	# Dynamically connect signals safely without duplicates
	var buttons_container = get_node_or_null("Buttons")
	if buttons_container:
		for child in buttons_container.get_children():
			if child.has_signal("ability_pressed"):
				if child.ability_pressed.is_connected(_on_ability_selected):
					child.ability_pressed.disconnect(_on_ability_selected)
				child.ability_pressed.connect(_on_ability_selected)
				
	# Now arrange everything onto their proper circles!
	## ⬢ radial_menu.gd ⬢ - Hover Signal Recovery

	# Connect all dynamic hex-buttons safely and inject Hover-Logic
	for child in $Buttons.get_children():
		if child.has_signal("ability_pressed"):
			# Click connection
			if not child.ability_pressed.is_connected(_on_ability_selected):
				child.ability_pressed.connect(_on_ability_selected)
			
			# HOVER RECOVERY: Bind mouse signals to the central UI label
			if not child.mouse_entered.is_connected(func(): _on_button_hover_start(child)):
				child.mouse_entered.connect(func(): _on_button_hover_start(child))
			if not child.mouse_exited.is_connected(_on_button_hover_end):
				child.mouse_exited.connect(_on_button_hover_end)
			
	_arrange_buttons()

## Pushes the description text directly to your central GameWorld canvas label
func _on_button_hover_start(p_btn: Area2D) -> void:
	var central_label = get_tree().current_scene.get_node_or_null("CanvasLayer/GuardianInfo/AbilityDescriptionLabel")
	if central_label and p_btn.get("ability_name") != null:
		central_label.text = p_btn.ability_name + "\n" + p_btn.ability_description

func _on_button_hover_end() -> void:
	var central_label = get_tree().current_scene.get_node_or_null("CanvasLayer/GuardianInfo/AbilityDescriptionLabel")
	if central_label:
		central_label.text = ""


func _on_ability_selected(p_name: String) -> void:
	var internal_cmd := ""
	
	# Universal dynamic command mapping
	if p_name == current_active_name: 
		internal_cmd = "Active"
	elif p_name == current_ulti_name: 
		internal_cmd = "Ultimate"
	elif p_name == "Close": 
		internal_cmd = "Cancel"
	
	print("⬢ Menu | Sending Command: ", internal_cmd, " : ", p_name)
	action_selected.emit(internal_cmd)
	close()

func close() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.2)
	await tw.finished
	queue_free()
