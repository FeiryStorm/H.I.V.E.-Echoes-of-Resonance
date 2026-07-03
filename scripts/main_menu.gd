## ⬢ main_menu.gd ⬢
## Controller managing matchmaking setup, character selection priority, and arena transitions.
extends Node2D
class_name MainMenu

# --- ENGINE CORES ---

func _ready() -> void:
	print("⬢ H.I.V.E. | Initializing selection matrix...")
	
	# Keep background rendering safely behind UI elements
	if has_node("Background"):
		var bg := $Background as CanvasItem
		if bg:
			bg.z_index = -10
	
	_wire_selection_buttons()
	_refresh_ui()

# --- INTERNAL METHODS ---

## Iterates through the Buttons container and binds clicked signals.
func _wire_selection_buttons() -> void:
	var button_container := get_node_or_null("Buttons") as Node
	if button_container:
		for child in button_container.get_children():
			var btn := child as HexButton
			if btn and btn.has_signal("hex_clicked"):
				# Safely reconnect to prevent duplicate signal routing
				if btn.hex_clicked.is_connected(_on_hex_clicked):
					btn.hex_clicked.disconnect(_on_hex_clicked)
				btn.hex_clicked.connect(_on_hex_clicked)
				print("⬢ Menu | Connected selection button: ", btn.name)
	else:
		push_error("⬢ Menu | Setup failed: 'Buttons' container node not found!")

# --- SIGNAL HANDLING ---

## Triggered when any selection hex is activated. Neutral acts as the start button.
func _on_hex_clicked(p_role_int: int) -> void:
	var selected_role: HexData.Owner = p_role_int as HexData.Owner
	print("⬢ Menu | Clicked role: ", GlobalSettings.get_owner_name(selected_role))
	
	if selected_role == HexData.Owner.NEUTRAL:
		_attempt_game_start()
	else:
		_process_selection(selected_role)
		_refresh_ui()

# --- SELECTION & TRANSITION LOGIC ---

## Handles selection cascade: Player -> Rival 1 -> Rival 2 -> Deselect.
func _process_selection(p_role: HexData.Owner) -> void:
	# 1. Player Choice (First click sets player, second click deselects)
	if GlobalSettings.selected_animal == int(HexData.Owner.NEUTRAL):
		GlobalSettings.selected_animal = int(p_role)
	elif GlobalSettings.selected_animal == int(p_role):
		GlobalSettings.selected_animal = int(HexData.Owner.NEUTRAL)
	
	# 2. Rival Choice (Subsequent clicks fill or empty the 2-rival queue)
	elif not p_role in GlobalSettings.selected_rivals:
		if GlobalSettings.selected_rivals.size() < 2:
			GlobalSettings.selected_rivals.append(int(p_role))
	else:
		GlobalSettings.selected_rivals.erase(int(p_role))

## Synchronizes visual states and selection frames for all buttons.
func _refresh_ui() -> void:
	var button_container := get_node_or_null("Buttons") as Node
	if not button_container: return
	
	for child in button_container.get_children():
		var btn := child as HexButton
		if btn:
			# Assign selection frames dynamically
			if btn.role == GlobalSettings.selected_animal:
				btn.current_mode = btn.SelectionMode.PLAYER
			elif btn.role in GlobalSettings.selected_rivals:
				btn.current_mode = btn.SelectionMode.ENEMY
			else:
				btn.current_mode = btn.SelectionMode.NONE
			
			# Trigger redraw
			if btn.has_method("_update_visuals"):
				btn._update_visuals(false)

## Verifies setup requirements and transitions to the GameWorld scene.
func _attempt_game_start() -> void:
	if GlobalSettings.selected_animal != int(HexData.Owner.NEUTRAL) and GlobalSettings.selected_rivals.size() == 2:
		print("⬢ Menu | Setup complete. Launching game arena...")
		get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	else:
		print("⬢ Menu | Setup incomplete. Requires 1 Player and exactly 2 Rivals to ignite resonance!")