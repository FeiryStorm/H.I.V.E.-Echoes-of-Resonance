## ⬢ cell_ui.gd ⬢
## Encapsulated UI component for managing, sorting, and displaying 3-tier cell energy spectrums.
extends Control
class_name CellUI

# --- NODES ---
@onready var energy_top: Label = $EnergyTop
@onready var energy_mid: Label = $EnergyMid
@onready var energy_bot: Label = $EnergyBot

# --- UI LOGIC ---

## Sorts and updates the three-tier energy display based on current resonance data.
func update_energy_labels(p_resonance_data: Dictionary, p_active_buffs: Dictionary) -> void:
	var active_energies: Array[Dictionary] = []
	
	# 1. Collect all active guardian energies above a visible threshold
	for role: int in p_resonance_data:
		if role != int(HexData.Owner.NEUTRAL) and p_resonance_data[role] > 0.5:
			active_energies.append({"role": role, "val": p_resonance_data[role]})
	
	# 2. Reset all text fields before redrawing
	energy_top.text = ""
	energy_mid.text = ""
	energy_bot.text = ""
	
	# 3. Sort by dominance (highest energy first) with static type hints
	active_energies.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: 
		return a["val"] > b["val"]
	)
	
	# 4. Assign top 3 spectrum values to labels
	var labels: Array[Label] = [energy_top, energy_mid, energy_bot]
	var display_count: int = min(active_energies.size(), 3)
	
	for i in range(display_count):
		var entry: Dictionary = active_energies[i]
		labels[i].text = str(int(entry["val"]))
		
		# Resolve the color dynamically from the Bestagon Palette
		var role_name: String = HexData.Owner.keys()[entry["role"]]
		labels[i].modulate = GlobalSettings.COLORS.get(role_name, Color.WHITE)
		
	# 5. Handle active Buff-Timer display (E.g., ThornWall or other generic buffs)
	if not p_active_buffs.is_empty():
		# If we have a buff and the bottom slot is free, display the duration
		if energy_bot.text == "":
			# Find the first active buff and its remaining pulses
			var buff_name: String = p_active_buffs.keys()[0]
			var remaining_pulses: int = p_active_buffs[buff_name]
			
			energy_bot.text = "T:" + str(remaining_pulses)
			energy_bot.modulate = Color("8b4513") # SaddleBrown visual marker for fortification