## ⬢ global_settings.gd ⬢
## Central authority for H.I.V.E. balance and constants.
extends Node

# --- VISUALS ---
const HEX_RADIUS := 64.0
const HEX_MARGIN := 1.075

# --- COLORS (Team Bestagon Palette) ---
const COLORS := {
	"NEUTRAL": Color("00e5ff"), # Neon Blue ⬢
	"WOLF":    Color("2d5a27"), # Deep Forest Green 🐺🌿
	"SHARK":   Color("1a5fb4"), # Shark Deep Blue ⚡🦈💧
	"BEE":     Color("ffcc00"), # Bee Gold 🐝🍯
	"PHOENIX": Color("e63946"), # Phoenix Red 🐦🔥
	"EAGLE":   Color("a2d2ff"), # Sky Blue (Cloud-ish) 🦅🌬️
	"SPIDER":  Color("7209b7")  # Spider Purple 🕷🕸️
}

# --- BALANCE ---
const TRANSFER_RATE := 0.4    # Percentage of energy sent per pulse
const REGEN_AMOUNT  := 4.0    # Passive energy gain per pulse
const CAPTURE_BONUS := 6.0    # Initial energy boost for newly captured cells
const MAX_RESONANCE := 100.0  # Cap per guardian resonance in a single cell

# --- MATCH STATE ---
var selected_animal: int = 0
var selected_rivals: Array[int] = []

## Returns the string name of an owner enum.
func get_owner_name(p_role: int) -> String:
	return HexData.Owner.keys()[p_role]