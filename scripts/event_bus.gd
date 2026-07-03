## ⬢ event_bus.gd ⬢
## Centralized Event Broker for Team Bestagon.
## Decouples world interaction, rhythmic timing, and guardian components.
extends Node

# --- RHYTHM & PHASE EVENTS ---
@warning_ignore("unused_signal")
signal phase_changed(p_new_phase: int) # Uses BeatManager.GamePhase values
@warning_ignore("unused_signal")
signal pulse_impacted()

# --- GAMEPLAY & CELL EVENTS ---
@warning_ignore("unused_signal")
signal cell_captured(p_cell: Area2D, p_new_owner: int)
@warning_ignore("unused_signal")
signal resonance_changed(p_cell: Area2D, p_owner: int, p_new_value: float)

# --- GUARDIAN ACTION EVENTS ---
@warning_ignore("unused_signal")
signal ability_activated(p_owner: int, p_cell: Area2D)
@warning_ignore("unused_signal")
signal ultimate_unleashed(p_owner: int, p_cell: Area2D)