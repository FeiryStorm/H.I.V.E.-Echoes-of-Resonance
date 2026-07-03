⬢ H.I.V.E. Development Archive ⬢

"The geometry of the dojo is incorruptible. Every spectrum finds its place, every rhythm beats to the pace of the EventBus." — Kiroku-Nexus

⬢ Phase I & II: Foundations & Match Initialization

Status: Complete (The Seed is Sown)

In this initial epoch, we carved the physical hex grid of H.I.V.E. out of the digital void, anchoring the Team Bestagon "Parchment" aesthetic and establishing robust structural persistence.

1. Match Setup & Logic

GlobalSettings: Centralization of all guardian colors, radii, and global match states (selected_animal, selected_rivals) acting as our unbending, unified single source of truth (Single Source of Truth).

SaveManager: Established a robust player profile persistence and loading routine via the secure file path user://hive_profile.save.

HexData: Created the "Soul" resource for every single grid element, tracking owner states, precise coordinates, and the complete spectral resonance dictionary.

2. UI & Main Menu

MainMenu Scene: Integrated the hand-drawn parchment selection layout.

Selection Logic: Implemented a priority-based selection matrix:


$$\text{First Click} = \text{Player (Gold Highlight)}$$

$$\text{Subsequent Clicks} = \text{Rivals (Red Highlight)}$$

HexButton Component: A tool-scripted Area2D component boasting dynamic viewport clipping, non-uniform portrait scaling, and anti-aliased, soft Line2D borders.

3. The Battlefield

GameWorld Scene: Established the high-level scene tree including a dynamic WorldCamera that automatically centers and scales itself perfectly to the origin of the hex grid.

HexGrid Orchestrator: Programmed ring-based grid generation using highly performant axial coordinates (Vector3i).

Guardian Deployment: Programmed the start positions in a symmetric $120^\circ$ triangle configuration (Player at Southeast, Rivals at North and Southwest) with exact color-spectrum initialization.

HexCell Component: Interactive, physical grid units with responsive hover effects, click signals, and anti-aliased edge rendering.

⬢ Phase III: Resonance & Rhythm

Status: Complete (The Heartbeat Ignites)

This phase transitioned the playing field from a static grid into a dynamic, rhythmic strategy ecosystem. We successfully implemented the global game loop heartbeat and established the multidimensional energy spectrum.

1. The Rhythmic Engine (The Heartbeat)

BeatManager (Autoload): The clock of the H.I.V.E. universe. Orchestrates the global gameplay loop into three distinct, recurring phases:

LOADING ($50\%$ time window): Strategic planning, Drag-to-Flow vector routing, and ability selection.

PULSING ($30\%$ time window): Physical expansion and charging of energy waves along connection vectors.

ECHOING ($20\%$ time window): Resolving damage and healing impacts, triggering overflow cascades, and passive regeneration.

Phase Visualizer: A progress bar HUD component synchronized with the global EventBus that communicates the active phase, remaining time, and tension to the player using rhythmic color shifts.

2. Spectral Resonance Philosophy (The Spectrum)

Multi-Guardian Occupancy: Moved away from binary ownership. Cells now act as vessels storing the resonance levels of all six guardian ecosystems simultaneously.

Dominance Logic: Ownership (current_owner) switches automatically to the faction with the highest energy as soon as a dominance threshold of $> 5.0$ points is reached. Sub-dominant energies remain passive inside the vessel.

Dynamic Color Blending: Implemented a real-time color blending engine based on Color.lerp(), which dynamically calculates the cell's visual color based on the weight of all contained resonance spectrums.

3. Advanced Interaction & Game Feel (The Flow)

Drag-to-Flow Control: A tactile energy-injection system. Players drag from a dominant source cell to a neighboring cell to define connection transfer vectors for the upcoming PULSING phase.

Logarithmic Feedback: The connection line's thickness scales logarithmically with the amount of flowing energy, providing a heavy, powerful visual feedback loop.

Haptic Snapping: Coupled subtle camera-leaning effects (maximum $15\text{px}$ offset) and haptic vibration (Input.vibrate_handheld(20)) to successful connection vector snapping.

4. Balancing & Scalability (The Symphony)

Overflow Cascade System: Engineered buffer-based overflow logic to prevent recursion crashes and performance freezes. Excess energy above the limit ($> 100.0$) is relocated into a global buffer and distributed equally ($1/6$) to the six neighboring cells during the next step, secured by an automatic emergency brake capped at $8$ cascade steps.

Rival AI: A tactical CPU agent that analyzes grid threats and plans counter-strikes, limited by a fair hand-speed bottleneck (Action Points) to match human reaction times.

Triple-Tier UI: Each CellUI component sorts and visualizes the top 3 dominant resonance values in real-time, color-coded to match the team palettes.

⬢ Phase IV: The Call of the Wolf

Status: Complete (The Emerald Fortification)

This phase breathed life into the structural grid by implementing the first complete, asymmetric Guardian ecosystem. We established a reusable, decoupled component architecture for unique guardian logic and the circular ability selection radial menu.

1. Universal Interface (The Radial Core)

Math-Driven Radial Menu: A procedural, circular ring menu that uses trigonometry to fan out ability buttons in precise $60^\circ$ steps around the selected cell.

Separation of Inputs: Successfully uncoupled left-click dragging mechanics (Drag-to-Flow) from right-click tactical micro-management (Radial Menu activation).

