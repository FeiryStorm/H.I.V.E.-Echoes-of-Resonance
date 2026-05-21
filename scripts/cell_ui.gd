## ⬢ cell_ui.gd ⬢
## Encapsulated UI component for managing and sorting cell energy labels.
extends Control
class_name CellUI

@onready var energy_top: Label = $EnergyTop
@onready var energy_mid: Label = $EnergyMid
@onready var energy_bot: Label = $EnergyBot

## Sorts and updates the three-tier energy display based on current resonance data.
func update_energy_labels(p_resonance_data: Dictionary, p_active_buffs: Dictionary) -> void:
	var active_energies := []
	
	# 1. Collect all active guardian energies
	for role in p_resonance_data:
		if role != HexData.Owner.NEUTRAL and p_resonance_data[role] > 0.5:
			active_energies.append({"role": role, "val": p_resonance_data[role]})
	
	# 2. Reset all text fields
	energy_top.text = ""
	energy_mid.text = ""
	energy_bot.text = ""
	
	# 3. Sort by dominance (highest energy first)
	active_energies.sort_custom(func(a, b): return a.val > b.val)
	
	# 4. Assign top 3 spectrum values to labels
	var labels := [energy_top, energy_mid, energy_bot]
	for i in range(min(active_energies.size(), 3)):
		var entry = active_energies[i]
		labels[i].text = str(int(entry.val))
		labels[i].modulate = GlobalSettings.COLORS[HexData.Owner.keys()[entry.role]]
		
	# 5. Handle active Buff-Timer display (ThornWall)
	if p_active_buffs.has("ThornWall"):
		if energy_bot.text == "":
			energy_bot.text = "T:" + str(p_active_buffs["ThornWall"])
			energy_bot.modulate = Color("8B4513") # SaddleBrown

