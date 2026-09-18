# Anime Haul — Final Art Audit and Recovery

## Audit result

The project contains the generated visual target set, downloaded free source packs, the procedural runtime vehicle/world implementation, cockpit details, traffic variants, road-network details, livery/decal assets, and the newly generated completion atlases for weather VFX, HUD icons, service facilities, vegetation LOD, and truck paint references.

The following are intentionally separated:

| Category | Current state |
|---|---|
| Runtime 3D gameplay | Procedural Godot 4 meshes and existing imported GLB source assets are active |
| Generated art | PNG reference/material atlases in `art/`, used as style and production targets |
| Formal authored GLB player truck | Still a future replacement asset; the procedural truck remains the safe Android fallback |
| LOD/collision | Runtime visibility-range LOD and procedural/simple collision approach are active; authored LOD GLBs are not falsely claimed as complete |
| Five biome landmarks | Procedural landmarks plus generated atlas targets and collected source packs |
| Android delivery | Compatibility renderer, quality modes, streamed chunks and mobile controls remain enabled |

## Large-pack recovery

GitHub's regular file limit is 100 MB. The optional source pack `ground-grass-road-floor.zip` was 125,795,331 bytes, so it is stored as two repository-safe parts:

```text
assets/free_source_packs/optional/ground-grass-road-floor_parts/ground-grass-road-floor.zip.part-000
assets/free_source_packs/optional/ground-grass-road-floor_parts/ground-grass-road-floor.zip.part-001
```

To reconstruct the original archive from the project root:

```bash
cat assets/free_source_packs/optional/ground-grass-road-floor_parts/ground-grass-road-floor.zip.part-* \
  > /tmp/ground-grass-road-floor.zip
sha256sum -c assets/free_source_packs/optional/ground-grass-road-floor_parts/SHA256SUMS.txt \
  --ignore-missing
unzip -l /tmp/ground-grass-road-floor.zip
```

The checksum file records the original archive hash before splitting. The split parts are not runtime dependencies; they preserve the collected optional source pack without violating GitHub's per-file limit.
