## ⬢ hex_data.gd ⬢
## Data container for spectral resonance and ownership.
extends Resource
class_name HexData

enum Owner { NEUTRAL, WOLF, SHARK, BEE, PHOENIX, EAGLE, SPIDER }

# --- DATA ---
@export var cube_coords := Vector3i.ZERO
@export var current_owner: Owner = Owner.NEUTRAL

## Stores resonance levels for each guardian: { Owner: float }
@export var resonance := {
	Owner.NEUTRAL: 0.0,
	Owner.WOLF:    0.0,
	Owner.SHARK:   0.0,
	Owner.BEE:     0.0,
	Owner.PHOENIX: 0.0,
	Owner.EAGLE:   0.0,
	Owner.SPIDER:  0.0
}

func _init(p_coords := Vector3i.ZERO) -> void:
	cube_coords = p_coords

## Adds resonance while respecting the global maximum cap.
func add_resonance(p_role: Owner, p_amount: float) -> void:
	resonance[p_role] = clamp(resonance[p_role] + p_amount, 0.0, GlobalSettings.MAX_RESONANCE)

## Calculates total energy combined from all spectrums.
func get_total_energy() -> float:
	var total := 0.0
	for amount in resonance.values():
		total += amount
	return total


