## ⬢ guardian_logic.gd ⬢
## Base component for guardian-specific abilities.
extends Node
class_name GuardianLogic

var cell: Area2D
var res: GuardianResource

func _init(p_cell: Area2D, p_resource: GuardianResource) -> void:
	cell = p_cell
	res = p_resource


## To be overridden by specific guardians
func apply_passive() -> void:
	pass

func activate_ability() -> bool:
	return false

func activate_ultimate() -> bool:
	return false

