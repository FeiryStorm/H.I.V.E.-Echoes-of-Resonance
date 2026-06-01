## ⬢ beat_manager.gd ⬢
## Global rhythmic clock for H.I.V.E. orchestrating game phases.
extends Node

# --- SIGNALS ---
signal phase_changed(p_new_phase: GamePhase)
signal pulse_impact()

# --- ENUMS ---
enum GamePhase { LOADING, PULSING, ECHOING }

# --- SETTINGS ---
@export var pulse_duration: float = 10.0
@export var phase_distribution := {
	GamePhase.LOADING: 0.5,  # 50% of time for planning
	GamePhase.PULSING: 0.3,  # 30% for the energy wave
	GamePhase.ECHOING: 0.2   # 20% for chain reactions
}

# --- STATE ---
var current_phase: GamePhase = GamePhase.LOADING
var time_left: float = 0.0
var is_active: bool = false
var wolf_actions_this_round := 0
var wolf_ultimate_used_this_round := false

# --- ENGINE CORES ---

func _ready() -> void:
	# For testing, we start automatically. 
	# Later, GameWorld will trigger this.
	start_heartbeat()

func _process(p_delta: float) -> void:
	if not is_active: return
	
	time_left -= p_delta
	if time_left <= 0:
		_advance_phase()

# --- LOGIC ---

## Starts the rhythmic cycle of the H.I.V.E.
func start_heartbeat() -> void:
	is_active = true
	_set_phase(GamePhase.LOADING)
	print("⬢ H.I.V.E. | Heartbeat initialized.")

## Switches to the next logical phase in the cycle
func _advance_phase() -> void:
	if current_phase == GamePhase.ECHOING:
		wolf_actions_this_round = 0 # RESET at start of new round
		wolf_ultimate_used_this_round = false # RESET ULTIMATE at start of new round
	match current_phase:
		GamePhase.LOADING: _set_phase(GamePhase.PULSING)
		GamePhase.PULSING: 
			pulse_impact.emit()
			_set_phase(GamePhase.ECHOING)
		GamePhase.ECHOING: _set_phase(GamePhase.LOADING)

## Sets a phase and resets the internal timer
func _set_phase(p_phase: GamePhase) -> void:
	current_phase = p_phase
	time_left = pulse_duration * phase_distribution[p_phase]
	phase_changed.emit(current_phase)
	print("⬢ Beat | Phase: ", GamePhase.keys()[p_phase], " (", snapped(time_left, 0.1), "s)")

