## ⬢ radial_menu.gd ⬢
## Universal radial menu displaying, arranging, and dispatching guardian ability requests.
## Completely decoupled from physical cells, binding directly to raw GuardianResources.
extends Control
class_name RadialMenu

signal action_selected(p_action: String)

# --- CONFIGURATION ---
@export var button_radius: float = 120.0

# --- STATE ---
var current_active_name: String = ""
var current_ulti_name: String = ""

# --- PUBLIC INTERACTION API ---

## Triggers the entry bloom scale animation of the radial wheel.
func open() -> void:
	pivot_offset = size / 2.0
	scale = Vector2.ZERO
	show()
	
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.3)

## Closes the radial ring with a smooth collapse animation and frees resources.
func close() -> void:
	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "scale", Vector2.ZERO, 0.2)
	await tw.finished
	queue_free()

## Configures layout, labels, and icons dynamically from the passed configuration resource.
func setup_with_resource(p_resource: GuardianResource) -> void:
	if not p_resource:
		push_error("⬢ Menu | Failed to setup: Provided GuardianResource is null!")
		return
		
	print("⬢ Menu | Initializing tactical interfaces for: ", p_resource.guardian_name)
	
	current_active_name = p_resource.active_name
	current_ulti_name = p_resource.ulti_name
	
	var north: Area2D = get_node_or_null("Buttons/North") as Area2D
	var south: Area2D = get_node_or_null("Buttons/South") as Area2D
	var center: Area2D = get_node_or_null("Buttons/Center") as Area2D
	
	if north:
		north.set("ability_name", p_resource.active_name)
		# 🌀 DYNAMIC: Fetches the dynamically formatted description string
		north.set("ability_description", p_resource.get_formatted_active_description())
		north.set("icon_texture", p_resource.active_icon)
		north.set("radius", p_resource.active_icon_radius)
		north.set("icon_scale", p_resource.active_icon_scale)
		north.set("icon_offset", p_resource.active_icon_offset)
		
	if south:
		south.set("ability_name", p_resource.ulti_name)
		# 🌀 DYNAMIC: Fetches the dynamically formatted description string
		south.set("ability_description", p_resource.get_formatted_ulti_description())
		south.set("icon_texture", p_resource.ulti_icon)
		south.set("radius", p_resource.ulti_icon_radius)
		south.set("icon_scale", p_resource.ulti_icon_scale)
		south.set("icon_offset", p_resource.ulti_icon_offset)
		
	if center:
		center.set("ability_name", "Close")
		center.set("ability_description", "Cancel active interaction.")
		center.set("icon_texture", load("res://assets/ui/hive_logo.png") as Texture2D)
		center.set("radius", 60.0)
		center.set("icon_scale", Vector2(0.17, 0.17))
		center.set("icon_offset", Vector2(-0.5, 3.0))

	_wire_buttons_and_hover()
	_arrange_buttons()

# --- INTERNAL MATHEMATICAL LAYOUTS ---

## Arranges button child nodes geometrically in a circular layout.
func _arrange_buttons() -> void:
	var buttons_container: Node = get_node_or_null("Buttons")
	if not buttons_container: 
		push_error("⬢ Menu | Buttons container node not found in scene tree!")
		return
		
	var buttons: Array[Node] = buttons_container.get_children()
	
	for i in range(buttons.size()):
		var btn := buttons[i] as Area2D
		if not btn: continue
		
		if btn.name == "Center":
			btn.position = Vector2.ZERO
			continue
			
		# Step positions smoothly along 60-degree radial steps
		var angle: float = deg_to_rad((i - 1) * 60.0 - 60.0) 
		var target_pos := Vector2(cos(angle), sin(angle)) * button_radius
		
		btn.position = target_pos

## Connects button press and hover feedback listeners dynamically.
func _wire_buttons_and_hover() -> void:
	var buttons_container: Node = get_node_or_null("Buttons")
	if not buttons_container: return
	
	for child in buttons_container.get_children():
		var btn := child as Area2D
		if not btn: continue
		
		if btn.has_signal("ability_pressed"):
			# Safe click connection cleanup
			if btn.ability_pressed.is_connected(_on_ability_selected):
				btn.ability_pressed.disconnect(_on_ability_selected)
			btn.ability_pressed.connect(_on_ability_selected)
			
			# Hover feedback connection recovery
			if btn.mouse_entered.is_connected(_on_button_hover_start.bind(btn)):
				btn.mouse_entered.disconnect(_on_button_hover_start.bind(btn))
			btn.mouse_entered.connect(_on_button_hover_start.bind(btn))
			
			if btn.mouse_exited.is_connected(_on_button_hover_end):
				btn.mouse_exited.disconnect(_on_button_hover_end)
			btn.mouse_exited.connect(_on_button_hover_end)

# --- SIGNALS & HOVER CORES ---

func _on_button_hover_start(p_btn: Area2D) -> void:
	var central_label := get_tree().current_scene.get_node_or_null("CanvasLayer/GuardianInfo/AbilityDescriptionLabel") as Label
	if central_label and p_btn.get("ability_name") != null:
		central_label.text = str(p_btn.get("ability_name")) + "\n" + str(p_btn.get("ability_description"))

func _on_button_hover_end() -> void:
	var central_label := get_tree().current_scene.get_node_or_null("CanvasLayer/GuardianInfo/AbilityDescriptionLabel") as Label
	if central_label:
		central_label.text = ""

func _on_ability_selected(p_name: String) -> void:
	var internal_cmd: String = ""
	
	if p_name == current_active_name: 
		internal_cmd = "Active"
	elif p_name == current_ulti_name: 
		internal_cmd = "Ultimate"
	elif p_name == "Close": 
		internal_cmd = "Cancel"
		
	print("⬢ Menu | Sending Command: ", internal_cmd, " -> ", p_name)
	action_selected.emit(internal_cmd)
	close()