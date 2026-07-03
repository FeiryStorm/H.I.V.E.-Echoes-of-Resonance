⬢ H.I.V.E. Architecture Manifest ⬢

The Nexus of Decoupling & Unified Resonance (Phases IV & V)

This architectural manifest serves as the unbending structural blueprint for the high-performance decoupled gameplay loop of H.I.V.E.

🏛️ 1. Core Architectural Pipeline

Our core layout isolates persistent data, dynamic logic strategies, and visual UI rendering into strict, unidirectional modules to guarantee zero circular dependency locks.

                  ⬢ [EventBus Autoload] ⬢
                 /           |           \
       [BeatManager]     [HexGrid]     [HexCell]
             |               |             |
        (Phases/AP)     (Flow Calc)   (Dynamic UI)
                             |             |
                    [GuardianLogic] <-- (Injected)
                       /        \
               [WolfLogic]    [SharkLogic]


1. The Global Event Broker (EventBus)

The Single Source of Decoupling: Global signals (phase_changed, pulse_impacted, resonance_changed) are routed strictly through the EventBus singleton.

No node is allowed to directly request or monitor sibling nodes unless they share a direct parent-child hierarchy.

2. The RefCounted Strategy Pattern

Core logic strategy brains (e.g., WolfLogic, SharkLogic) inherit directly from RefCounted, never from Node.

This secures automatic memory management: when a grid cell shifts owners, the previous strategy instance is immediately discarded and garbage collected by the Godot engine, entirely preventing system memory leaks.

3. Agnostic Resonance Vessels (HexCell)

HexCell scripts contain absolutely no preloads or hardcoded references to specific guardian mechanics.

Cells are modular containers designed to track spectral values and host dynamic logic injections. Behavior is dynamically attached and executed by the HexGrid controller at runtime.

⚡ 2. Static O(1) Performance Routines

Grid positioning, hover calculations, and distance calculations bypass heavy engine queries entirely by utilizing static, pure mathematical operations.

Axis Conversions (HexMath): Translating vector screen coordinates to hexagonal cube coordinates is computed instantly in $O(1)$ time using static coordinate conversions.

Cube Distances: Symmetrical radius calculations and range-checks utilize Manhattan cube distance checks:


$$\text{Distance} = \frac{|x_a - x_b| + |y_a - y_b| + |z_a - z_b|}{2}$$

This prevents expensive physics raycasts and loops, ensuring consistent, framerate-independent rendering performance on mobile platforms.