# Anime Haul Visual Assets

## Art direction

The project uses a consistent high-detail anime 3D direction: cel-shaded low-poly forms, warm European Alpine color palettes, deep ink outlines, readable road geometry, practical street lighting, and realistic vehicle/audio behavior. The reference images below were generated as visual targets for scene composition and lighting; the playable Godot scene continues to use lightweight runtime 3D geometry so it remains suitable for Android.

## Generated visual targets

| Asset | Use |
|---|---|
| `art/visual_target_city.png` | City street, truck proportions, traffic signal and warm sunset lighting reference |
| `art/visual_target_mountain.png` | Snow mountain road, tunnel, guardrail and depth reference |
| `art/visual_target_rural.png` | Rural road, village, orchard, bridge and field reference |

## Scene previews

These previews are retained as quick visual checkpoints for the runtime biome pass.

| Asset | Checkpoint |
|---|---|
| `preview_city.png` | City lighting, buildings and traffic checkpoint |
| `preview_forest.png` | Deep forest and weather checkpoint |
| `preview_snow_mountain.png` | Snow pass, tunnel and fog checkpoint |
| `preview_plains.png` | Plains, fields and lake checkpoint |

## Runtime implementation

The runtime scene uses Godot `MeshInstance3D`, `BoxMesh`, `CylinderMesh`, `StandardMaterial3D`, procedural particles, dynamic lights and seeded streaming chunks. The latest vehicle pass adds a more detailed grille, cab windows, panel seams, side accents, bumper lamps, outline silhouettes and anime material response. The road pass adds shoulders, pavement cracks, reflectors, chevron boards, lane dashes and amber edge markers to create readable driving rhythm. Traffic vehicles use independent tail-lamp references so red-light braking is visible. Streaming generation avoids duplicate biome-detail passes, and the camera uses a smoothed persistent look target for stable mobile presentation. This keeps the reference direction while avoiding large imported assets that would exceed Android memory budgets.

## Audio direction

Vehicle and weather sound remains realistic-style: diesel engine loop, air brakes, rain, wet tires, snow tires, wind and thunder. Visual assets are intentionally anime-styled while sound remains grounded and mechanical.

## Acceptance target

A screenshot should read immediately as an anime 3D long-haul truck game, with the truck as the focal point, a clearly modeled road, a coherent biome, visible route depth, and lighting that supports gameplay readability on a mobile display.

## Production checklist

The complete production-facing inventory is maintained in [`ART_ASSET_MASTER_LIST.md`](ART_ASSET_MASTER_LIST.md). It covers models, textures, materials, animations, VFX, UI, LOD, collision, naming, priority and Android budgets.

The current runtime HUD follows the city reference composition: route map at upper left, route card near the upper center, compact speed/fuel cards at upper right, destination/status card below them, and large touch controls along the lower edge. Settings and garage panels share the same navy-violet translucent cards, rounded corners, thin blue borders and warm highlight states.

The long-distance map production strategy is maintained in [`WORLD_ART_PRODUCTION_PLAN.md`](WORLD_ART_PRODUCTION_PLAN.md). It explains how a finite modular asset library, seeded 1 km streaming chunks, five biome families, sub-biomes and landmark cooldowns can create a varied 20,000 km route without authoring 20,000 km of unique meshes.

The acquisition and licensing strategy is maintained in [`ART_ASSET_ACQUISITION_PLAN.md`](ART_ASSET_ACQUISITION_PLAN.md). It maps each asset category to purchase, outsourcing, procedural generation or generated-reference workflows, and includes commercial-license checks and a staged replacement order.

Free source packs collected for the project are stored under `assets/free_source_packs/` with extracted files in `assets/free_source_import/`. The manifest and source/license links are recorded in `assets/free_source_packs/RESOURCE_MANIFEST.md` and `licenses/free_sources/LICENSE_SOURCES.md`.

The remaining-gap closure sequence is documented in [`ART_GAP_CLOSURE_PLAN.md`](ART_GAP_CLOSURE_PLAN.md). It prioritizes the player truck, driving-distance road assets, five biome landmarks, style unification, LOD, collision and Android integration instead of collecting unlimited additional packs.

## Generated files

- `art/visual_target_city.png`
- `art/visual_target_mountain.png`
- `art/visual_target_rural.png`
- `art/truck.svg` (editable vector fallback asset)
