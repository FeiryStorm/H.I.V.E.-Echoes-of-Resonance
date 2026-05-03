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
