## ⬢ guardian_logic.gd ⬢
## Base component for guardian-specific behavioral rules.
## Inherits from RefCounted to guarantee seamless automated memory collection on ownership change.
extends RefCounted
class_name GuardianLogic

# --- STATE ---
var cell: Area2D
var res: GuardianResource

func _init(p_cell: Area2D, p_resource: GuardianResource) -> void:
	cell = p_cell
	res = p_resource

# --- CORE INTERACTION HOOKS (Virtual Methods) ---

## Triggers the standard primary tactical ability. Must return true if executed successfully.
func activate_ability() -> bool:
	return false

## Triggers the ultimate field ability. Must return true if executed successfully.
func activate_ultimate() -> bool:
	return false

# --- DECOUPLING FLOW HOOKS ---

## Intercepts and alters outbound energy vectors from this cell during pulse phases.
func modify_outgoing_flow(_p_target: Area2D, p_base_amount: float) -> float:
	return p_base_amount

## Intercepts and filters incoming energy/attacks targetting this cell during pulse phases.
func modify_incoming_flow(_p_attacker: Area2D, p_base_amount: float) -> float:
	return p_base_amount

## Processes customized turn-based resource amplification during the global regeneration step.
func process_regeneration() -> void:
	if cell and cell.hex_data and res:
		cell.hex_data.add_resonance(cell.hex_data.current_owner, res.base_regeneration)