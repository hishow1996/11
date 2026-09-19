# Implementation Plan

- [x] Vertical slice: Godot project boot + single scene.
- [x] Driving model: acceleration, braking, steering, fuel and distance.
- [x] World rendering: anime alpine backdrop, road perspective, traffic and truck.
- [x] Mobile controls: four touch buttons mapped to input actions.
- [x] Freight market hall: browse, filter by cargo category, sort by payout, inspect route previews and detailed cargo parameters, and accept multiple contracts.
- [x] Contract handoff: enter the driving HUD after acceptance with live destination, ETA, remaining distance, and navigation map guidance.
- [x] Delivery scoring: smooth driving, collision penalties, grade-based payout and achievements.
- [x] Radio system: off, upbeat route BGM, and high-energy driving BGM with dynamic mixing.
- [x] Startup flow: loading transition, animated logo intro, and main menu before driving.
- [x] Audio: layered diesel loop and air-brake WAV generated locally.
- [ ] Future slice: 3D cab camera and actual Android device tuning.
- [ ] Future slice: save slots, garage upgrades, weather and more routes.

## Verification
Run the audio generator, inspect generated WAVs, open the project in Godot 4, press Play, and verify the success criteria in `SPEC.md`. For Android, set an Android export preset and test portrait/landscape safe areas on a physical device.
