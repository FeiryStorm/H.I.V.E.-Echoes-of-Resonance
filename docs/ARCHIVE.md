## ⬢ H.I.V.E. Archive Update: Phase I & II Completion ⬢
Match Setup & Logic:

* GlobalSettings: Centralized all guardian colors, radii, and match states (selected_animal, selected_rivals).
* SaveManager: Established persistence logic for player profiles.
* HexData: Created the "Soul" resource for every cell, tracking owner, energy, and coordinates.

UI & Main Menu:

* MainMenu Scene: Integrated the "Parchment" aesthetic with a functional guardian selection system.
* Selection Logic: Implemented a priority-based selection (1st click = Player/Gold, subsequent clicks = Enemies/Red).
* HexButton Component: A tool-scripted Area2D with dynamic clipping, non-uniform portrait scaling, and smooth Line2D borders.

The Battlefield:

* GameWorld Scene: Established the high-level scene tree with a dynamic WorldCamera that automatically centers on the battlefield.
* HexGrid Orchestrator: Implemented ring-based grid generation using Cube Coordinates (Vector3i).
* Guardian Deployment: Programmed the 120-degree triangle start positions (Player at SE, Rivals at N and SW) with correct color assignment.
* HexCell Component: Functional grid units with hover effects, click signals, and anti-aliased borders.

------------------------------

## ⬢ H.I.V.E. Development Archive | Phase III: Resonance & Rhythm ⬢## Core Architectural Milestone: Completed
This phase transitioned the project from static geometry into a dynamic, rhythmic strategy ecosystem. We successfully implemented the "Heartbeat" of the H.I.V.E. and established the "Spectral Philosophy" of energy.
## 1. The Rhythmic Engine (The Heartbeat)

* BeatManager (Singleton): Orchestrates the global game loop into three distinct phases:
* LOADING: Strategic planning and input window.
   * PULSING: Simultaneous execution of all resonance transfers.
   * ECHOING: Post-impact calculations, overflow cascades, and passive regeneration.
* Visualizer: Integrated a synchronized UI component to communicate phase-timing and tension to the player.

## 2. Spectral Resonance Philosophy (The Spectrum)

* Multi-Guardian Occupancy: Moved away from binary ownership. Cells now act as vessels for all six guardian energies simultaneously.
* Dominance Logic: Ownership is determined by the highest resonance level, while sub-dominant energies persist and influence the cell's "Spectral Signature."
* Dynamic Color Blending: Implemented a real-time Color.lerp system that mixes guardian colors based on their resonance weight in the spectrum.

## 3. Advanced Interaction & Game Feel (The Flow)

* Drag-to-Flow Control: Implemented a tactile energy-injection system. Players drag from a source to a neighbor to plan a transfer.
* Logarithmic Feedback: The connection line's thickness scales logarithmically with the amount of energy, providing a "heavy" and powerful visual feel.
* Haptic Snapping: Integrated camera leaning (15px offset) and vibration feedback (Input.vibrate_handheld) to enhance the physical connection between player and parchment.

## 4. Balancing & Scalability (The Symphony)

* Overflow Cascade System: Engineered a buffer-based overflow logic to prevent recursion crashes. Excess energy (>100) now ripples safely across the grid in a wave-like pattern.
* Rival AI (Strategic Equilibrium): Implemented a "Hand-Speed" limit (Action Points) for AI agents to ensure fair play against human reaction times.
* Triple-Tier UI: Each cell now displays the top 3 dominant resonance values in real-time, color-coded for immediate tactical assessment.

------------------------------