Centralized Description Hub: A wrap-smart text label at the bottom screen bounds, allowing real-time, dynamic ability tooltips to overlay on hover without battlefield obstruction.

2. Advanced Architectural Separation (The SRP Refactoring)

GuardianLogic Componentization: Outsourced specific archetype behaviors from the physical HexCell into lightweight standalone scripts (GuardianLogic, WolfLogic) that are dynamically injected and recycled upon cell conversion.

CellUI Encapsulation: Isolated the cell's internal sorting algorithms and UI text assignments into an independent class CellUI, stripping down core cell script weight by nearly $50\%$.

Global Action Regulation: Registers active actions in the BeatManager to enforce round-based tactical limits globally.

3. Emerald Resonance Balance (The Wolf Pack)

Root Network (Passive): High territorial scaling. Generates $+6.0$ base resonance per pulse, plus a local Pack Bonus of $+0.5$ energy per adjacent friendly Wolf cell (capped at $+9.0$ maximum regeneration).

Thorn Wall (Active): A defensive barrier buffing active cells during the PULSING phase, instantly slicing all incoming damage by $50\%$ for $3$ consecutive pulses.

Call of the Pack (Ultimate): Deploys a massive, concentric 3-ring sonic shockwave using asynchronous cube-distance timers. Injects heavy emerald resonance layers ($+33$, $+22$, $+11$) outwards with a staggered delay, followed by a border-flash ring animation.

⬢ Phase V: The Depth of the Shark & The Great Refactor

Status: Complete (The Ship of KIseus)

This epoch represents the ultimate architectural maturity of H.I.V.E. By initiating a complete, system-wide refactoring cycle, we eradicated memory leaks, separated Concerns via Strategy Patterns, and unleashed the tidal wrath of the Shark.

1. Structural Architecture & Communication

                 ⬢ [EventBus Autoload] ⬢
                /           |           \
      [BeatManager]     [HexGrid]     [HexCell]
            |               |             |
       (Phases/AP)     (Flow Calc)   (Dynamic UI)
                            |             |
                   [GuardianLogic] <-- (Injected)
                      /        \
              [WolfLogic]    [SharkLogic]


The RefCounted Strategy Pattern: Converted the base class GuardianLogic and its children (WolfLogic, SharkLogic) into pure RefCounted objects. This guarantees 100% automated garbage collection upon cell ownership swap, completely preventing memory leaks.

Zero-Dependency HexCells: Completely decoupled cells from concrete guardian classes. Cells are now agnostic vessels; strategic behaviors are dynamically injected from the outside at runtime.

The Centralized EventBus: Implemented a global decoupled event broker (EventBus) handling all asynchronous communication. This eliminated circular dependency locks across all core systems.

Editor Tool Hardening: Armored all @tool scripts (ability_hex.gd, hex_button.gd) with robust is_node_ready() checks, ensuring layout changes in the Godot editor never cause rendering crashes.

Dynamic Description Formatting Engine

Dynamic Descriptions: Completely freed descriptions from hardcoded numerical values. Guardian resource templates (.tres) declare dynamic placeholder tokens inside curly brackets (e.g. {cost}, {duration}, {range}).

Format Engine: Integrated format utilities inside guardian_resource.gd read these tokens at runtime and populate the UI elements live with active, real-time balancing variables.

Deep Blue Carnage Balance (The Shark Archetype)

Bloodlust (Passive): Modulates outbound energy transfers via the modify_outgoing_flow() hook. Senses network vulnerability: when sending energy to a weakened target node (total resonance below $33\%$), transfer throughput is amplified by a $1.5\times$ frenzy multiplier.

Maelstrom (Active): An advanced siphon vortex. Extracts up to $7.0$ resonance from all adjacent non-allied nodes, distributes a dynamic allied pack-buff:


$$\text{Ally Buff} = 3.0 + 3.0 \times \text{Drained Enemies}$$


to neighboring allied Sharks, and deposits the remaining net surplus energy onto the casting node.

Tsunami (Ultimate): Unleashes a cascading directional fanning cone wave.

6-Directional Snapping Targeting: Activating targeting mode closes the radial wheel and spans a mouse guide line. The system snaps the mouse angle to the closest of the $6$ core hex axes and draws a real-time fanning preview.

The Fanning Maelstrom (Wave Geometry): Spreads a symmetrical fanning cone wave up to $7$ steps depth (wave layout: $1 \rightarrow 2 \rightarrow 3 \dots$ affected cells).

Tidal Damage & Siphon: Inflicts step-scaled damage to hostiles (Wave step 1 deals $25.0$ base damage, step $k$ increases by $+7.0$ damage scale per step) and reclaims $50\%$ of crushed enemy resonance as active Shark energy.

Tidal Claims (Neutrals): Floods neutral cells in the wave's path and converts $50\%$ of the damage rating into active Shark resonance (rapid territorial conversion).

Tidal Surge (Allies): Invigorates and boosts friendly allied Shark cells hit by the wave with an energy boost equal to $25\%$ of the wave's damage rating.

Visual Hover-Fix: The HexGrid manager enforces preview borders on all target cells every frame, bypassing hover-resets from mouse_entered signals to keep target previews perfectly highlighted.

⬢🌿🐺 (Wolf: +9.0 Pack / 50% Vines / 3-Ring Shockwave)
⚡🦈💧 (Shark: 1.5x Bloodlust / Vortex Siphon / Cone Tsunami)
🐝🍯🔥🐦‍🔥🕸️🕷️🌬️🦅🚀⬢