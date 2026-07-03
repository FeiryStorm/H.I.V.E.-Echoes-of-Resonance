## ⬢ beat_manager.gd ⬢
## Global rhythmic clock orchestrating gameplay phase rotations.
## Keeps tracking completely anonymous to bypass dependency conflicts.
extends Node

# --- LOGICAL CYCLES ---
enum GamePhase { LOADING, PULSING, ECHOING }

# --- SETTINGS ---
@export var pulse_duration: float = 10.0
@export var phase_distribution: Dictionary = {
	GamePhase.LOADING: 0.5, # 50% window of planning
	GamePhase.PULSING: 0.3, # 30% window of physical wave flow charging
	GamePhase.ECHOING: 0.2  # 20% window of calculation impact cascades
}

# --- STATE VARIABLES ---
var current_phase: GamePhase = GamePhase.LOADING
var time_left: float = 0.0
var is_active: bool = false

# --- GENERIC ANONYMOUS TRACKING MATRIX ---
var guardian_actions: Dictionary = {} # Key: HexData.Owner (int) -> Value: count (int)
var ultimates_used: Array[int] = []    # Array of HexData.Owner (int) indices

# --- ENGINE CORES ---

func _ready() -> void:
	# Automatically kickstart the heartbeat loop
	start_heartbeat()

func _process(p_delta: float) -> void:
	if not is_active: return
	
	time_left -= p_delta
	if time_left <= 0:
		_advance_phase()

# --- LOGICAL METHODS ---

## Activates the internal clock systems.
func start_heartbeat() -> void:
	is_active = true
	_set_phase(GamePhase.LOADING)
	print("⬢ H.I.V.E. | Heartbeat initialized.")

## Steps structural clock execution into the subsequent phase sector.
func _advance_phase() -> void:
	if current_phase == GamePhase.ECHOING:
		# Reset tracking tables at the birth of every round
		guardian_actions.clear()
		ultimates_used.clear()
		print("⬢ Beat | Global round actions reset.")

	match current_phase:
		GamePhase.LOADING: 
			_set_phase(GamePhase.PULSING)
		GamePhase.PULSING: 
			EventBus.pulse_impacted.emit()
			_set_phase(GamePhase.ECHOING)
		GamePhase.ECHOING: 
			_set_phase(GamePhase.LOADING)

## Updates states and broadcasts phase updates to the EventBus.
func _set_phase(p_phase: GamePhase) -> void:
	current_phase = p_phase
	time_left = pulse_duration * phase_distribution[p_phase]
	EventBus.phase_changed.emit(current_phase)
	print("⬢ Beat | Phase: ", GamePhase.keys()[p_phase], " (", snapped(time_left, 0.1), "s)")

# --- EXTERNAL API FOR GUARDIANS (SRP SANITY) ---

## Registers a dynamic action used by a specific owner.
func register_action(p_owner: int) -> void:
	if not guardian_actions.has(p_owner):
		guardian_actions[p_owner] = 0
	guardian_actions[p_owner] += 1

## Queries the exact action count for balanced evaluation.
func get_action_count(p_owner: int) -> int:
	return guardian_actions.get(p_owner, 0)

## Flags a specific owner's ultimate usage during this beat circle.
func register_ultimate(p_owner: int) -> void:
	if not p_owner in ultimates_used:
		ultimates_used.append(p_owner)

## Verifies ultimate availability.
func is_ultimate_used(p_owner: int) -> bool:
	return p_owner in ultimates_used
