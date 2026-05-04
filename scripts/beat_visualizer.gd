## ⬢ beat_visualizer.gd ⬢
## UI representation of the BeatManager's state.
extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $PhaseLabel

func _process(_delta: float) -> void:
	if BeatManager.is_active:
		# Update progress bar
		var total_phase_time = BeatManager.pulse_duration * BeatManager.phase_distribution[BeatManager.current_phase]
		progress_bar.max_value = total_phase_time
		progress_bar.value = BeatManager.time_left
		
		# Update Label
		label.text = "PHASE: " + BeatManager.GamePhase.keys()[BeatManager.current_phase]
		
		# Visual Color Change based on phase
		match BeatManager.current_phase:
			BeatManager.GamePhase.LOADING: progress_bar.modulate = Color.WHITE
			BeatManager.GamePhase.PULSING: progress_bar.modulate = Color.GOLD
			BeatManager.GamePhase.ECHOING: progress_bar.modulate = Color.CYAN
