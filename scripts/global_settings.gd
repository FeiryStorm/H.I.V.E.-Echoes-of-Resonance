## ⬢ global_settings.gd ⬢
## Central authority for H.I.V.E. balancing coefficients and constants.
extends Node

# --- VISUAL MATRIX ---
const HEX_RADIUS: float = 64.0
const HEX_MARGIN: float = 1.075

# --- THE BESTAGON PALETTE ---
const COLORS: Dictionary = {
	"NEUTRAL": Color("00e5ff"), # Neon Blue ⬢
	"WOLF":    Color("2d5a27"), # Deep Forest Green 🐺🌿
	"SHARK":   Color("1a5fb4"), # Shark Deep Blue ⚡🦈💧
	"BEE":     Color("ffcc00"), # Bee Gold 🐝🍯
	"PHOENIX": Color("e63946"), # Phoenix Red 🐦🔥
	"EAGLE":   Color("a2d2ff"), # Sky Blue 🦅🌬️
	"SPIDER":  Color("7209b7")  # Spider Purple 🕷🕸️
}

# --- STATISTICAL BALANCE ---
const TRANSFER_RATE: float = 0.4    # Percentage of energy sent per pulse
const REGEN_AMOUNT: float  = 4.0    # Passive energy gain per pulse
const CAPTURE_BONUS: float = 6.0    # Initial energy boost for newly captured cells
const MAX_RESONANCE: float = 100.0  # Maximum cap per guardian resonance in a single cell

# --- MATCH STATE CORES ---
var selected_animal: int = 0
var selected_rivals: Array[int] = []

## Translates dynamic owner integers back into human-readable strings.
func get_owner_name(p_role: int) -> String:
	return HexData.Owner.keys()[p_role]