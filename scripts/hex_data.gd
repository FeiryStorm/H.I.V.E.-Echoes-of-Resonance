## ⬢ hex_data.gd ⬢ - Data container for a single hexagonal cell
extends Resource
class_name HexData

# --- ENUMS ---

enum Owner { NEUTRAL, WOLF, SHARK, BEE, PHOENIX, EAGLE, SPIDER }

# --- DATA ---

@export var cube_coords := Vector3i.ZERO
@export var current_owner: Owner = Owner.NEUTRAL
@export var energy: float = 0.0:
	set(value):
		energy = clamp(value, 0.0, 100.0)

# Performance & State tracking
@export var last_interaction_timestamp: float = 0.0
@export var status_effects: Array = []

func _init(p_coords := Vector3i.ZERO) -> void:
	cube_coords = p_coords
