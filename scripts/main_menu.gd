## ⬢ main_menu.gd ⬢
## Logic for guardian selection and match initialization.
extends Node2D

# --- ENGINE CORES ---

func _ready() -> void:
	print("⬢ H.I.V.E. | Initializing Dojo...")
	
	# Push background to the back
	if has_node("Background"):
		$Background.z_index = -10
	
	# Look into the "Buttons" container
	var button_container := get_node_or_null("Buttons")
	if button_container:
		for child in button_container.get_children():
			if child is Area2D and child.has_signal("hex_clicked"):
				# Connect signal safely
				if child.hex_clicked.is_connected(_on_hex_clicked):
					child.hex_clicked.disconnect(_on_hex_clicked)
				child.hex_clicked.connect(_on_hex_clicked)
				print("⬢ Connection established: ", child.name)
	else:
		print("⬢ ERROR: 'Buttons' node not found in MainMenu!")

	_refresh_ui()

# --- SIGNAL HANDLING ---

## Triggered when any HexButton is pressed.
func _on_hex_clicked(p_role_int: int) -> void:
	var p_role := p_role_int as HexData.Owner
	print("⬢ Resonance detected: ", GlobalSettings.get_owner_name(p_role))
	
	if p_role == HexData.Owner.NEUTRAL:
		_attempt_game_start()
	else:
		_process_selection(p_role)
		_refresh_ui()

# --- LOGIC ---

## Handles selection priority: Player -> Enemy 1 -> Enemy 2 -> Deselect.
func _process_selection(p_role: HexData.Owner) -> void:
	# 1. Player Choice
	if GlobalSettings.selected_animal == HexData.Owner.NEUTRAL:
		GlobalSettings.selected_animal = p_role
	elif GlobalSettings.selected_animal == p_role:
		GlobalSettings.selected_animal = HexData.Owner.NEUTRAL
	
	# 2. Rival Choice
	elif not GlobalSettings.selected_rivals.has(p_role):
		if GlobalSettings.selected_rivals.size() < 2:
			GlobalSettings.selected_rivals.append(p_role)
	else:
		GlobalSettings.selected_rivals.erase(p_role)

## Updates visual states for all buttons in the container.
func _refresh_ui() -> void:
	var button_container := get_node_or_null("Buttons")
	if not button_container: return
	
	for child in button_container.get_children():
		if child.has_method("_update_visuals"):
			# Determine current selection mode
			if child.role == GlobalSettings.selected_animal:
				child.current_mode = child.SelectionMode.PLAYER
			elif GlobalSettings.selected_rivals.has(child.role):
				child.current_mode = child.SelectionMode.ENEMY
			else:
				child.current_mode = child.SelectionMode.NONE
			
			# Trigger visual refresh
			child._update_visuals(false)

## Transitions to the game world if setup is complete.
func _attempt_game_start() -> void:
	if GlobalSettings.selected_animal != HexData.Owner.NEUTRAL and GlobalSettings.selected_rivals.size() == 2:
		print("⬢ H.I.V.E. | All systems green. Launching...")
		get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	else:
		print("⬢ H.I.V.E. | Setup incomplete. Need 1 Player and 2 Rivals.")
