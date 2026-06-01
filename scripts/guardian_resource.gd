## ⬢ guardian_resource.gd ⬢
## Universal data container for all Wächter configs, text, textures, and fine-tuning.
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
@export var passive_radius: float = 60.0
@export var passive_icon_scale := Vector2(0.25, 0.25)
@export var passive_icon_offset := Vector2.ZERO

@export_group("Active Ability ⚔️")
@export var active_name: String = ""
@export_multiline var active_description: String = ""
@export var active_icon: Texture2D
@export var active_cost: float = 15.0
@export var active_duration_pulses: int = 3
@export var active_max_uses_per_round: int = 3
@export var active_radius: float = 60.0
@export var active_icon_scale := Vector2(0.25, 0.25)
@export var active_icon_offset := Vector2.ZERO

@export_group("Ultimate Ability 🔥")
@export var ulti_name: String = ""
@export_multiline var ulti_description: String = ""
@export var ulti_icon: Texture2D
@export var ulti_cost: float = 50.0
@export var ulti_duration_pulses: int = 1
@export var ulti_max_uses_per_round: int = 1
@export var ulti_radius: float = 60.0
@export var ulti_icon_scale := Vector2(0.25, 0.25)
@export var ulti_icon_offset := Vector2.ZERO
