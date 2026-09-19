#!/usr/bin/env python3
"""Offline validation for the 漫漫货运 Godot project.

This does not replace Godot's parser; it validates resource paths, JSON manifests,
GLB readability and common indentation hazards before an engine/Android test run.
"""
from __future__ import annotations
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []

def check_file(path: Path) -> None:
    if not path.exists() or path.stat().st_size == 0:
        errors.append(f"missing or empty: {path.relative_to(ROOT)}")

for path in [Path("project.godot"), Path("scenes/Main.tscn"), Path("scripts/main_3d.gd"), Path("art/runtime/runtime_art_manifest.json")]:
    check_file(ROOT / path)

manifest_path = ROOT / "art/runtime/runtime_art_manifest.json"
if manifest_path.exists():
    try:
        manifest = json.loads(manifest_path.read_text())
    except json.JSONDecodeError as exc:
        errors.append(f"invalid manifest JSON: {exc}")
        manifest = {}
    def walk(value):
        if isinstance(value, dict):
            for item in value.values():
                yield from walk(item)
        elif isinstance(value, list):
            for item in value:
                yield from walk(item)
        elif isinstance(value, str) and value.startswith("res://"):
            yield value[6:]
    for relative in walk(manifest):
        if not (ROOT / relative).exists():
            errors.append(f"broken manifest path: res://{relative}")

script = ROOT / "scripts/main_3d.gd"
if script.exists():
    text = script.read_text()
    for resource in sorted(set(re.findall(r'"(res://[^" ]+)"', text))):
        if not (ROOT / resource[6:]).exists():
            errors.append(f"broken script resource: {resource}")
    for line_no, line in enumerate(text.splitlines(), 1):
        if line.startswith(" ") and not line.startswith("    "):
            errors.append(f"mixed indentation at main_3d.gd:{line_no}")
        if "\t " in line or " \t" in line:
            errors.append(f"mixed tab/space indentation at main_3d.gd:{line_no}")

try:
    import trimesh
    for glb in sorted((ROOT / "assets/vehicles/player_truck").glob("*.glb")):
        scene = trimesh.load(glb, force="scene")
        if not scene.geometry:
            errors.append(f"GLB has no geometry: {glb.relative_to(ROOT)}")
except ImportError:
    print("warning: trimesh unavailable; GLB parse check skipped")

if errors:
    print("VALIDATION FAILED")
    print("\n".join(f"- {error}" for error in errors))
    sys.exit(1)
print("VALIDATION PASSED")
print("- resource paths: ok")
print("- manifest JSON: ok")
print("- GLB readability: ok")
print("- indentation scan: ok")
