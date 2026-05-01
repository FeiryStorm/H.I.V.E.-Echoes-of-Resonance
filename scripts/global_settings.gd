## ⬢ global_settings.gd ⬢
## Central singleton for game state and constants.
extends Node

const HEX_RADIUS := 64.0

const COLORS := {
	"NEUTRAL": Color("00e5ff"), # Neon Blue
	"WOLF":    Color("2d5a27"), # Deep Forest Green 🐺🌿
	"SHARK":   Color("1a5fb4"), # Shark Deep Blue ⚡🦈💧
	"BEE":     Color("ffcc00"), # Bee Gold 🐝🍯
	"PHOENIX": Color("e63946"), # Phoenix Red 🐦🔥
	"EAGLE":   Color("a2d2ff"), # Sky Blue (Cloud-ish) 🦅🌬️
	"SPIDER":  Color("7209b7")  # Spider Purple 🕷🕸️
}

## Match setup variables
var selected_animal: HexData.Owner = HexData.Owner.NEUTRAL
var selected_rivals: Array[HexData.Owner] = []

## Returns the string representation of an Owner enum
func get_owner_name(p_role: HexData.Owner) -> String:
	return HexData.Owner.keys()[p_role]
