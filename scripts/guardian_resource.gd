## ⬢ guardian_resource.gd ⬢
## Universal data container upgraded with universal dynamic formatting hooks for Wolf and Shark ecosystems.
extends Resource
class_name GuardianResource

@export_group("Identity ⬢")
@export var guardian_name: String = "Unknown"
@export var theme_color: Color = Color.WHITE

@export_group("Basic Mechanics")
@export var base_regeneration: float = 3.0

@export_group("Passive Ability 🌀")
@export var passive_name: String = ""
@export_multiline var passive_description: String = ""
@export var passive_icon: Texture2D
@export var passive_icon_radius: float = 60.0
@export var passive_gameplay_range: float = 1.0
@export var passive_icon_scale: Vector2 = Vector2(0.25, 0.25)
@export var passive_icon_offset: Vector2 = Vector2.ZERO

@export_group("Active Ability ⚔️")
@export var active_name: String = ""
@export_multiline var active_description: String = ""
@export var active_icon: Texture2D
@export var active_cost: float = 15.0
@export var active_duration_pulses: int = 3
@export var active_max_uses_per_round: int = 3
@export var active_icon_radius: float = 60.0
@export var active_gameplay_range: float = 3.0
@export var active_icon_scale: Vector2 = Vector2(0.25, 0.25)
@export var active_icon_offset: Vector2 = Vector2.ZERO

@export_group("Ultimate Ability 🔥")
@export var ulti_name: String = ""
@export_multiline var ulti_description: String = ""
@export var ulti_icon: Texture2D
@export var ulti_cost: float = 50.0
@export var ulti_duration_pulses: int = 1
@export var ulti_max_uses_per_round: int = 1
@export var ulti_icon_radius: float = 60.0
@export var ulti_gameplay_range: float = 7.0
@export var ulti_icon_scale: Vector2 = Vector2(0.25, 0.25)
@export var ulti_icon_offset: Vector2 = Vector2.ZERO

@export_group("Ultimate Ability Balancing (Phase V) ⚖️")
@export var ulti_base_damage: float = 25.0
@export_custom(PROPERTY_HINT_NONE, "") var ulti_step_damage_scale: float = 7.0
@export var ulti_drain_efficiency: float = 0.5
@export var ulti_friendly_boost_scale: float = 0.25
@export var ulti_neutral_claim_efficiency: float = 0.5

# --- UNIVERSAL TACTICAL DICTIONARY FORMATTERS ---

func get_formatted_passive_description() -> String:
	return passive_description.format({
		"regen": base_regeneration,
		"range": passive_gameplay_range,
		"pack_bonus": 0.5, # Wolf specific ecosystem modifiers
		"cap": 9.0
	})

func get_formatted_active_description() -> String:
	return active_description.format({
		"cost": active_cost,
		"duration": active_duration_pulses,
		"range": active_gameplay_range,
		"uses": active_max_uses_per_round,
		"reduction": 50 # Wolf active mitigation reduction rate
	})

func get_formatted_ulti_description() -> String:
	return ulti_description.format({
		"cost": ulti_cost,
		"duration": ulti_duration_pulses,
		"range": ulti_gameplay_range,
		"uses": ulti_max_uses_per_round,
		"base_damage": ulti_base_damage,
		"step_damage": ulti_step_damage_scale,
		"drain": int(ulti_drain_efficiency * 100.0),
		"boost": int(ulti_friendly_boost_scale * 100.0),
		"claim": int(ulti_neutral_claim_efficiency * 100.0),
		"rings": 3, # Wolf shockwave rings depth
		"r1": 33,
		"r2": 22,
		"r3": 11
	})