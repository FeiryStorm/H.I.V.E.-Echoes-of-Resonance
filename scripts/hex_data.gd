## ⬢ hex_data.gd ⬢
## Static data container representing state, coordinates, and spectral signatures of a grid cell.
extends Resource
class_name HexData

# --- SCHEMA DEFINITION ---
enum Owner { NEUTRAL, WOLF, SHARK, BEE, PHOENIX, EAGLE, SPIDER }

# --- ATTRIBUTES ---
@export var cube_coords: Vector3i = Vector3i.ZERO
@export var current_owner: Owner = Owner.NEUTRAL

## Tracks current levels of spectral energy for all guardians simultaneously.
@export var resonance: Dictionary = {
	Owner.NEUTRAL: 0.0,
	Owner.WOLF:    0.0,
	Owner.SHARK:   0.0,
	Owner.BEE:     0.0,
	Owner.PHOENIX: 0.0,
	Owner.EAGLE:   0.0,
	Owner.SPIDER:  0.0
}

func _init(p_coords: Vector3i = Vector3i.ZERO) -> void:
	cube_coords = p_coords

## Adds energy value with strict clamping bounds according to global configurations.
func add_resonance(p_role: int, p_amount: float) -> void:
	if resonance.has(p_role):
		resonance[p_role] = clamp(resonance[p_role] + p_amount, 0.0, GlobalSettings.MAX_RESONANCE)

## Quantifies total combined energy of all spectrums inside the hex cell vessel.
func get_total_energy() -> float:
	var total: float = 0.0
	for amount in resonance.values():
		total += amount
	return total


