⬢ The Bestagon Way ⬢

⬢ A Style Guide to Harmonic GDScript 2.0 Code ⬢ by Team Bestagon ⬢

„Code is written for humans to read, and only incidentally for machines to execute. A clean script is like a well-tended Zen garden: every line has its purpose and place, every blank space allows the structure to breathe and resonate.“ — The Philosophy of Team Bestagon.

This document defines the absolute architectural and stylistic pillars for developing H.I.V.E. - Echoes of Resonance in Godot 4.x (GDScript 2.0). Every developer and AI assistant entering our Dojo must strictly adhere to these principles to maintain harmony within the grid.

📐 1. The Soul of the Code (Formatting & Readability)

We strictly reject aggressive minification, cramped, unreadable logic, and dense code. Readability and long-term maintainability are our highest priorities.

Room to Breathe (Vertical Spacing): Logical blocks within a function must be separated by a single empty line. This allows the human eye to easily distinguish where one calculation ends and the next begins.

Vertical Data Structures: Arrays and Dictionaries containing more than three elements or complex spatial vectors must be formatted vertically.

# ❌ INCORRECT (Dense and hard to scan)
var dirs = [Vector3i(1,-1,0), Vector3i(1,0,-1), Vector3i(0,1,-1), Vector3i(-1,1,0)]

# ✅ CORRECT (The Bestagon Style)
var directions: Array[Vector3i] = [
    Vector3i(1, -1, 0), 
    Vector3i(1, 0, -1), 
    Vector3i(0, 1, -1), 
    Vector3i(-1, 1, 0)
]


Meaningful Comments: Comments must explain the Why, not the What. They divide the script into clear thematic chapters (e.g., # --- ENGINE CORES ---). Never strip established educational comments during refactoring sessions!

🔤 2. Unified Naming Conventions & Scoping

Names carry structural weight – select them so they remain clear even during a 3 AM emergency debugging session.

The p_ Parameter Prefix: All function arguments and parameters MUST start with the p_ prefix (e.g., func setup(p_cell: Area2D)). This prevents compiler "shadowing warnings", makes the code compatible with Godot's C++ core style, and visually separates temporary parameters from persistent class variables.

The Mathematical Exception: Local helper variables within highly localized, static math operations (like in HexMath) are permitted to use established short-hands (e.g., q, r, s, dist, rad) to keep equations readable. Everywhere else, descriptive names are mandatory.

Classes and Files: Filenames must use snake_case (e.g., hex_grid.gd), while class declarations must use PascalCase (e.g., class_name HexGrid).

🛡️ 3. Absolute Type Safety

Godot 4.x features a powerful static analyzer. We utilize static typing consistently to catch bugs during development, long before they can crash the runtime.

Explicit Type-Hinting: Every variable, function argument, and return type must be explicitly typed (e.g., var energy: float = 0.0, -> void). Avoid using untyped variants unless absolutely necessary.

Safe Casting (as Keyword): When retrieving objects from untyped collections, dictionaries, arrays, or signals, always cast them to their concrete type immediately (e.g., var cell := all_cells[coords] as Area2D).

Enums as Distinct Types: Enums (such as HexData.Owner) must never be mixed with raw integers without explicit casting. Use p_role as HexData.Owner to guarantee typsafety.

🏛️ 4. Architecture of Decoupling (SRP)

The "Single Responsibility Principle" (SRP) is our guiding light. A script should do exactly one thing, and do it flawlessly.

The EventBus System: Nodes must never communicate across-the-board with distant systems if they do not share a direct parent-child relationship. All global notifications are dispatched and captured via the EventBus singleton. Circular dependencies are forbidden.

Vessels & Injections: Grid cells (HexCell) are designed as "Resonance Vessels." They do not contain hardcoded tactical abilities. Guardian-specific behaviors (e.g., WolfLogic) are dynamically injected from the outside by the grid controller.

Memory Safety via RefCounted Memory Management: Logic strategy classes must inherit from RefCounted (or our base GuardianLogic), never from Node. This allows Godot's internal garbage collector to automatically wipe discarded instances when a cell changes ownership, eliminating memory leaks.

🛠️ 5. Editor-Safe Tool Scripting

We build our UI to be highly interactive and dynamic directly inside the Godot Editor viewport. @tool scripts are incredibly powerful, but require absolute safety.

The is_node_ready() Guard: Every @tool script utilizing setter methods to manipulate UI elements in the editor MUST check if the node is fully prepared before accessing child references.

@export var radius: float = 80.0:
    set(p_val):
        radius = p_val
        if is_node_ready(): 
            _update_geometry()


⚡ 6. O(1) Spatial Calculations & Performance

Why iterate through hundreds of nodes when spatial geometry can solve the query instantly?

Geometry Over Loops: For all distance checks, neighbor queries, and area-of-effect calculations on the hex grid, we utilize the high-performance O(1) Manhattan distance formulas located in the HexMath utility class. Avoid physics raycasts or pathfinding algorithms for grid-coordinate logic.

🌱 7. Bestagon's Law of Pragmatism

„Code is organic. We are not afraid of simplifying an architecture we considered brilliant yesterday if it brings us clarity today. We choose functional stability over academic perfection.“

The Gardener Principle (Continuous Refactoring): Always leave the codebase cleaner than you found it. Pay off technical debt immediately upon discovery before it can paralyze the system.

Practicality Beats Purity: If a theoretically "imperfect" implementation proves to be significantly more stable, understandable, and performant during play testing, it will be favored over academic purity.

🚨 8. The "Better Safe Than Sorry" Protocol (Error Mitigation)

Since GDScript does not utilize traditional try/catch exception blocks due to engine performance optimizations, we handle errors defensively to ensure the game fails loudly during development, but remains resilient in the release build.

Assert to Prevent Hidden Bugs: Use assertions to protect invariants and guarantee that the game state never enters an impossible setup during development. Assertions crash the editor loudly so bugs cannot hide, but are automatically stripped in production builds.

func process_regeneration() -> void:
    assert(cell != null, "⬢ Error | Cannot execute regeneration tick on an unbound cell!")


Graceful Release Fallbacks: If an error state is reached in an exported build, log it with push_error() and exit the function early using safe fallback states rather than letting the game crash on the user.

func get_cell_at(p_coords: Vector3i) -> Area2D:
    if not all_cells.has(p_coords):
        push_warning("⬢ Grid | Requested cell at invalid coordinates: " + str(p_coords))
        return null
    return all_cells[p_coords] as Area2D


May the resonance be with you. 🖖⬢✨