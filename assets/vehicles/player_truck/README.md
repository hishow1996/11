# Player truck GLB pack

This folder contains a Godot-ready low-poly anime semi-trailer truck generated with `tools/generate_truck_glb.py`.

| File | Intended use | Contents |
|---|---|---|
| `player_truck_lod0.glb` | Near view | Cab, trailer, windows, mirrors, grille, wheels, hubs, lamps, exhaust and fuel tanks |
| `player_truck_lod1.glb` | Mid view | Cab, trailer, windows, mirrors, grille, wheels and hubs |
| `player_truck_lod2.glb` | Far view | Cab, trailer and wheels |

The model uses Godot-compatible glTF 2.0 binary files and shared simple materials. The collision resource is `res://art/runtime/player_truck_collision.tres`. The original online reference is recorded under `assets/vehicles/source/SOURCE_LICENSE.md`.

The current gameplay script keeps its procedural truck as a safe fallback so wheel animation, cockpit instruments, lights and Android behavior remain available while the authored GLB is integrated into the final vehicle controller.
