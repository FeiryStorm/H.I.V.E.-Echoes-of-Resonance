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

## ⬢ H.I.V.E. Development Archive | Phase IV: The Call of the Wolf ⬢

## Core Archetype & Component Milestone: Completed
This phase breathed life into the structural grid by implementing the first complete, asymmetric Guardian ecosystem. We established a reusable plug-and-play architecture for unique guardian logic and tactical radial command interfaces while optimizing system performance for multi-platform delivery.

## 1. Universal Interface & Interaction (The Radial Core)
* **Math-Driven Radial Menu:** Engineered a dynamic, hexagonal-symmetrical radial interface using 60-degree increments to display ability buttons seamlessly around a target cell.
* **Separation of Inputs:** Successfully uncoupled left-click targeting interactions (Drag-to-Flow) from right-click tactical micro-management (Radial Menu activation).
* **Centralized Description Hub:** Implemented a fixed UI description label at the bottom screen bounds, allowing real-time, wrap-smart ability descriptions to dynamically overlay on hover without battlefield obstruction.

## 2. Advanced Architectural Separation (The SRP Refactoring)
* **GuardianLogic Componentization:** Outsourced specific archetype behaviors from the physical `HexCell` into standalone modular scripts (`GuardianLogic`, `WolfLogic`), enabling quick plug-and-play script instantiation upon tile capture.
* **CellUI Encapsulation:** Isolated the cell's internal three-tier energy display logic and custom sorting routines into an independent sub-scene (`CellUI`), stripping down core cell script weight by nearly 50%.
* **Global Action Regulation:** Replaced traditional, restrictive localized cooldown loops with a centralized round-based action limiter (`wolf_actions_this_round`) inside the `BeatManager`.

## 3. High-Performance Optimization (The Dojo Formula)
* **O(1) Grid Math:** Eradicated linear iteration loops ($O(N)$) for hover tracking by engineering a static matrix conversion system (`HexMath.pixel_to_cube`), instantly resolving screen position vectors directly to dictionary coordinates.
* **Immediate Cascade Engine:** Restructured the delayed overflow system into an immediate recursive `while`-loop cascade within the same frame, fully armored with an automated emergency circuit brake to prevent execution freezes.

## 4. Emerald Resonance Balance (The Wolf Pack)
* **Root Network (Passive):** Implemented high-yield territorial scaling allowing a base generation spike (+6.0) combined with dynamic neighbor packaging (+0.5 per adjacent friendly node) capped tightly at +9.0 energy per beat.
* **Thorn Wall (Active):** Developed a fortification buff targeting the `LOADING` and `PULSING` phases, instantly slicing all incoming spectral resource damage by 50% for 3 subsequent pulses.
* **Call of the Pack (Ultimate):** Deployed a massive 3-ring cascading sonic shockwave utilizing asynchronous cube-distance timers. Spreads heavy emerald resonance layers (+33, +22, +11) outwards, followed by a distance-graded alpha glow decay to blend back into the spectrum.

------------------------------

⬢🌿🐺⚡🦈💧🍯🐝⬢🔥🐦‍🔥🕸️🕷️🌬️🦅🚀⬢