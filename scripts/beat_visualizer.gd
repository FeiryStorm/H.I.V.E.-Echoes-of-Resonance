## ⬢ beat_visualizer.gd ⬢
## UI representation of the BeatManager's rhythmic states.
## Subscribes to the EventBus to prevent redundant frame-by-frame calculations.
extends Control
class_name BeatVisualizer

# --- NODES ---
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $PhaseLabel

# --- ENGINE CORES ---

func _ready() -> void:
	# Connect to the global EventBus to handle state changes efficiently
	EventBus.phase_changed.connect(_on_phase_changed)
	_initialize_visuals()

func _process(_delta: float) -> void:
	if BeatManager.is_active:
		# Update progress bar value every frame to ensure smooth visual countdown
		progress_bar.value = BeatManager.time_left

# --- INTERNAL METHODS ---

## Sets up initial visual states on game load.
func _initialize_visuals() -> void:
	if BeatManager.is_active:
		_on_phase_changed(BeatManager.current_phase)

## Dynamic listener reacting to phase changes. Calculates limits and sets colors only ONCE.
func _on_phase_changed(p_new_phase: int) -> void:
	# 1. Update maximum value threshold
	var active_distribution: float = BeatManager.phase_distribution.get(p_new_phase, 1.0)
	var total_phase_time: float = BeatManager.pulse_duration * active_distribution
	
	progress_bar.max_value = total_phase_time
	progress_bar.value = BeatManager.time_left
	
	# 2. Update Label Text using the String names of the enum
	label.text = "PHASE: " + BeatManager.GamePhase.keys()[p_new_phase]
	
	# 3. Apply color shifts based on the newly active pulse phase
	match p_new_phase:
		BeatManager.GamePhase.LOADING:
			progress_bar.modulate = Color.WHITE
		BeatManager.GamePhase.PULSING:
			progress_bar.modulate = Color.GOLD
		BeatManager.GamePhase.ECHOING:
			progress_bar.modulate = Color.CYAN