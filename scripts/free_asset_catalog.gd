extends RefCounted

## Runtime catalog for the collected free assets.
## Only lightweight GLB assets are instantiated at runtime; raw ZIP packs stay as source archives.

const ROAD_ASSETS := [
	"res://assets/free_source_import/kenney_city-kit-roads/Models/GLB format/road-straight.glb",
	"res://assets/free_source_import/kenney_city-kit-roads/Models/GLB format/road-bend.glb",
	"res://assets/free_source_import/kenney_city-kit-roads/Models/GLB format/road-bridge.glb",
	"res://assets/free_source_import/kenney_city-kit-roads/Models/GLB format/traffic-light.glb"
]
const NATURE_ASSETS := [
	"res://assets/free_source_import/kenney_nature-kit/Models/GLTF format/tree_default.glb",
	"res://assets/free_source_import/kenney_nature-kit/Models/GLTF format/rock_largeA.glb",
	"res://assets/free_source_import/kenney_nature-kit/Models/GLTF format/bridge_center_wood.glb"
]
const TRAFFIC_ASSETS := [
	"res://assets/free_source_import/optional/traffic_road_assets/Traffic Road Assets/GLB/Streetlights/Streetlights.glb",
	"res://assets/free_source_import/optional/traffic_road_assets/Traffic Road Assets/GLB/Water Hydrant/Water_Hydrant.glb"
]

static func instantiate(parent: Node3D, path: String, position: Vector3, scale_factor: float = 1.0, rotation_y: float = 0.0) -> Node3D:
	if not ResourceLoader.exists(path):
		return null
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		return null
	instance.position = position
	instance.rotation.y = rotation_y
	instance.scale = Vector3.ONE * scale_factor
	instance.name = "FreeAsset_" + path.get_file().get_basename()
	parent.add_child(instance)
	apply_toon_materials(instance)
	return instance

static func apply_toon_materials(root: Node3D) -> void:
	if root == null:
		return
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface_index in mesh_instance.mesh.get_surface_count():
			var source := mesh_instance.get_active_material(surface_index)
			if source is StandardMaterial3D:
				var toon := (source as StandardMaterial3D).duplicate() as StandardMaterial3D
				toon.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
				toon.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
				toon.roughness = max(toon.roughness, 0.72)
				mesh_instance.set_surface_override_material(surface_index, toon)

static func add_lod_visibility(root: Node3D, near_distance: float = 55.0, far_distance: float = 125.0) -> void:
	if root == null:
		return
	for child in root.find_children("*", "GeometryInstance3D", true, false):
		var geometry := child as GeometryInstance3D
		if geometry:
			geometry.visibility_range_begin = near_distance
			geometry.visibility_range_end = far_distance
			geometry.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED

static func road_path(index: int) -> String:
	return ROAD_ASSETS[abs(index) % ROAD_ASSETS.size()]

static func nature_path(index: int) -> String:
	return NATURE_ASSETS[abs(index) % NATURE_ASSETS.size()]

static func traffic_path(index: int) -> String:
	return TRAFFIC_ASSETS[abs(index) % TRAFFIC_ASSETS.size()]
