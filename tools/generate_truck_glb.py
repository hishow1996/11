from pathlib import Path
import trimesh
from trimesh.visual.material import SimpleMaterial
from trimesh.visual import ColorVisuals

ROOT = Path(__file__).resolve().parents[1] / 'assets' / 'vehicles' / 'player_truck'
ROOT.mkdir(parents=True, exist_ok=True)

COLORS = {
    'orange': [239, 111, 97, 255],
    'cream': [255, 241, 207, 255],
    'ink': [33, 28, 55, 255],
    'glass': [159, 227, 255, 230],
    'gold': [255, 209, 102, 255],
    'tire': [28, 31, 46, 255],
    'metal': [115, 129, 151, 255],
    'red': [239, 80, 76, 255],
    'signal': [255, 154, 66, 255],
}

def mat(name):
    return SimpleMaterial(name=name, diffuse=COLORS[name])

def add(scene, mesh, name, material):
    mesh.visual = ColorVisuals(mesh=mesh)
    mesh.visual.material = mat(material)
    scene.add_geometry(mesh, node_name=name, geom_name=name)

def box(size, loc):
    m = trimesh.creation.box(extents=size)
    m.apply_translation(loc)
    return m

def cyl(radius, depth, loc, axis=(1,0,0), sections=12):
    m = trimesh.creation.cylinder(radius=radius, height=depth, sections=sections)
    # cylinder default axis is Z; wheel axle needs X
    import numpy as np
    if axis == (1,0,0):
        m.apply_transform(trimesh.transformations.rotation_matrix(1.57079632679, [0,1,0]))
    m.apply_translation(loc)
    return m

def build(lod):
    scene = trimesh.Scene()
    detail = lod == 0
    medium = lod <= 1
    sections = 16 if detail else (10 if medium else 8)
    add(scene, box((4.9,2.25,7.2),(0,1.35,0.9)), 'Trailer_Body', 'cream')
    add(scene, box((4.0,2.7,2.7),(0,1.55,-3.25)), 'Cab_Body', 'orange')
    add(scene, box((3.25,0.95,0.16),(0,2.15,-4.65)), 'Windshield', 'glass')
    add(scene, box((4.2,0.18,0.18),(0,0.35,-4.7)), 'Front_Bumper', 'ink')
    add(scene, box((1.8,0.38,0.16),(0,0.86,-4.76)), 'Front_Grille', 'metal')
    for y in (0.72,0.84,0.96):
        add(scene, box((1.55,0.05,0.08),(0,y,-4.86)), 'Grille_Slat', 'ink')
    add(scene, box((4.98,0.3,7.0),(0,2.28,0.9)), 'Trailer_Stripe', 'orange')
    if medium:
        add(scene, box((1.9,0.14,0.12),(0,2.55,-3.45)), 'Roof_Stripe', 'gold')
        for side in (-1,1):
            add(scene, box((0.08,0.72,1.1),(side*2.1,1.58,-3.3)), 'Cab_Side_Window', 'glass')
            add(scene, box((0.28,0.62,0.42),(side*2.25,1.85,-3.72)), 'Mirror', 'ink')
    wheel_positions = [(-2.1,-2.8), (2.1,-2.8), (-2.1,2.5), (2.1,2.5)]
    for i,(x,z) in enumerate(wheel_positions):
        add(scene, cyl(0.62,0.42,(x,0.62,z),sections=sections), f'Wheel_{i+1}', 'tire')
        if medium:
            add(scene, cyl(0.25,0.44,(x,0.62,z),sections=sections), f'Hub_{i+1}', 'gold')
    if detail:
        for side in (-1,1):
            add(scene, box((0.16,0.5,2.8),(side*2.56,1.05,0.75)), 'Trailer_Side_Outline', 'ink')
            add(scene, box((0.42,0.52,2.2),(side*2.25,0.62,0.15)), 'Fuel_Tank', 'metal')
        for x in (-1.6,1.6):
            add(scene, box((0.3,0.3,0.2),(x,1.8,-4.65)), 'Headlight', 'gold')
            add(scene, box((0.32,0.26,0.16),(x,1.65,4.58)), 'Brake_Lamp', 'red')
            add(scene, box((0.22,0.22,0.16),(x,1.95,4.58)), 'Signal_Lamp', 'signal')
        add(scene, cyl(0.22,0.9,(-1.55,1.15,4.65),axis=(0,0,1),sections=12), 'Exhaust', 'ink')
    return scene

for lod in range(3):
    scene = build(lod)
    scene.export(ROOT / f'player_truck_lod{lod}.glb', file_type='glb')
print('generated', ', '.join(f'player_truck_lod{i}.glb' for i in range(3)))
