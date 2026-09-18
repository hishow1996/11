extends Node3D

# Anime Haul 3D — Android-friendly third-person truck driving prototype.
# Art: stylized low-poly 3D with warm cel-like colors and ink-dark outlines simulated by silhouettes.
# Audio: realistic-style local diesel and air-brake WAV loops.

var truck: Node3D
var camera: Camera3D
var camera_look_target := Vector3.ZERO
var cockpit_mode := false
var speed := 0.0
var slope_percent := 0.0
var steer := 0.0
var distance := 0.0
var fuel := 78.0
var money := 1250
var damage := 0.0
var route_goal := 12.0
var cargo_index := 0
var destination := "LUCERNE"
var time_left := 184.0
var paused := false
var traffic: Array[Node3D] = []
var traffic_lanes := [-3.2, 0.0, 3.2, -3.2, 3.2, 0.0]
var traffic_speeds := [0.82, 1.05, 0.68, 0.92, 0.76, 1.12]
var traffic_types := ["car", "van", "bus", "wagon", "coach", "service"]
var traffic_lights: Array[MeshInstance3D] = []
var traffic_tail_lamps: Array[MeshInstance3D] = []
var traffic_signal_lamps: Array[MeshInstance3D] = []
var toast := "READY TO HAUL"
var toast_time := 3.0
var ui_speed: Label
var ui_route: Label
var ui_stats: Label
var ui_toast: Label
var engine_player: AudioStreamPlayer
var brake_player: AudioStreamPlayer
var rain_player: AudioStreamPlayer
var wind_player: AudioStreamPlayer
var wet_tire_player: AudioStreamPlayer
var snow_tire_player: AudioStreamPlayer
var thunder_player: AudioStreamPlayer
var virtual_controls: Control
var minimap: Control
var scenery: Array[Node3D] = []
var current_scene := "乡村公路"
var current_weather := "clear"
var weather_intensity := 0.0
var thunder_cooldown := 18.0
var game_hour := 8.0
var day_length_seconds := 420.0
var world_environment: WorldEnvironment
var environment: Environment
var sun: DirectionalLight3D
var moon: DirectionalLight3D
var rain_particles: GPUParticles3D
var snow_particles: GPUParticles3D
var lightning_light: OmniLight3D
var sky_material: ProceduralSkyMaterial
var road_surface: MeshInstance3D
var city_lights: Array[OmniLight3D] = []
var wheel_nodes: Array[MeshInstance3D] = []
var headlight_nodes: Array[OmniLight3D] = []
var road_puddles: Array[MeshInstance3D] = []
var hit_shake := 0.0
var exhaust_particles: GPUParticles3D
var brake_lamps: Array[MeshInstance3D] = []
var signal_lamps: Array[MeshInstance3D] = []
var station_positions: Array[Vector3] = []
var refueling := false
var repair_positions: Array[Vector3] = []
var repairing := false
var stream_chunks: Dictionary = {}
var stream_seed := 184729
var active_chunk := 0
var save_timer := 0.0
var engine_level := 0
var tire_level := 0
var tank_level := 0
var armor_level := 0
var garage_panel: Panel
var garage_label: Label
var settings_panel: Panel
var quality_mode := 1
var steering_sensitivity := 1.0
var master_volume := 0.8
var touch_steer := 0.0
var touch_throttle := 0.0
var touch_brake := 0.0
var interior_steering_wheel: MeshInstance3D
var interior_speed_display: Label3D
var interior_fuel_display: Label3D
var interior_rpm_display: Label3D
var interior_gear_display: Label3D
var interior_indicator_display: Label3D
var interior_nav_display: Label3D
var interior_mirrors: Array[MeshInstance3D] = []
var mirror_viewports: Array[SubViewport] = []
var mirror_cameras: Array[Camera3D] = []
var interior_wipers: Array[MeshInstance3D] = []
var interior_lamps: Array[MeshInstance3D] = []
var wiper_phase := 0.0
var mirrors_enabled := true
var interior_warning_display: Label3D
var truck_detail_nodes: Array[MeshInstance3D] = []
var truck_livery_parts: Array[MeshInstance3D] = []
var cargo_decal_labels: Array[Label3D] = []
var cargo_badge_lights: Array[MeshInstance3D] = []
var safety_reflectors: Array[MeshInstance3D] = []
const FreeAssetCatalog = preload("res://scripts/free_asset_catalog.gd")

const ROAD_WIDTH := 12.0
const ROAD_LENGTH := 20000000.0 # 20000 km at 1 world unit = 1 meter.
const CHUNK_LENGTH := 1000.0 # 1 km streaming chunk.
const INK := Color("#211c37")
const ASPHALT := Color("#40455b")
const CREAM := Color("#fff1cf")
const CORAL := Color("#ef6f61")
const MINT := Color("#74d0ad")
const SKY := Color("#86d6e8")
const SAVE_PATH := "user://anime_haul_save.json"
const ROAD_CLEAR_TEXTURE = preload("res://art/runtime/road_surface.svg")
const ROAD_WET_TEXTURE = preload("res://art/runtime/road_wet.svg")
const ROAD_SNOW_TEXTURE = preload("res://art/runtime/road_snow.svg")
const RAIN_STREAK_TEXTURE = preload("res://art/runtime/rain_streak.svg")
const SNOW_FLAKE_TEXTURE = preload("res://art/runtime/snow_flake.svg")
const ORANGE_LIVERY_TEXTURE = preload("res://art/runtime/truck_livery_orange.svg")
const BLUE_LIVERY_TEXTURE = preload("res://art/runtime/truck_livery_blue.svg")
const UI_FUEL_TEXTURE = preload("res://art/runtime/ui_fuel.svg")
const UI_WEATHER_TEXTURE = preload("res://art/runtime/ui_weather.svg")
const UI_ROUTE_TEXTURE = preload("res://art/runtime/ui_route.svg")

func _ready() -> void:
	_load_save()
	_build_environment()
	_build_weather_effects()
	_build_world()
	_build_truck()
	_build_traffic()
	_build_camera()
	_build_ui()
	_build_audio()
	_apply_quality(quality_mode)
	_apply_sensitivity(steering_sensitivity)
	_apply_volume(master_volume)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()

func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		money = int(data.get("money", money))
		fuel = float(data.get("fuel", fuel))
		damage = float(data.get("damage", damage))
		distance = float(data.get("distance", distance))
		cargo_index = int(data.get("cargo_index", cargo_index))
		game_hour = float(data.get("game_hour", game_hour))
		engine_level = int(data.get("engine_level", engine_level))
		tire_level = int(data.get("tire_level", tire_level))
		tank_level = int(data.get("tank_level", tank_level))
		armor_level = int(data.get("armor_level", armor_level))
		quality_mode = int(data.get("quality_mode", quality_mode))
		steering_sensitivity = float(data.get("steering_sensitivity", steering_sensitivity))
		master_volume = float(data.get("master_volume", master_volume))
		route_goal = 10.0 + float(cargo_index * 2)
		destination = ["LUCERNE", "INNSBRUCK", "MILAN"][cargo_index]

func _save_game() -> void:
	var data := {
		"money": money,
		"fuel": fuel,
		"damage": damage,
		"distance": distance,
		"cargo_index": cargo_index,
		"game_hour": game_hour,
		"engine_level": engine_level,
		"tire_level": tire_level,
		"tank_level": tank_level,
		"armor_level": armor_level,
		"quality_mode": quality_mode,
		"steering_sensitivity": steering_sensitivity,
		"master_volume": master_volume
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func _haptic(duration_ms: int, amplitude: float) -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(duration_ms, amplitude)

func _mat(color: Color, roughness := 0.82) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.62 if color == ASPHALT else roughness
	material.metallic = 0.08 if color == ASPHALT else 0.0
	material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return material

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, name := "Box") -> MeshInstance3D:
	var outlined_parts := ["Trailer", "Cab", "Windshield", "FrontBumper", "TrailerStripe", "Body", "Glass", "Lamp", "CabSideWindow", "BumperLamp", "CityBalcony"]
	var mesh := BoxMesh.new()
	mesh.size = size
	if name in outlined_parts:
		var outline_mesh := BoxMesh.new()
		outline_mesh.size = size * 1.075
		var outline := MeshInstance3D.new()
		outline.name = name + "_AnimeOutline"
		outline.mesh = outline_mesh
		outline.material_override = _mat(INK, 1.0)
		outline.position = pos
		parent.add_child(outline)
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	parent.add_child(node)
	return node

func _cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color, name := "Cylinder") -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	if name in ["FrontWheel", "RearWheel", "Wheel", "Hub"]:
		var outline_mesh := CylinderMesh.new()
		outline_mesh.top_radius = radius * 1.11
		outline_mesh.bottom_radius = radius * 1.11
		outline_mesh.height = height * 1.08
		var outline := MeshInstance3D.new()
		outline.name = name + "_AnimeOutline"
		outline.mesh = outline_mesh
		outline.material_override = _mat(INK, 1.0)
		outline.position = pos
		parent.add_child(outline)
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	parent.add_child(node)
	return node

func _cone(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color, name := "Cone") -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	parent.add_child(node)
	return node

func _build_environment() -> void:
	world_environment = WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#4b78c2")
	sky_material.sky_horizon_color = SKY
	sky_material.ground_bottom_color = Color("#40516b")
	sky_material.ground_horizon_color = Color("#9bb07f")
	sky_material.sun_angle_max = 18.0
	sky_material.sun_curve = 0.08
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d8edff")
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("#bcd3dc")
	environment.fog_light_energy = 0.45
	environment.fog_density = 0.008
	environment.fog_height = 3.0
	environment.fog_height_density = 0.04
	environment.glow_enabled = true
	environment.glow_intensity = 0.72
	environment.glow_bloom = 0.12
	environment.glow_hdr_threshold = 1.15
	world_environment.environment = environment
	add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_color = Color("#fff1ca")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)
	moon = DirectionalLight3D.new()
	moon.light_color = Color("#8fa7d8")
	moon.light_energy = 0.0
	moon.shadow_enabled = false
	add_child(moon)

func _build_weather_effects() -> void:
	rain_particles = _weather_particles("RainParticles", Color("#a8d8ff"), 420, 0.75, 28.0)
	snow_particles = _weather_particles("SnowParticles", Color("#fff7df"), 260, 4.5, 2.2)
	lightning_light = OmniLight3D.new()
	lightning_light.name = "LightningFlash"
	lightning_light.light_color = Color("#e8f4ff")
	lightning_light.light_energy = 0.0
	lightning_light.omni_range = 55.0
	lightning_light.position = Vector3(0, 12, -20)
	add_child(lightning_light)

func _weather_particles(name: String, color: Color, amount: int, lifetime: float, velocity: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = name
	particles.amount = amount
	particles.lifetime = lifetime
	particles.local_coords = true
	particles.emitting = false
	var process_material := ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, -1, 0)
	process_material.initial_velocity_min = velocity * 0.72
	process_material.initial_velocity_max = velocity
	process_material.gravity = Vector3(0, -2.0 if name == "RainParticles" else -0.45, 0)
	process_material.scale_min = 0.045 if name == "RainParticles" else 0.10
	process_material.scale_max = 0.075 if name == "RainParticles" else 0.18
	process_material.color = color
	particles.process_material = process_material
	var quad := QuadMesh.new()
	quad.size = Vector2(0.045, 0.28) if name == "RainParticles" else Vector2(0.16, 0.16)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.texture = RAIN_STREAK_TEXTURE if name == "RainParticles" else SNOW_FLAKE_TEXTURE
	quad.material = material
	particles.draw_pass_1 = quad
	particles.position = Vector3(0, 10, 0)
	particles.visibility_aabb = AABB(Vector3(-18, -2, -24), Vector3(36, 22, 48))
	add_child(particles)
	return particles

func _build_world() -> void:
	var ground := _box(self, Vector3(180, 0.4, ROAD_LENGTH), Vector3(0, -0.35, -ROAD_LENGTH * 0.25), Color("#9bb07f"), "Grass")
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	road_surface = _box(self, Vector3(ROAD_WIDTH, 0.18, 260.0), Vector3(0, -0.12, -10.0), ASPHALT, "Road")
	road_surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for z in range(-120, 110, 12):
		_box(self, Vector3(0.22, 0.04, 5.5), Vector3(0, 0.01, z), CREAM, "LaneMarker")
		_box(self, Vector3(1.0, 0.035, 11.5), Vector3(-7.2, -0.01, z), Color("#68775f"), "RoadShoulder")
		_box(self, Vector3(1.0, 0.035, 11.5), Vector3(7.2, -0.01, z), Color("#68775f"), "RoadShoulder")
		_box(self, Vector3(0.18, 0.35, 12.0), Vector3(-6.35, 0.1, z), INK, "RoadEdge")
		_box(self, Vector3(0.18, 0.35, 12.0), Vector3(6.35, 0.1, z), INK, "RoadEdge")
		_add_guardrail(Vector3(-7.0, 0, z), -1.0)
		_add_guardrail(Vector3(7.0, 0, z), 1.0)
		_add_reflector(Vector3(-6.75, 0.32, z + 4.0))
		_add_reflector(Vector3(6.75, 0.32, z + 4.0))
		_add_puddle(Vector3(sin(float(z)) * 2.2, 0.06, z + 2.5), 0.7 + fmod(abs(z), 2.0) * 0.22)
		if z % 24 == 0:
			_add_road_crack(Vector3(-2.0 + fmod(abs(z), 3.0), 0.055, z + 3.0), 1.2)
			_add_road_crack(Vector3(2.4 - fmod(abs(z), 2.0), 0.055, z - 2.0), 0.8)
		if z % 48 == 0:
			_add_chevron_pair(z)
	for z in range(-115, 100, 18):
		_add_mountain_cluster(Vector3(-19, 0, z), 1.0 + float(abs(z % 4)) * 0.08)
		_add_mountain_cluster(Vector3(19, 0, z - 8), 0.8 + float(abs(z % 3)) * 0.09)
		_add_tree(Vector3(-9.0, 0, z + 4), 1.0)
		_add_tree(Vector3(9.0, 0, z - 3), 0.9)
	# Route zones: city → countryside → deep forest → mountain pass → plains.
	for z in range(-112, -72, 10):
		_add_city_block(float(z))
		if int(abs(z)) % 20 == 2:
			_add_city_intersection(float(z))
		if int(abs(z)) % 20 == 12:
			_add_city_landmark(float(z))
	_add_fuel_station(Vector3(-13.0, 0, -92.0), "CITY FUEL")
	for z in range(-68, -28, 12):
		_add_village_farm(float(z))
		_add_village_landmark(float(z))
		if int(abs(z)) % 24 == 20:
			_add_village_junction(float(z))
	_add_fuel_station(Vector3(13.0, 0, -48.0), "FARM FUEL")
	for z in range(-24, 24, 9):
		_add_deep_forest(float(z))
		_add_forest_landmark(float(z))
	for z in range(28, 70, 10):
		_add_mountain_pass(float(z))
		_add_mountain_warning(float(z))
		if int(abs(z)) % 20 == 8:
			_add_mountain_landmark(float(z))
	_add_repair_station(Vector3(-13.0, 0, 48.0))
	for z in range(74, 112, 12):
		_add_plain_field(float(z))
		_add_plain_landmark(float(z))
	_add_bridge(92.0)
	_add_direction_sign(Vector3(-7.4, 0, -86), "CITY")
	_add_direction_sign(Vector3(7.4, 0, 42), "PASS")
	for chunk_index in range(0, 7):
		_ensure_stream_chunk(chunk_index)

func _add_guardrail(pos: Vector3, side: float) -> void:
	var rail := Node3D.new()
	rail.position = pos
	add_child(rail)
	_box(rail, Vector3(0.12, 0.75, 11.5), Vector3.ZERO, Color("#aeb8c5"), "Guardrail")
	for post_z in [-4.5, 0.0, 4.5]:
		_box(rail, Vector3(0.16, 0.9, 0.16), Vector3(0, -0.35, post_z), INK, "GuardPost")

func _add_reflector(pos: Vector3) -> void:
	var reflector := _box(self, Vector3(0.10, 0.22, 0.06), pos, Color("#ffe28a"), "RoadReflector")
	var material := reflector.material_override as StandardMaterial3D
	material.emission_enabled = true
	material.emission = Color("#ffb84d")
	material.emission_energy_multiplier = 1.8

func _add_puddle(pos: Vector3, width: float) -> void:
	var puddle := _box(self, Vector3(width, 0.018, 1.6 + width), pos, Color("#526d88"), "RoadPuddle")
	var puddle_material := puddle.material_override as StandardMaterial3D
	puddle_material.roughness = 0.08
	puddle_material.metallic = 0.52
	puddle_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puddle_material.albedo_color = Color(0.20, 0.32, 0.45, 0.52)
	road_puddles.append(puddle)

func _add_road_crack(pos: Vector3, length: float) -> void:
	var crack := _box(self, Vector3(0.045, 0.012, length), pos, Color("#252b3d"), "RoadCrack")
	crack.rotation_degrees.y = -18.0 + fmod(abs(pos.z), 36.0)

func _add_chevron_pair(z: float) -> void:
	for side in [-1.0, 1.0]:
		var sign_root := Node3D.new()
		sign_root.position = Vector3(side * 7.25, 0, z)
		add_child(sign_root)
		_box(sign_root, Vector3(0.12, 1.7, 0.12), Vector3(0, 0.85, 0), INK, "ChevronPost")
		var board := _box(sign_root, Vector3(0.9, 0.5, 0.10), Vector3(0, 1.8, 0), Color("#ffd166"), "ChevronBoard")
		board.rotation_degrees.y = 0.0 if side < 0.0 else 180.0

func _add_direction_sign(pos: Vector3, text_hint: String) -> void:
	var sign_root := Node3D.new()
	sign_root.position = pos
	add_child(sign_root)
	_box(sign_root, Vector3(0.18, 3.0, 0.18), Vector3(0, 1.5, 0), INK, "SignPost")
	_box(sign_root, Vector3(2.6, 1.0, 0.12), Vector3(0, 3.15, 0), Color("#3478a8"), "DirectionSign")
	_box(sign_root, Vector3(1.6, 0.12, 0.05), Vector3(0, 3.15, -0.08), CREAM, "SignStripe")

func _add_city_lamp(parent: Node3D, pos: Vector3) -> void:
	_box(parent, Vector3(0.16, 4.4, 0.16), pos + Vector3(0, 2.2, 0), INK, "StreetLamp")
	_box(parent, Vector3(1.0, 0.16, 0.16), pos + Vector3(0.35, 4.35, 0), INK, "LampArm")
	var glow := _box(parent, Vector3(0.34, 0.18, 0.34), pos + Vector3(0.78, 4.25, 0), Color("#ffd166"), "LampGlow")
	var glow_material := glow.material_override as StandardMaterial3D
	glow_material.emission_enabled = true
	glow_material.emission = Color("#ff9a42")
	glow_material.emission_energy_multiplier = 2.5
	var point_light := OmniLight3D.new()
	point_light.name = "CityLampLight"
	point_light.position = pos + Vector3(0.78, 4.15, 0)
	point_light.light_color = Color("#ffb35c")
	point_light.light_energy = 0.0
	point_light.omni_range = 8.0
	point_light.shadow_enabled = false
	point_light.add_to_group("city_lights")
	parent.add_child(point_light)
	city_lights.append(point_light)

func _register_scenery(root: Node3D) -> void:
	scenery.append(root)

func _add_city_block(z: float) -> void:
	for side in [-1.0, 1.0]:
		var block := Node3D.new()
		block.position = Vector3(side * (11.0 + fmod(abs(z), 3.0)), 0, z)
		add_child(block)
			_box(block, Vector3(7.0, 6.0 + fmod(abs(z), 5.0), 7.0), Vector3.ZERO, Color("#e58c78"), "CityBuilding")
			_box(block, Vector3(7.2, 0.35, 7.2), Vector3(0, 3.2 + fmod(abs(z), 5.0), 0), Color("#53617d"), "CityRoof")
			for balcony_y in [1.0, 2.8, 4.6]:
				_box(block, Vector3(6.4, 0.12, 0.52), Vector3(0, balcony_y, -3.72), Color("#f5d3a4"), "CityBalcony")
				_box(block, Vector3(0.12, 0.5, 0.52), Vector3(-3.0, balcony_y + 0.22, -3.72), INK, "BalconyRail")
				_box(block, Vector3(0.12, 0.5, 0.52), Vector3(3.0, balcony_y + 0.22, -3.72), INK, "BalconyRail")
		for window_y in [1.2, 3.0, 4.8]:
			for window_x in [-2.0, 0.0, 2.0]:
				var window := _box(block, Vector3(1.1, 0.65, 0.18), Vector3(window_x, window_y, -3.55), Color("#9fe3ff"), "CityWindow")
				if int(abs(z) + window_y + window_x) % 3 == 0:
					var window_material := window.material_override as StandardMaterial3D
					window_material.emission_enabled = true
					window_material.emission = Color("#ffd166")
					window_material.emission_energy_multiplier = 1.8
		_add_city_lamp(block, Vector3(0, 0, -5.0))
		_register_scenery(block)

func _add_fuel_station(pos: Vector3, label_text: String) -> void:
	var station := Node3D.new()
	station.position = pos
	add_child(station)
	station_positions.append(pos)
	_box(station, Vector3(7.5, 0.12, 8.0), Vector3.ZERO, Color("#5b6d73"), "StationLot")
	_box(station, Vector3(6.0, 0.28, 2.2), Vector3(0, 3.4, 0), Color("#ef6f61"), "StationCanopy")
	for pump_x in [-2.0, 0.0, 2.0]:
		_box(station, Vector3(0.8, 1.6, 0.8), Vector3(pump_x, 0.9, 0), Color("#d5dded"), "FuelPump")
		var pump_light := _box(station, Vector3(0.38, 0.22, 0.12), Vector3(pump_x, 1.65, -0.42), Color("#74d0ad"), "PumpLight")
		var pump_material := pump_light.material_override as StandardMaterial3D
		pump_material.emission_enabled = true
		pump_material.emission = Color("#74d0ad")
		pump_material.emission_energy_multiplier = 2.0
	_box(station, Vector3(1.0, 4.0, 0.5), Vector3(3.9, 2.0, 0), Color("#ffd166"), "FuelSign")
	_box(station, Vector3(0.8, 0.18, 0.12), Vector3(3.9, 3.25, -0.28), CREAM, "FuelSignStripe")
	_register_scenery(station)

func _add_repair_station(pos: Vector3) -> void:
	var station := Node3D.new()
	station.position = pos
	add_child(station)
	repair_positions.append(pos)
	_box(station, Vector3(7.5, 0.12, 8.0), Vector3.ZERO, Color("#526476"), "RepairLot")
	_box(station, Vector3(5.8, 3.4, 3.4), Vector3(0, 1.7, 0), Color("#d47761"), "RepairGarage")
	_box(station, Vector3(6.5, 0.28, 1.0), Vector3(0, 3.55, 0), Color("#ffd166"), "RepairCanopy")
	_box(station, Vector3(1.8, 1.5, 0.18), Vector3(0, 2.2, -1.82), CREAM, "RepairSign")
	_box(station, Vector3(0.18, 1.2, 0.20), Vector3(0, 2.2, -1.95), Color("#74d0ad"), "WrenchIcon")
	_register_scenery(station)

func _add_city_landmark(z: float) -> void:
	var tower := Node3D.new()
	tower.position = Vector3(0, 0, z - 3.0)
	add_child(tower)
	_box(tower, Vector3(2.2, 12.0, 2.2), Vector3.ZERO, Color("#66728b"), "CityTower")
	_box(tower, Vector3(3.8, 0.28, 3.8), Vector3(0, 6.0, 0), CORAL, "TowerCap")
	for y in [2.0, 4.0, 8.0, 10.0]:
		_box(tower, Vector3(1.5, 0.5, 0.14), Vector3(0, y, -1.18), Color("#ffd166"), "TowerWindow")
	_register_scenery(tower)

func _add_city_intersection(z: float) -> void:
	for stripe in range(-4, 5):
		_box(self, Vector3(0.45, 0.025, 7.0), Vector3(float(stripe) * 0.65, 0.08, z), CREAM, "CrosswalkStripe")
	for side in [-1.0, 1.0]:
		var signal := Node3D.new()
		signal.position = Vector3(side * 6.9, 0, z - 2.0)
		add_child(signal)
		_box(signal, Vector3(0.18, 4.0, 0.18), Vector3(0, 2.0, 0), INK, "TrafficPole")
		var red := _box(signal, Vector3(0.42, 0.42, 0.25), Vector3(0, 4.2, 0), CORAL, "TrafficRed")
		var red_material := red.material_override as StandardMaterial3D
		red_material.emission_enabled = true
		red_material.emission = CORAL
		red_material.emission_energy_multiplier = 1.5

func _add_bridge(z: float) -> void:
	var bridge := Node3D.new()
	bridge.position = Vector3(0, 0, z)
	add_child(bridge)
	_box(bridge, Vector3(22.0, 0.6, 10.0), Vector3(0, -0.05, 0), Color("#66728b"), "BridgeDeck")
	for side in [-1.0, 1.0]:
		_box(bridge, Vector3(0.3, 1.6, 10.0), Vector3(side * 7.0, 0.9, 0), Color("#aeb8c5"), "BridgeRail")
		for pillar_z in [-3.0, 3.0]:
			_box(bridge, Vector3(0.45, 5.0, 0.45), Vector3(side * 5.5, -2.5, pillar_z), INK, "BridgePillar")
	_register_scenery(bridge)

func _add_village_farm(z: float) -> void:
	var farm := Node3D.new()
	farm.position = Vector3(-12.0, 0, z)
	add_child(farm)
	_box(farm, Vector3(8.0, 3.2, 7.0), Vector3.ZERO, Color("#f4b86b"), "FarmHouse")
	_box(farm, Vector3(8.5, 0.3, 7.5), Vector3(0, 1.9, 0), CORAL, "FarmRoof")
	for row in 4:
		_box(farm, Vector3(7.0, 0.08, 0.35), Vector3(0, 0.08, -4.0 + row * 2.0), Color("#c78c55"), "CropRow")
	_register_scenery(farm)
	var silo := Node3D.new()
	silo.position = Vector3(13.0, 1.5, z + 4.0)
	add_child(silo)
	_cylinder(silo, 1.6, 5.5, Vector3.ZERO, Color("#d5dded"), "Silo")
	_register_scenery(silo)

func _add_village_landmark(z: float) -> void:
	var mill := Node3D.new()
	mill.position = Vector3(11.5, 0, z - 3.0)
	add_child(mill)
	_box(mill, Vector3(1.4, 5.5, 1.4), Vector3(0, 2.75, 0), Color("#f4b86b"), "WindmillTower")
	for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
		var blade := _box(mill, Vector3(0.18, 3.4, 0.12), Vector3(0, 5.8, 0), CREAM, "WindmillBlade")
		blade.rotation_degrees.z = rad_to_deg(angle)
	_register_scenery(mill)

func _add_village_junction(z: float) -> void:
	_box(self, Vector3(8.0, 0.04, 0.55), Vector3(9.0, 0.04, z), Color("#4c9c79"), "FarmRoad")
	_box(self, Vector3(2.5, 0.65, 0.2), Vector3(9.0, 0.38, z - 1.2), CREAM, "FarmRoadSign")

func _add_deep_forest(z: float) -> void:
	for side in [-1.0, 1.0]:
		for tree_index in 3:
			_add_tree(Vector3(side * (9.5 + tree_index * 2.3), 0, z + tree_index * 2.5), 1.25)

func _add_forest_landmark(z: float) -> void:
	var boulder := Node3D.new()
	boulder.position = Vector3(-10.8, 0.9, z - 3.0)
	boulder.scale = Vector3(1.4, 0.8, 1.1)
	add_child(boulder)
	_cylinder(boulder, 1.4, 2.0, Vector3.ZERO, Color("#4a5268"), "ForestBoulder")
	var log := _box(self, Vector3(1.0, 0.8, 4.8), Vector3(11.0, 0.45, z + 2.0), Color("#78533c"), "FallenLog")
	log.rotation_degrees.y = 18.0

func _add_mountain_pass(z: float) -> void:
	for side in [-1.0, 1.0]:
		var cliff := Node3D.new()
		cliff.position = Vector3(side * 14.0, 3.5, z)
		cliff.scale = Vector3(1.0, 1.4 + fmod(abs(z), 3.0) * 0.15, 1.0)
		add_child(cliff)
		_cylinder(cliff, 5.0, 10.0, Vector3.ZERO, Color("#66728b"), "RockWall")
		_cylinder(cliff, 3.2, 0.4, Vector3(0, 5.2, 0), Color("#f5f2df"), "SnowEdge")
		_register_scenery(cliff)

func _add_mountain_landmark(z: float) -> void:
	var tunnel := Node3D.new()
	tunnel.position = Vector3(0, 0, z - 4.5)
	add_child(tunnel)
	_box(tunnel, Vector3(13.0, 5.5, 1.2), Vector3(0, 2.75, 0), Color("#38405b"), "TunnelFace")
	_box(tunnel, Vector3(7.0, 3.5, 1.4), Vector3(0, 1.4, -0.7), INK, "TunnelOpening")
	for x in [-4.0, -2.0, 0.0, 2.0, 4.0]:
		var lamp := _box(tunnel, Vector3(0.28, 0.28, 0.18), Vector3(x, 3.8, -1.0), Color("#fff0a7"), "TunnelLamp")
		var lamp_material := lamp.material_override as StandardMaterial3D
		lamp_material.emission_enabled = true
		lamp_material.emission = Color("#fff0a7")
		lamp_material.emission_energy_multiplier = 2.0
	_register_scenery(tunnel)

func _add_mountain_warning(z: float) -> void:
	for side in [-1.0, 1.0]:
		var sign := Node3D.new()
		sign.position = Vector3(side * 6.9, 0, z + 2.5)
		add_child(sign)
		_box(sign, Vector3(0.12, 2.0, 0.12), Vector3(0, 1.0, 0), INK, "WarningPost")
		_box(sign, Vector3(0.9, 0.65, 0.12), Vector3(0, 2.0, 0), Color("#ffd166"), "MountainWarning")

func _add_plain_field(z: float) -> void:
	for side in [-1.0, 1.0]:
		var field := Node3D.new()
		field.position = Vector3(side * 13.0, 0, z)
		add_child(field)
		_box(field, Vector3(10.0, 0.08, 9.0), Vector3.ZERO, Color("#d8b867"), "WheatField")
		for row in 5:
			_box(field, Vector3(0.12, 0.5, 7.5), Vector3(-4.0 + row * 2.0, 0.3, 0), Color("#a67c43"), "WheatRow")
		_register_scenery(field)

func _add_plain_landmark(z: float) -> void:
	var lake := _box(self, Vector3(15.0, 0.06, 7.0), Vector3(-14.0, 0.02, z), Color("#5fb5d0"), "PlainLake")
	var lake_material := lake.material_override as StandardMaterial3D
	lake_material.roughness = 0.12
	lake_material.metallic = 0.35
	for side in [-1.0, 1.0]:
		var turbine := Node3D.new()
		turbine.position = Vector3(side * 15.0, 0, z + 2.0)
		add_child(turbine)
		_box(turbine, Vector3(0.2, 7.0, 0.2), Vector3(0, 3.5, 0), Color("#d5dded"), "TurbinePole")
		for angle in [0.0, PI * 0.666, PI * 1.333]:
			var blade := _box(turbine, Vector3(0.12, 2.4, 0.1), Vector3(0, 7.0, 0), CREAM, "TurbineBlade")
			blade.rotation_degrees.z = rad_to_deg(angle)

func _add_mountain_cluster(pos: Vector3, scale_factor: float) -> void:
	var root := Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_factor
	add_child(root)
	var cone := _cone(root, 7.0, 18.0, Vector3(0, 8.8, 0), Color("#53617d"), "Mountain")
	var snow := _cone(root, 3.6, 5.0, Vector3(0, 17.2, 0), Color("#f5f2df"), "SnowCap")
	cone.rotation_degrees.y = 22.0
	snow.rotation_degrees.y = 22.0

func _add_tree(pos: Vector3, scale_factor: float) -> void:
	var tree := Node3D.new()
	tree.position = pos
	tree.scale = Vector3.ONE * scale_factor
	add_child(tree)
	_cylinder(tree, 0.25, 2.5, Vector3(0, 1.2, 0), Color("#6e4639"), "Trunk")
	_cone(tree, 2.2, 3.0, Vector3(0, 3.0, 0), Color("#4c9c79"), "Foliage")
	_cone(tree, 1.65, 2.5, Vector3(0, 4.7, 0), Color("#5bb691"), "FoliageMid")
	_cone(tree, 1.1, 2.0, Vector3(0, 6.1, 0), Color("#74d0ad"), "FoliageTop")

func _build_truck() -> void:
	truck = Node3D.new()
	truck.name = "PlayerTruck"
	truck.position = Vector3(0, 0.65, 95)
	add_child(truck)
	var trailer_body := _box(truck, Vector3(4.9, 2.25, 7.2), Vector3(0, 1.35, 0.9), CREAM, "Trailer")
	var trailer_stripe := _box(truck, Vector3(4.98, 0.36, 7.0), Vector3(0, 2.28, 0.9), CORAL, "TrailerStripe")
	var cab_body := _box(truck, Vector3(4.0, 2.7, 2.7), Vector3(0, 1.55, -3.25), Color("#ff9c65"), "Cab")
	truck_livery_parts.append(trailer_body)
	truck_livery_parts.append(trailer_stripe)
	truck_livery_parts.append(cab_body)
	_box(truck, Vector3(3.2, 1.0, 0.15), Vector3(0, 2.15, -4.65), Color("#9fe3ff"), "Windshield")
	_box(truck, Vector3(4.2, 0.18, 0.18), Vector3(0, 0.35, -4.7), INK, "FrontBumper")
	_box(truck, Vector3(3.5, 0.12, 0.22), Vector3(0, 2.55, -3.45), Color("#ffd166"), "AnimeRoofStripe")
	_box(truck, Vector3(0.55, 0.5, 0.22), Vector3(-1.5, 2.72, -3.55), CORAL, "RoofLamp")
	_box(truck, Vector3(0.55, 0.5, 0.22), Vector3(1.5, 2.72, -3.55), CORAL, "RoofLamp")
	var cargo_badge := _box(truck, Vector3(1.8, 0.8, 0.16), Vector3(0, 1.45, 4.52), Color("#ffcf5c"), "AnimeCargoBadge")
	truck_livery_parts.append(cargo_badge)
	_box(truck, Vector3(0.22, 1.4, 0.22), Vector3(-1.25, 3.1, -3.45), INK, "Antenna")
	_box(truck, Vector3(0.28, 0.62, 0.42), Vector3(-2.25, 1.85, -3.72), INK, "MirrorArm")
	_box(truck, Vector3(0.28, 0.62, 0.42), Vector3(2.25, 1.85, -3.72), INK, "MirrorArm")
	_box(truck, Vector3(1.8, 0.38, 0.16), Vector3(0, 0.86, -4.76), Color("#66728b"), "FrontGrille")
	for grille_y in [0.72, 0.84, 0.96]:
		_box(truck, Vector3(1.55, 0.05, 0.08), Vector3(0, grille_y, -4.86), INK, "GrilleSlat")
	for side in [-1.0, 1.0]:
		_box(truck, Vector3(0.12, 1.35, 1.55), Vector3(side * 2.03, 1.48, -3.3), INK, "CabOutline")
		_box(truck, Vector3(0.08, 0.72, 1.1), Vector3(side * 2.1, 1.58, -3.3), Color("#9fe3ff"), "CabSideWindow")
		_box(truck, Vector3(0.08, 0.08, 1.2), Vector3(side * 2.13, 0.9, -3.3), Color("#ffd166"), "CabStep")
		_box(truck, Vector3(0.16, 0.5, 2.8), Vector3(side * 2.56, 1.05, 0.75), INK, "TrailerSideOutline")
		_box(truck, Vector3(0.08, 0.3, 2.4), Vector3(side * 2.62, 1.2, 0.75), CORAL, "TrailerSideAccent")
	for trailer_z in [-1.8, 0.0, 1.8, 3.6]:
		_box(truck, Vector3(0.06, 1.45, 0.08), Vector3(-2.54, 1.25, trailer_z), INK, "TrailerPanelLine")
		_box(truck, Vector3(0.06, 1.45, 0.08), Vector3(2.54, 1.25, trailer_z), INK, "TrailerPanelLine")
	for bumper_x in [-1.4, 0.0, 1.4]:
		var bumper_lamp := _box(truck, Vector3(0.34, 0.16, 0.12), Vector3(bumper_x, 0.44, -4.9), Color("#fff0a7"), "BumperLamp")
		var bumper_material := bumper_lamp.material_override as StandardMaterial3D
		bumper_material.emission_enabled = true
		bumper_material.emission = Color("#fff0a7")
		bumper_material.emission_energy_multiplier = 2.0
	for x in [-2.1, 2.1]:
		var front_wheel := _cylinder(truck, 0.62, 0.42, Vector3(x, 0.62, -2.8), INK, "FrontWheel")
		front_wheel.rotation_degrees.z = 90.0
		wheel_nodes.append(front_wheel)
		var rear_wheel := _cylinder(truck, 0.62, 0.42, Vector3(x, 0.62, 2.5), INK, "RearWheel")
		rear_wheel.rotation_degrees.z = 90.0
		wheel_nodes.append(rear_wheel)
	for x in [-2.1, 2.1]:
		var front_hub := _cylinder(truck, 0.25, 0.44, Vector3(x, 0.62, -2.8), Color("#ffce68"), "Hub")
		front_hub.rotation_degrees.z = 90.0
		var rear_hub := _cylinder(truck, 0.25, 0.44, Vector3(x, 0.62, 2.5), Color("#ffce68"), "Hub")
		rear_hub.rotation_degrees.z = 90.0
	var exhaust := _cylinder(truck, 0.22, 0.9, Vector3(-1.55, 1.15, 4.65), INK, "ExhaustPipe")
	exhaust.rotation_degrees.x = 90.0
	exhaust_particles = _build_exhaust_particles()
	for lamp_x in [-1.6, 1.6]:
		var lamp := _box(truck, Vector3(0.3, 0.3, 0.2), Vector3(lamp_x, 1.8, -4.65), Color("#fff0a7"), "Lamp")
		var lamp_material := lamp.material_override as StandardMaterial3D
		lamp_material.emission_enabled = true
		lamp_material.emission = Color("#fff0a7")
		lamp_material.emission_energy_multiplier = 3.0
		var headlight := OmniLight3D.new()
		headlight.position = Vector3(lamp_x, 1.75, -5.1)
		headlight.light_color = Color("#fff0b2")
		headlight.light_energy = 0.0
		headlight.omni_range = 18.0
		headlight.shadow_enabled = false
			truck.add_child(headlight)
			headlight_nodes.append(headlight)
			var brake_lamp := _box(truck, Vector3(0.32, 0.26, 0.16), Vector3(lamp_x, 1.65, 4.58), CORAL, "BrakeLamp")
			brake_lamps.append(brake_lamp)
			var signal_lamp := _box(truck, Vector3(0.22, 0.22, 0.16), Vector3(lamp_x, 1.95, 4.58), Color("#ff9a42"), "SignalLamp")
			signal_lamps.append(signal_lamp)
	# Exterior refinement pass: door seams, handles, wheel arches, tanks and trailer hardware.
	for side in [-1.0, 1.0]:
		truck_detail_nodes.append(_box(truck, Vector3(0.07, 1.55, 0.08), Vector3(side * 2.08, 1.45, -3.18), INK, "CabDoorSeam"))
		truck_detail_nodes.append(_box(truck, Vector3(0.18, 0.08, 0.42), Vector3(side * 2.14, 1.85, -3.72), Color("#ffd166"), "CabDoorHandle"))
		truck_detail_nodes.append(_box(truck, Vector3(0.34, 0.18, 1.72), Vector3(side * 2.46, 0.78, -2.8), INK, "FrontMudguard"))
		truck_detail_nodes.append(_box(truck, Vector3(0.42, 0.52, 2.2), Vector3(side * 2.25, 0.62, 0.15), Color("#53617d"), "FuelTank"))
		truck_detail_nodes.append(_box(truck, Vector3(0.12, 0.16, 2.6), Vector3(side * 2.57, 1.25, 1.0), INK, "TrailerLatchRail"))
	for trailer_x in [-1.45, 1.45]:
		truck_detail_nodes.append(_box(truck, Vector3(0.12, 1.55, 0.12), Vector3(trailer_x, 1.25, 4.63), INK, "TrailerDoorLockBar"))
		truck_detail_nodes.append(_box(truck, Vector3(0.30, 0.18, 0.16), Vector3(trailer_x, 2.02, 4.62), Color("#ffd166"), "TrailerDoorHandle"))
	for side in [-1.0, 1.0]:
		var cargo_label := _label3d(truck, "MOUNTAIN TEA", Vector3(side * 2.57, 1.48, 0.9), CREAM, 26)
		cargo_label.rotation_degrees = Vector3(0, 90.0 if side < 0.0 else -90.0, 0)
		cargo_label.modulate = Color("#fff1cf")
		cargo_decal_labels.append(cargo_label)
		var badge_light := _box(truck, Vector3(0.06, 0.24, 0.65), Vector3(side * 2.63, 1.52, 0.9), Color("#ffd166"), "CargoBadgeLight")
		var badge_material := badge_light.material_override as StandardMaterial3D
		badge_material.emission_enabled = true
		badge_material.emission = Color("#ffd166")
		badge_material.emission_energy_multiplier = 0.0
		cargo_badge_lights.append(badge_light)
	for side in [-1.0, 1.0]:
		for trailer_z in [-2.8, -1.0, 0.8, 2.6, 4.1]:
			var reflector := _box(truck, Vector3(0.07, 0.20, 0.48), Vector3(side * 2.66, 0.82, trailer_z), Color("#ef6f61"), "TrailerReflector")
			var reflector_material := reflector.material_override as StandardMaterial3D
			reflector_material.emission_enabled = true
			reflector_material.emission = Color("#ef6f61")
			reflector_material.emission_energy_multiplier = 0.0
			safety_reflectors.append(reflector)
	for stripe_index in range(6):
		var warning_stripe := _box(truck, Vector3(0.34, 0.10, 0.08), Vector3(-1.1 + stripe_index * 0.44, 0.62, 4.72), Color("#ffd166" if stripe_index % 2 == 0 else CORAL), "RearWarningStripe")
		warning_stripe.rotation_degrees.y = 20.0 if stripe_index % 2 == 0 else -20.0
	var plate := _label3d(truck, "AH-2048", Vector3(0, 0.68, 4.82), CREAM, 18)
	plate.rotation_degrees = Vector3(0, 180, 0)
	_build_cockpit_interior()

func _label3d(parent: Node3D, text_value: String, pos: Vector3, color: Color, size: int = 32) -> Label3D:
	var label := Label3D.new()
	label.text = text_value
	label.position = pos
	label.modulate = color
	label.font_size = size
	label.outline_size = 8
	label.outline_modulate = INK
	label.pixel_size = 0.0028
	label.no_depth_test = true
	parent.add_child(label)
	return label

func _build_cockpit_interior() -> void:
	var cabin := Node3D.new()
	cabin.name = "DetailedCockpitInterior"
	truck.add_child(cabin)
	# Driver and passenger seats with headrests and colored piping.
	for side in [-1.0, 1.0]:
		_box(cabin, Vector3(1.25, 0.38, 1.1), Vector3(side * 0.9, 0.78, -2.0), Color("#39445e"), "SeatBase")
		_box(cabin, Vector3(1.15, 1.3, 0.42), Vector3(side * 0.9, 1.38, -2.22), Color("#53617d"), "SeatBack")
		_box(cabin, Vector3(0.82, 0.12, 0.08), Vector3(side * 0.9, 1.98, -2.42), CORAL, "SeatHeadrestTrim")
		_box(cabin, Vector3(0.12, 0.75, 0.12), Vector3(side * 1.55, 1.0, -1.92), INK, "SeatBelt")
	# Dashboard shell, instrument hood and central navigation console.
	_box(cabin, Vector3(3.65, 0.32, 0.95), Vector3(0, 1.65, -3.95), Color("#303950"), "Dashboard")
	_box(cabin, Vector3(3.15, 0.16, 0.32), Vector3(0, 1.88, -4.18), INK, "InstrumentHood")
	_box(cabin, Vector3(1.35, 0.58, 0.12), Vector3(0.75, 1.9, -4.22), Color("#1d263b"), "NavigationConsole")
	interior_nav_display = _label3d(cabin, "ROUTE AHEAD\nLUCERNE", Vector3(0.75, 1.94, -4.3), MINT, 24)
	interior_nav_display.rotation_degrees = Vector3(0, 180, 0)
	# Analog-style speed and fuel displays are readable in cockpit view.
	interior_speed_display = _label3d(cabin, "00 km/h", Vector3(-0.78, 1.93, -4.28), CREAM, 30)
	interior_speed_display.rotation_degrees = Vector3(0, 180, 0)
	interior_fuel_display = _label3d(cabin, "FUEL 78%", Vector3(-0.78, 1.67, -4.28), Color("#9fe3ff"), 20)
	interior_fuel_display.rotation_degrees = Vector3(0, 180, 0)
	interior_rpm_display = _label3d(cabin, "RPM 0800", Vector3(-0.78, 1.48, -4.28), Color("#ffd166"), 18)
	interior_rpm_display.rotation_degrees = Vector3(0, 180, 0)
	interior_gear_display = _label3d(cabin, "GEAR N", Vector3(0.76, 1.48, -4.28), CREAM, 18)
	interior_gear_display.rotation_degrees = Vector3(0, 180, 0)
	interior_indicator_display = _label3d(cabin, "○  LIGHTS", Vector3(0.76, 1.67, -4.28), Color("#9fe3ff"), 18)
	interior_indicator_display.rotation_degrees = Vector3(0, 180, 0)
	interior_warning_display = _label3d(cabin, "SYSTEMS OK", Vector3(0.0, 1.27, -4.28), MINT, 18)
	interior_warning_display.rotation_degrees = Vector3(0, 180, 0)
	# Steering wheel, center badge and two control stalks.
	interior_steering_wheel = _cylinder(cabin, 0.62, 0.12, Vector3(-1.0, 1.35, -3.6), INK, "InteriorSteeringWheel")
	interior_steering_wheel.rotation_degrees.x = 90.0
	_cylinder(cabin, 0.24, 0.14, Vector3(-1.0, 1.35, -3.68), Color("#66728b"), "SteeringHub").rotation_degrees.x = 90.0
	_box(cabin, Vector3(0.08, 0.52, 0.08), Vector3(-1.42, 1.48, -3.62), CORAL, "TurnSignalStalk")
	_box(cabin, Vector3(0.08, 0.52, 0.08), Vector3(-0.58, 1.48, -3.62), Color("#74d0ad"), "WiperStalk")
	# Functional mirror surfaces; their yaw is adjusted with steering in _process.
	for side in [-1.0, 1.0]:
		var mirror := _box(cabin, Vector3(0.72, 0.42, 0.08), Vector3(side * 2.0, 2.25, -3.55), Color("#74a9c4"), "InteriorMirror")
		var mirror_mesh := PlaneMesh.new()
		mirror_mesh.size = Vector2(0.72, 0.42)
		mirror.mesh = mirror_mesh
		mirror.rotation_degrees.x = 90.0
		mirror.rotation_degrees.y = side * 12.0
		var mirror_viewport := SubViewport.new()
		mirror_viewport.name = "MirrorViewport_%s" % ("L" if side < 0.0 else "R")
		mirror_viewport.size = Vector2i(256, 128)
		mirror_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		mirror_viewport.handle_input_locally = false
		mirror_viewport.world_3d = get_viewport().world_3d
		cabin.add_child(mirror_viewport)
		var mirror_camera := Camera3D.new()
		mirror_camera.name = "MirrorCamera"
		mirror_camera.fov = 62.0
		mirror_camera.near = 0.2
		mirror_camera.far = 90.0
		mirror_viewport.add_child(mirror_camera)
		mirror_camera.current = true
		var mirror_material := StandardMaterial3D.new()
		mirror_material.albedo_texture = mirror_viewport.get_texture()
		mirror_material.shading_mode = BaseMaterial3D.SHADING_UNSHADED
		mirror_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		mirror_material.roughness = 0.18
		mirror.material_override = mirror_material
		interior_mirrors.append(mirror)
		mirror_viewports.append(mirror_viewport)
		mirror_cameras.append(mirror_camera)
		_box(cabin, Vector3(0.10, 0.62, 0.10), Vector3(side * 1.72, 1.95, -3.48), INK, "MirrorMount")
	# Twin windshield wiper arms visibly sweep in rain and snow.
	for side in [-1.0, 1.0]:
		var wiper := _box(cabin, Vector3(0.10, 0.92, 0.08), Vector3(side * 0.86, 1.98, -4.48), INK, "WindshieldWiper")
		wiper.rotation_degrees.z = side * 18.0
		interior_wipers.append(wiper)
	# Warm cabin lamps are dimmed at daytime and brightened at night.
	for side in [-1.0, 1.0]:
		var lamp := _box(cabin, Vector3(0.22, 0.06, 0.16), Vector3(side * 0.8, 2.35, -1.7), Color("#ffd166"), "CabinLamp")
			var lamp_material := lamp.material_override as StandardMaterial3D
			lamp_material.emission_enabled = true
			lamp_material.emission = Color("#ffd166")
			interior_lamps.append(lamp)
	_apply_livery(cargo_index)

func _apply_livery(index: int) -> void:
	var liveries := [
		[Color("#ff9c65"), CORAL, Color("#ffcf5c")],
		[Color("#6f9fe8"), Color("#536fc2"), MINT],
		[Color("#6bbf91"), Color("#397a68"), Color("#ffd166")],
		[Color("#a88bd8"), Color("#6f5ca8"), Color("#9fe3ff")]
	]
	var palette: Array = liveries[abs(index) % liveries.size()]
	var livery_texture: Texture2D = ORANGE_LIVERY_TEXTURE if abs(index) % 2 == 0 else BLUE_LIVERY_TEXTURE
	for part_index in truck_livery_parts.size():
		var part_material := truck_livery_parts[part_index].material_override as StandardMaterial3D
		part_material.albedo_color = palette[part_index % palette.size()]
		part_material.albedo_texture = livery_texture if part_index < 2 else null
		part_material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	var cargo_names := ["MOUNTAIN TEA", "STRAWBERRY JAM", "ALPINE PARTS"]
	for label in cargo_decal_labels:
		label.text = cargo_names[abs(index) % cargo_names.size()]
	for badge_light in cargo_badge_lights:
		var badge_material := badge_light.material_override as StandardMaterial3D
		badge_material.albedo_color = palette[2]
		badge_material.emission = palette[2]
	if interior_nav_display:
		interior_nav_display.modulate = palette[2]

func _build_exhaust_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "ExhaustSmoke"
	particles.amount = 18
	particles.lifetime = 1.8
	particles.emitting = true
	var process_material := ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, 1, 1)
	process_material.initial_velocity_min = 0.25
	process_material.initial_velocity_max = 0.7
	process_material.gravity = Vector3(0, 0.15, 0)
	process_material.scale_min = 0.08
	process_material.scale_max = 0.18
	process_material.color = Color(0.55, 0.58, 0.64, 0.28)
	particles.process_material = process_material
	var quad := QuadMesh.new()
	quad.size = Vector2(0.22, 0.22)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.55, 0.58, 0.64, 0.28)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = material
	particles.draw_pass_1 = quad
	particles.position = Vector3(-1.55, 1.65, 4.7)
	truck.add_child(particles)
	return particles

func _build_traffic() -> void:
	for i in traffic_types.size():
		var car := Node3D.new()
		car.name = "Traffic_%d" % i
		car.position = Vector3(traffic_lanes[i], 0.55, truck.position.z - 24.0 - float(i) * 28.0)
		add_child(car)
		var body_size := Vector3(2.5, 1.15, 4.2)
		if traffic_types[i] == "van" or traffic_types[i] == "service":
			body_size = Vector3(2.65, 1.7, 5.0)
		elif traffic_types[i] == "bus" or traffic_types[i] == "coach":
			body_size = Vector3(3.0, 2.5, 7.0)
		elif traffic_types[i] == "wagon":
			body_size = Vector3(2.55, 1.35, 4.8)
		var traffic_colors := [MINT, Color("#f4b86b"), Color("#bb86fc"), Color("#ef6f61"), Color("#9fe3ff"), Color("#ffd166")]
		_box(car, body_size, Vector3.ZERO, traffic_colors[i], "Body")
		_box(car, Vector3(body_size.x * 0.72, body_size.y * 0.52, 1.2), Vector3(0, body_size.y * 0.48, -body_size.z * 0.16), Color("#9fe3ff"), "Glass")
		_cylinder(car, 0.36, body_size.x * 0.82, Vector3(-body_size.x * 0.40, 0, -body_size.z * 0.25), INK, "Wheel")
		_cylinder(car, 0.36, body_size.x * 0.82, Vector3(body_size.x * 0.40, 0, -body_size.z * 0.25), INK, "Wheel")
		var tail_lamp := _box(car, Vector3(0.30, 0.24, 0.12), Vector3(-body_size.x * 0.32, body_size.y * 0.12, body_size.z * 0.5), CORAL, "TrafficTailLamp")
		var tail_material := tail_lamp.material_override as StandardMaterial3D
		tail_material.emission_enabled = true
		tail_material.emission = CORAL
		tail_material.emission_energy_multiplier = 1.6
		traffic_lights.append(tail_lamp)
		traffic_tail_lamps.append(tail_lamp)
		var head_lamp := _box(car, Vector3(0.30, 0.24, 0.12), Vector3(body_size.x * 0.32, body_size.y * 0.12, -body_size.z * 0.5), Color("#fff0a7"), "TrafficHeadLamp")
		var head_material := head_lamp.material_override as StandardMaterial3D
		head_material.emission_enabled = true
		head_material.emission = Color("#fff0a7")
		head_material.emission_energy_multiplier = 1.8
		traffic_lights.append(head_lamp)
		traffic.append(car)
		FreeAssetCatalog.add_lod_visibility(car, 45.0, 130.0)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 7.6, 15.0)
	camera.rotation_degrees = Vector3(-17, 180, 0)
	camera.near = 0.1
	camera.far = 155.0
	camera.current = true
	add_child(camera)
	camera_look_target = truck.global_position + Vector3(0, 1.2, -5.0)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	var top := ColorRect.new()
	top.color = Color(INK, 0.0)
	top.size = Vector2(1, 1)
	layer.add_child(top)
	_hud_card(layer, Vector2(330, 22), Vector2(292, 112), Color("#211c37", 0.92))
	_hud_card(layer, Vector2(970, 22), Vector2(112, 92), Color("#211c37", 0.94))
	_hud_card(layer, Vector2(1090, 22), Vector2(166, 92), Color("#211c37", 0.94))
	_hud_card(layer, Vector2(970, 124), Vector2(286, 70), Color("#211c37", 0.90))
	_hud_icon(layer, UI_ROUTE_TEXTURE, Vector2(332, 42), Vector2(28, 28))
	_hud_icon(layer, UI_FUEL_TEXTURE, Vector2(978, 70), Vector2(24, 24))
	_hud_icon(layer, UI_WEATHER_TEXTURE, Vector2(1100, 70), Vector2(24, 24))
	ui_route = _label(layer, Vector2(350, 40), 18, CREAM)
	ui_route.size = Vector2(252, 82)
	ui_route.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_speed = _label(layer, Vector2(988, 34), 34, CREAM)
	ui_speed.size = Vector2(76, 56)
	ui_speed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_stats = _label(layer, Vector2(990, 137), 14, Color("#c0cde4"))
	ui_stats.size = Vector2(260, 48)
	ui_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_toast = _label(layer, Vector2(470, 145), 20, CREAM)
	ui_toast.size = Vector2(340, 44)
	ui_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minimap = Control.new()
	minimap.name = "RouteMinimap"
	minimap.position = Vector2(24, 22)
	minimap.size = Vector2(292, 190)
	minimap.set_script(load("res://scripts/minimap.gd"))
	layer.add_child(minimap)
	var hint := _label(layer, Vector2(330, 148), 13, Color("#d5dded"))
	hint.text = "触摸驾驶  •  左右变道  •  避开交通  •  到达目的地交付"
	virtual_controls = Control.new()
	virtual_controls.name = "AnalogDrivingControls"
	virtual_controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	virtual_controls.mouse_filter = Control.MOUSE_FILTER_STOP
	virtual_controls.set_script(load("res://scripts/virtual_controls.gd"))
	virtual_controls.steering_changed.connect(_on_touch_steering)
	virtual_controls.throttle_changed.connect(_on_touch_throttle)
	virtual_controls.brake_changed.connect(_on_touch_brake)
	layer.add_child(virtual_controls)
	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.position = Vector2(1197, 18)
	pause_button.size = Vector2(52, 52)
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.add_theme_font_size_override("font_size", 23)
	_style_ui_button(pause_button)
	pause_button.pressed.connect(_toggle_pause)
	layer.add_child(pause_button)
	var camera_button := Button.new()
	camera_button.text = "视角"
	camera_button.position = Vector2(1118, 18)
	camera_button.size = Vector2(70, 52)
	camera_button.process_mode = Node.PROCESS_MODE_ALWAYS
	camera_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(camera_button)
	camera_button.pressed.connect(_toggle_camera_mode)
	layer.add_child(camera_button)
	var garage_button := Button.new()
	garage_button.text = "车库"
	garage_button.position = Vector2(1035, 18)
	garage_button.size = Vector2(72, 52)
	garage_button.process_mode = Node.PROCESS_MODE_ALWAYS
	garage_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(garage_button)
	garage_button.pressed.connect(_toggle_garage)
	layer.add_child(garage_button)
	var settings_button := Button.new()
	settings_button.text = "设置"
	settings_button.position = Vector2(950, 18)
	settings_button.size = Vector2(72, 52)
	settings_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(settings_button)
	settings_button.pressed.connect(_toggle_settings)
	layer.add_child(settings_button)
	_build_garage_panel(layer)
	_build_settings_panel(layer)
	_update_ui()

func _style_ui_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", INK)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#3d4764", 0.96)
	normal.border_color = Color("#66789d", 0.9)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(12)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color("#ffd166", 0.96)
	button.add_theme_stylebox_override("hover", hover)

func _hud_card(layer: CanvasLayer, pos: Vector2, card_size: Vector2, color: Color) -> Panel:
	var card := Panel.new()
	card.position = pos
	card.size = card_size
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#52617e", 0.72)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	card.add_theme_stylebox_override("panel", style)
	layer.add_child(card)
	return card

func _hud_icon(layer: CanvasLayer, texture: Texture2D, pos: Vector2, icon_size: Vector2) -> void:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.position = pos
	icon.size = icon_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(icon)

func _build_settings_panel(layer: CanvasLayer) -> void:
	settings_panel = Panel.new()
	settings_panel.position = Vector2(760, 112)
	settings_panel.size = Vector2(370, 290)
	settings_panel.visible = false
	settings_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_panel.set_script(load("res://scripts/settings_panel.gd"))
	settings_panel.quality_selected.connect(_apply_quality)
	settings_panel.sensitivity_changed.connect(_apply_sensitivity)
	settings_panel.volume_changed.connect(_apply_volume)
	settings_panel.closed.connect(_toggle_settings)
	layer.add_child(settings_panel)
	settings_panel.quality_mode = quality_mode
	settings_panel.sensitivity = steering_sensitivity
	settings_panel.volume = master_volume

func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible

func _apply_quality(mode: int) -> void:
	quality_mode = mode
	var ratios := [0.45, 0.72, 1.0]
	rain_particles.amount_ratio = ratios[mode]
	snow_particles.amount_ratio = ratios[mode]
	camera.far = [95.0, 125.0, 155.0][mode]
	sun.shadow_enabled = mode >= 1
	moon.shadow_enabled = false
	mirrors_enabled = mode >= 1
	for mirror_viewport in mirror_viewports:
		mirror_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED if mode == 0 else (SubViewport.UPDATE_WHEN_VISIBLE if mode == 1 else SubViewport.UPDATE_ALWAYS)
	for chunk in stream_chunks.values():
		FreeAssetCatalog.add_lod_visibility(chunk, [35.0, 50.0, 70.0][mode], [80.0, 115.0, 145.0][mode])
	_save_game()

func _apply_sensitivity(value: float) -> void:
	steering_sensitivity = value
	if virtual_controls:
		virtual_controls.sensitivity = value
	_save_game()

func _apply_volume(value: float) -> void:
	master_volume = value
	for player in [engine_player, brake_player, rain_player, wind_player, wet_tire_player, snow_tire_player, thunder_player]:
		if player:
			player.volume_db = linear_to_db(max(master_volume, 0.001))
	_save_game()

func _build_garage_panel(layer: CanvasLayer) -> void:
	garage_panel = Panel.new()
	garage_panel.position = Vector2(850, 112)
	garage_panel.size = Vector2(390, 300)
	garage_panel.visible = false
	garage_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var garage_style := StyleBoxFlat.new()
	garage_style.bg_color = Color("#211c37", 0.96)
	garage_style.border_color = Color("#52617e", 0.9)
	garage_style.set_border_width_all(2)
	garage_style.set_corner_radius_all(18)
	garage_panel.add_theme_stylebox_override("panel", garage_style)
	layer.add_child(garage_panel)
	garage_label = Label.new()
	garage_label.position = Vector2(20, 16)
	garage_label.size = Vector2(350, 42)
	garage_label.add_theme_font_size_override("font_size", 18)
	garage_label.add_theme_color_override("font_color", CREAM)
	garage_label.add_theme_color_override("font_shadow_color", Color("#0d1020", 0.85))
	garage_label.add_theme_constant_override("shadow_offset_x", 2)
	garage_label.add_theme_constant_override("shadow_offset_y", 2)
	garage_panel.add_child(garage_label)
	var upgrades := ["发动机", "轮胎", "油箱", "装甲"]
	for i in upgrades.size():
		var button := Button.new()
		button.text = upgrades[i] + "升级  €" + str(500 + i * 150)
		button.position = Vector2(18, 68 + i * 50)
		button.size = Vector2(350, 40)
		button.add_theme_font_size_override("font_size", 16)
		_style_ui_button(button)
		var upgrade_id := ["engine", "tire", "tank", "armor"][i]
		button.pressed.connect(func(): _buy_upgrade(upgrade_id))
		garage_panel.add_child(button)
	_update_garage_label()

func _toggle_garage() -> void:
	garage_panel.visible = not garage_panel.visible
	_update_garage_label()

func _update_garage_label() -> void:
	if garage_label:
		garage_label.text = "车库升级   € %d\n发动机 %d   轮胎 %d   油箱 %d   装甲 %d" % [money, engine_level, tire_level, tank_level, armor_level]

func _buy_upgrade(upgrade_id: String) -> void:
	var price := {"engine": 500, "tire": 650, "tank": 800, "armor": 950}.get(upgrade_id, 9999)
	if money < price:
		toast = "运费不足"
	else:
		money -= price
		match upgrade_id:
			"engine": engine_level += 1
			"tire": tire_level += 1
			"tank": tank_level += 1
			"armor": armor_level += 1
			toast = "升级完成：" + upgrade_id
			toast_time = 2.0
			_save_game()
			_haptic(80, 0.45)
	_update_garage_label()

func _label(layer: CanvasLayer, pos: Vector2, size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	layer.add_child(label)
	return label

func _add_button(layer: CanvasLayer, text: String, pos: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(88, 78)
	button.add_theme_font_size_override("font_size", 30)
	_style_ui_button(button)
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))
	layer.add_child(button)

func _on_touch_steering(value: float) -> void:
	touch_steer = value

func _on_touch_throttle(value: float) -> void:
	touch_throttle = value

func _on_touch_brake(value: float) -> void:
	touch_brake = value

func _build_audio() -> void:
	engine_player = AudioStreamPlayer.new()
	engine_player.stream = load("res://audio/engine_loop.wav")
	engine_player.volume_db = -10.0
	add_child(engine_player)
	engine_player.play()
	brake_player = AudioStreamPlayer.new()
	brake_player.stream = load("res://audio/air_brake.wav")
	brake_player.volume_db = -4.0
	add_child(brake_player)
	rain_player = _loop_audio("res://audio/rain_ambient.wav", -28.0)
	wind_player = _loop_audio("res://audio/wind_ambient.wav", -24.0)
	wet_tire_player = _loop_audio("res://audio/tire_wet.wav", -32.0)
	snow_tire_player = _loop_audio("res://audio/tire_snow.wav", -32.0)
	thunder_player = AudioStreamPlayer.new()
	thunder_player.stream = load("res://audio/thunder_rumble.wav")
	thunder_player.volume_db = -9.0
	add_child(thunder_player)

func _loop_audio(path: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := load(path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	player.stream = stream
	player.volume_db = volume
	add_child(player)
	player.play()
	return player

func _process(delta: float) -> void:
	if paused:
		return
	save_timer += delta
	if save_timer >= 10.0:
		save_timer = 0.0
		_save_game()
	game_hour = fmod(game_hour + 24.0 * delta / day_length_seconds, 24.0)
	var keyboard_throttle := Input.get_action_strength("accelerate")
	var keyboard_brake := Input.get_action_strength("brake")
	var keyboard_steer := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var throttle := max(keyboard_throttle, touch_throttle)
	var braking := max(keyboard_brake, touch_brake)
	var steer_input := touch_steer if abs(touch_steer) > 0.01 else keyboard_steer
	steer = lerp(steer, steer_input, delta * 7.0)
	var max_speed := 21.0 + float(engine_level) * 2.5
	slope_percent = clamp((_road_height_at(truck.position.z - 8.0) - _road_height_at(truck.position.z)) / 8.0 * 100.0, -18.0, 18.0)
	var slope_drag := slope_percent * 0.055
	var target_speed := throttle * max_speed - braking * (12.0 + float(tire_level) * 0.8) - slope_drag
	speed = lerp(speed, max(target_speed, 0.0), delta * 3.8)
	var steering_grip := 1.0 + float(tire_level) * 0.08
	var road_center := _road_center_at(truck.position.z)
	truck.position.x = clamp(truck.position.x + steer * delta * 6.4 * steering_grip + (road_center - truck.position.x) * delta * 0.38, road_center - 4.0, road_center + 4.0)
	truck.position.y = 0.65 + _road_height_at(truck.position.z)
	var road_pitch := atan2(_road_height_at(truck.position.z - 8.0) - _road_height_at(truck.position.z), 8.0)
	var brake_glow := 1.0 if braking > 0.15 else 0.35
	for lamp in brake_lamps:
		var brake_material := lamp.material_override as StandardMaterial3D
		brake_material.emission_enabled = true
		brake_material.emission = CORAL
		brake_material.emission_energy_multiplier = brake_glow * 2.8
	var signal_on := abs(steer) > 0.14 and fmod(Time.get_ticks_msec() / 1000.0, 0.65) < 0.32
	for lamp in signal_lamps:
		lamp.visible = signal_on
	if exhaust_particles:
		exhaust_particles.amount_ratio = clamp(0.18 + throttle * 0.72, 0.18, 1.0)
	truck.rotation.z = lerp(truck.rotation.z, -steer * 0.075, delta * 8.0)
	truck.rotation.x = lerp(truck.rotation.x, -road_pitch + sin(Time.get_ticks_msec() * 0.006) * speed * 0.0018, delta * 4.0)
	if engine_player:
		var engine_load := clamp(throttle + max(0.0, slope_percent) * 0.035, 0.0, 1.0)
		engine_player.pitch_scale = 0.82 + speed / max(max_speed, 1.0) * 0.32 + engine_load * 0.16
		engine_player.volume_db = -12.0 + engine_load * 4.0
	for wheel in wheel_nodes:
		wheel.rotation.x -= speed * delta * 1.8
	distance += speed * delta * 0.016
	truck.position.z -= speed * delta * 0.7
	_update_streaming()
	_update_refueling(delta)
	_update_repairing(delta)
	var fuel_capacity := 100.0 + float(tank_level) * 10.0
	fuel = max(0.0, fuel - speed * delta * 0.0014)
	time_left = max(0.0, time_left - delta)
	thunder_cooldown -= delta
	if braking > 0.2 and speed > 2.0 and not brake_player.playing:
		brake_player.play()
		for i in traffic.size():
			var car := traffic[i]
			var traffic_factor := traffic_speeds[i]
				if current_scene.find("城市") >= 0 and _near_signal_intersection(car.position.z) and _signal_is_red(car.position.z):
					traffic_factor = 0.08
				var traffic_braking := traffic_factor < 0.45
				var traffic_tail_material := traffic_tail_lamps[i].material_override as StandardMaterial3D
				traffic_tail_material.emission_energy_multiplier = 2.8 if traffic_braking else 1.1
				car.position.z += speed * delta * 0.7 * traffic_factor
			var car_center := _road_center_at(car.position.z)
			var car_target_x := car_center + traffic_lanes[i]
			car.position.x = lerp(car.position.x, car_target_x, delta * 5.0)
			car.position.y = 0.55 + _road_height_at(car.position.z)
			car.rotation.y = atan2(_road_center_at(car.position.z - 8.0) - car_center, 8.0)
			car.rotation.x = -atan2(_road_height_at(car.position.z - 8.0) - _road_height_at(car.position.z), 8.0)
			if car.position.z > truck.position.z + 22.0:
				car.position.z = truck.position.z - 100.0 - float(i) * 20.0
				car.position.x = _road_center_at(car.position.z) + traffic_lanes[i]
			if abs(car.position.x - truck.position.x) < 2.5 and abs(car.position.z - truck.position.z) < 4.0 and speed > 11.0:
				damage = min(100.0, damage + max(5.0, 16.0 - float(armor_level) * 3.0))
				speed *= 0.45
				hit_shake = 0.9
				toast = "轻微碰撞！请注意车距"
				toast_time = 2.2
				_haptic(130, 0.75)
	if distance >= route_goal:
		_complete_delivery()
	toast_time = max(0.0, toast_time - delta)
	_update_camera(delta)
	_update_scene_name()
	_update_signal_visuals()
	_update_day_night()
	_update_weather_visuals()
	_update_weather_audio(delta)
	_update_cockpit_instruments(delta)
	_update_ui()

func _update_day_night() -> void:
	var sun_angle := (game_hour - 6.0) / 24.0 * 360.0
	var daylight := clamp(sin((game_hour - 6.0) / 12.0 * PI), 0.0, 1.0)
	sun.rotation_degrees = Vector3(sun_angle - 90.0, -28.0, 0.0)
	sun.light_energy = lerp(0.04, 1.25, daylight)
	sun.light_color = Color(1.0, lerp(0.52, 0.95, daylight), lerp(0.40, 0.82, daylight))
	sun.shadow_enabled = daylight > 0.12
	moon.rotation_degrees = Vector3(sun_angle + 180.0, 150.0, 0.0)
	moon.light_energy = lerp(0.24, 0.0, daylight)
	var night := 1.0 - daylight
	environment.ambient_light_energy = lerp(0.16, 0.82, daylight)
	if game_hour >= 5.0 and game_hour < 8.0:
		environment.background_color = Color("#e1a77f").lerp(Color("#86d6e8"), (game_hour - 5.0) / 3.0)
	elif game_hour >= 17.0 and game_hour < 20.0:
		environment.background_color = Color("#86d6e8").lerp(Color("#e38769"), (game_hour - 17.0) / 3.0)
	elif daylight <= 0.02:
		environment.background_color = Color("#111b39")
	else:
		environment.background_color = Color("#86d6e8")
	var sky_top := Color("#4b78c2")
	var sky_horizon := Color("#86d6e8")
	var ground_horizon := Color("#9bb07f")
	if game_hour >= 5.0 and game_hour < 8.0:
		sky_top = Color("#bd7891")
		sky_horizon = Color("#f3b181")
	elif game_hour >= 17.0 and game_hour < 20.0:
		sky_top = Color("#8b5e9e")
		sky_horizon = Color("#ef916c")
	elif daylight <= 0.02:
		sky_top = Color("#0d1631")
		sky_horizon = Color("#273b66")
		ground_horizon = Color("#263047")
	sky_material.sky_top_color = sky_material.sky_top_color.lerp(sky_top, 0.08)
	sky_material.sky_horizon_color = sky_material.sky_horizon_color.lerp(sky_horizon, 0.08)
	sky_material.ground_horizon_color = sky_material.ground_horizon_color.lerp(ground_horizon, 0.08)
	# Snow reflects more moonlight; forest remains intentionally darker at night.
	if current_scene == "山区雪岭":
		environment.ambient_light_energy += night * 0.12
	elif current_scene == "深山老林":
		environment.ambient_light_energy -= night * 0.08
	for city_light in city_lights:
		city_light.light_energy = clamp((1.0 - daylight) * 1.8, 0.0, 1.8) if current_scene == "动漫城市" else 0.0
	for headlight in headlight_nodes:
		headlight.light_energy = clamp((1.0 - daylight) * 2.8, 0.0, 2.8)
	for traffic_lamp in traffic_lights:
		var traffic_material := traffic_lamp.material_override as StandardMaterial3D
		traffic_material.emission_energy_multiplier = lerp(0.8, 2.2, 1.0 - daylight)

func _update_weather_visuals() -> void:
	var rain_strength := weather_intensity if current_weather == "rain" else 0.0
	var snow_strength := weather_intensity if current_weather == "snow" else 0.0
	rain_particles.emitting = rain_strength > 0.02
	snow_particles.emitting = snow_strength > 0.02
	rain_particles.amount_ratio = rain_strength
	snow_particles.amount_ratio = snow_strength
	var base_fog := 0.008
	if current_scene == "深山老林":
		base_fog = 0.038
	elif current_scene == "山区雪岭":
		base_fog = 0.022
	elif current_scene == "动漫城市":
		base_fog = 0.010
	if current_weather == "rain":
		base_fog += weather_intensity * 0.012
	elif current_weather == "snow":
		base_fog += weather_intensity * 0.018
	environment.fog_density = lerp(environment.fog_density, base_fog, 0.08)
	var road_material := road_surface.material_override as StandardMaterial3D
	if current_weather == "rain":
		road_material.albedo_texture = ROAD_WET_TEXTURE
		road_material.albedo_color = road_material.albedo_color.lerp(Color("#29364d"), 0.12)
		road_material.roughness = lerp(road_material.roughness, 0.18, 0.08)
		road_material.metallic = lerp(road_material.metallic, 0.22, 0.08)
	elif current_weather == "snow":
		road_material.albedo_texture = ROAD_SNOW_TEXTURE
		road_material.albedo_color = road_material.albedo_color.lerp(Color("#8d9caf"), 0.10)
		road_material.roughness = lerp(road_material.roughness, 0.68, 0.08)
		road_material.metallic = lerp(road_material.metallic, 0.04, 0.08)
	else:
		road_material.albedo_texture = ROAD_CLEAR_TEXTURE
		road_material.albedo_color = road_material.albedo_color.lerp(ASPHALT, 0.08)
		road_material.roughness = lerp(road_material.roughness, 0.82, 0.08)
		road_material.metallic = lerp(road_material.metallic, 0.0, 0.08)
	for puddle in road_puddles:
		puddle.visible = current_weather == "rain"
	if current_weather == "rain" and weather_intensity > 0.5 and thunder_cooldown <= 0.0 and not thunder_player.playing:
		lightning_light.light_energy = 6.0
		var flash := create_tween()
		flash.tween_property(lightning_light, "light_energy", 0.0, 0.16)

func _format_clock() -> String:
	return "%02d:%02d" % [int(game_hour), int((game_hour - int(game_hour)) * 60.0)]

func _update_weather_audio(delta: float) -> void:
	# Weather is biome-driven for the prototype; later it can be replaced by a forecast manager.
	if current_scene == "山区雪岭":
		current_weather = "snow"
		weather_intensity = 0.78
	elif current_scene == "深山老林":
		current_weather = "rain"
		weather_intensity = 0.62
	elif current_scene == "动漫城市" and int(distance) % 3 == 0:
		current_weather = "rain"
		weather_intensity = 0.38
	else:
		current_weather = "clear"
		weather_intensity = 0.0
	var speed_factor := clamp(speed / 21.0, 0.0, 1.0)
	var master_db := linear_to_db(max(master_volume, 0.001))
	rain_player.volume_db = master_db + lerp(-42.0, -12.0, weather_intensity)
	wind_player.volume_db = master_db + lerp(-30.0, -18.0, 0.35 + speed_factor * 0.65)
	wet_tire_player.volume_db = master_db + (-38.0 if current_weather != "rain" else lerp(-34.0, -9.0, speed_factor * weather_intensity))
	snow_tire_player.volume_db = master_db + (-38.0 if current_weather != "snow" else lerp(-34.0, -8.0, speed_factor * weather_intensity))
	if current_weather == "rain" and weather_intensity > 0.5 and thunder_cooldown <= 0.0 and not thunder_player.playing:
		thunder_player.play()
		thunder_cooldown = 24.0 + randf() * 20.0

func _update_refueling(delta: float) -> void:
	var near_station := false
	for station_pos in station_positions:
		if truck.global_position.distance_to(station_pos) < 8.0:
			near_station = true
			break
	var can_refuel := near_station and speed < 1.5 and fuel < 99.5
	if can_refuel:
		var fuel_capacity := 100.0 + float(tank_level) * 10.0
		fuel = min(fuel_capacity, fuel + delta * 9.0)
		if not refueling:
			toast = "PARKED AT FUEL STATION"
			toast_time = 2.5
			_haptic(55, 0.25)
		refueling = true
	else:
		refueling = false

func _update_repairing(delta: float) -> void:
	var near_repair := false
	for station_pos in repair_positions:
		if truck.global_position.distance_to(station_pos) < 8.0:
			near_repair = true
			break
	var can_repair := near_repair and speed < 1.5 and damage > 0.5
	if can_repair and money >= 80:
		var repair_amount := min(damage, delta * 12.0)
		damage -= repair_amount
		money = max(0, money - int(ceil(repair_amount * 5.0)))
		if not repairing:
			toast = "REPAIRING TRUCK"
			toast_time = 2.5
			_haptic(70, 0.3)
		repairing = true
	elif not can_repair or money < 80:
		if can_repair and money < 80 and not repairing:
			toast = "维修费用不足"
			toast_time = 2.0
		repairing = false

func _update_scene_name() -> void:
	var z := truck.position.z
	if z < -120.0:
		var chunk_index := int(floor((-z - 120.0) / CHUNK_LENGTH))
		var macro_region := int(floor(float(chunk_index) / 50.0))
		var macro_name := ["动漫城市新区", "乡村湖区", "深林国家公园", "高山雪谷", "金色平原"][macro_region % 5]
		if macro_region % 5 == 0:
			current_scene = ["动漫城市·市中心", "动漫城市·住宅区", "动漫城市·工业区", "动漫城市·外环"][chunk_index % 4]
		elif macro_region % 5 == 1:
			current_scene = ["乡村·农田", "乡村·村庄", "乡村·河谷", "乡村·果园"][chunk_index % 4]
		elif macro_region % 5 == 2:
			current_scene = ["森林·针叶林", "森林·雨林", "森林·湖畔林", "森林·峡谷林"][chunk_index % 4]
		elif macro_region % 5 == 3:
			current_scene = ["雪山·冰川山口", "雪山·雪松山林", "雪山·矿区山路", "雪山·隧道群"][chunk_index % 4]
		elif macro_region % 5 == 4:
			current_scene = ["平原·麦田高速", "平原·湖岸湿地", "平原·风电走廊", "平原·太阳能产业区"][chunk_index % 4]
		else:
			current_scene = macro_name
	elif z > 70.0:
		current_scene = "开阔平原"
	elif z > 26.0:
		current_scene = "山区雪岭"
	elif z > -26.0:
		current_scene = "深山老林"
	elif z > -70.0:
		current_scene = "乡村田园"
	else:
		current_scene = "动漫城市"

func _update_camera(delta: float) -> void:
	var speed_zoom := clamp(speed / 21.0, 0.0, 1.0)
	var target: Vector3
	var look_target: Vector3
	if cockpit_mode:
		target = truck.global_position + Vector3(0, 2.65, -3.55)
		look_target = truck.global_position + Vector3(steer * 2.0, 2.45, -18.0)
		camera.fov = lerp(camera.fov, 70.0 + speed_zoom * 5.0, delta * 3.0)
	else:
		target = truck.global_position + Vector3(0, 5.2, 11.5)
		target.z += speed_zoom * 2.2
		look_target = truck.global_position + Vector3(0, 1.2, -5.0)
		camera.fov = lerp(camera.fov, 58.0 + speed_zoom * 7.0, delta * 3.0)
	hit_shake = move_toward(hit_shake, 0.0, delta * 2.8)
	var shake := Vector3(sin(Time.get_ticks_msec() * 0.08), cos(Time.get_ticks_msec() * 0.11), 0) * hit_shake * 0.22
	target += shake
	camera.global_position = camera.global_position.lerp(target, delta * 3.5)
	camera_look_target = camera_look_target.lerp(look_target, delta * 5.5)
	camera.look_at(camera_look_target, Vector3.UP)

func _update_cockpit_instruments(delta: float) -> void:
	if not interior_steering_wheel:
		return
	interior_steering_wheel.rotation_degrees.x = 90.0
	interior_steering_wheel.rotation_degrees.y = steer * 28.0
	if interior_speed_display:
		interior_speed_display.text = "%02d km/h" % int(speed * 4.4)
	if interior_fuel_display:
		interior_fuel_display.text = "FUEL %02d%%" % int(fuel)
	if interior_rpm_display:
		interior_rpm_display.text = "RPM %04d" % int(800.0 + speed * 115.0 + abs(slope_percent) * 35.0)
	if interior_gear_display:
		var gear := 0 if speed < 0.35 else clamp(int(speed / 3.2) + 1, 1, 12)
		interior_gear_display.text = "GEAR N" if gear == 0 else "GEAR %02d" % gear
	if interior_indicator_display:
		var indicator_on := fmod(Time.get_ticks_msec() / 1000.0, 0.65) < 0.32
		var direction := "L" if steer < -0.14 else ("R" if steer > 0.14 else "○")
		var night_lights := game_hour < 6.0 or game_hour >= 19.0
		interior_indicator_display.text = "%s  %s" % [direction if indicator_on else "○", "LIGHTS ON" if night_lights else "LIGHTS"]
	if interior_warning_display:
		if damage >= 70.0:
			interior_warning_display.text = "DAMAGE HIGH"
			interior_warning_display.modulate = CORAL
		elif fuel <= 18.0:
			interior_warning_display.text = "FUEL LOW"
			interior_warning_display.modulate = Color("#ffd166")
		else:
			interior_warning_display.text = "SYSTEMS OK"
			interior_warning_display.modulate = MINT
	if interior_nav_display:
		interior_nav_display.text = "ROUTE AHEAD\n%s\n%.1f km" % [destination, max(route_goal - distance, 0.0)]
	for mirror in interior_mirrors:
		mirror.rotation_degrees.y = (12.0 if mirror.position.x > 0.0 else -12.0) + steer * 5.0
	if mirrors_enabled:
		for i in mirror_cameras.size():
			var mirror_camera := mirror_cameras[i]
			var side := -1.0 if i == 0 else 1.0
			mirror_camera.global_position = truck.global_position + Vector3(side * 1.7, 2.25, -2.8)
			mirror_camera.look_at(truck.global_position + Vector3(side * 3.0, 1.4, 18.0), Vector3.UP)
	var wiper_active := current_weather == "rain" or current_weather == "snow"
	if wiper_active:
		wiper_phase = fmod(wiper_phase + delta * (3.0 + weather_intensity * 3.0 + speed * 0.08), TAU)
		for i in interior_wipers.size():
			interior_wipers[i].rotation_degrees.z = (18.0 if i == 1 else -18.0) + sin(wiper_phase) * (24.0 if i == 1 else -24.0)
	else:
		for i in interior_wipers.size():
			interior_wipers[i].rotation_degrees.z = 18.0 if i == 1 else -18.0
	var cabin_brightness := clamp(1.2 - sin((game_hour - 6.0) / 12.0 * PI) * 1.2, 0.12, 1.0)
	for lamp in interior_lamps:
		var lamp_material := lamp.material_override as StandardMaterial3D
		lamp_material.emission_energy_multiplier = cabin_brightness * 1.6
	for badge_light in cargo_badge_lights:
		var badge_material := badge_light.material_override as StandardMaterial3D
		badge_material.emission_energy_multiplier = cabin_brightness * 1.4
	for reflector in safety_reflectors:
		var reflector_material := reflector.material_override as StandardMaterial3D
		reflector_material.emission_energy_multiplier = cabin_brightness * 1.8

func _complete_delivery() -> void:
	money += 640
	toast = "DELIVERY COMPLETE   +€640"
	toast_time = 4.0
	_haptic(220, 0.9)
	distance = 0.0
	cargo_index = (cargo_index + 1) % 3
	route_goal = 10.0 + float(cargo_index * 2)
	destination = ["INNSBRUCK", "MILAN", "LYON"][cargo_index]
	_apply_livery(cargo_index)
	_save_game()

func _toggle_pause() -> void:
	paused = not paused
	toast = "PAUSED" if paused else "BACK ON THE ROAD"
	toast_time = 2.0

func _toggle_camera_mode() -> void:
	cockpit_mode = not cockpit_mode
	toast = "驾驶舱视角" if cockpit_mode else "第三人称视角"
	toast_time = 2.0

func _update_ui() -> void:
	if not ui_speed:
		return
	var cargo := ["MOUNTAIN TEA", "STRAWBERRY JAM", "ALPINE PARTS"][cargo_index]
	var branch_hint := _get_branch_hint()
	ui_route.text = "↗ %s\n%s\n%s  →  %s" % [branch_hint if branch_hint != "" else "ROUTE AHEAD", current_scene, cargo, destination]
	ui_speed.text = "%02d km/h" % int(speed * 4.4)
	var weather_name := {"clear": "晴", "rain": "雨", "snow": "雪"}.get(current_weather, "多云")
	ui_stats.text = "DEST  %s   %.1f km\nTIME  %s   %s   FUEL %d%%\nSLOPE %+d%%   DAMAGE %d%%   € %d" % [destination, max(route_goal - distance, 0.0), _format_clock(), weather_name, int(fuel), int(slope_percent), int(damage), money]
	ui_toast.text = toast if toast_time > 0.0 else ""
	if minimap:
		minimap.update_state(truck.position.x, distance, route_goal, current_scene, destination, branch_hint)

func _get_branch_hint() -> String:
	if current_scene.find("城市") >= 0:
		return "环城匝道 / OLD TOWN"
	if current_scene.find("乡村") >= 0:
		return "农场支路 / FARM LAKE"
	if current_scene.find("雪谷") >= 0:
		return "观景道路 / SUMMIT VIEW"
	if current_scene.find("森林") >= 0:
		return "湖区连接 / FOREST LAKE"
	if current_scene.find("平原") >= 0:
		return "服务区 / REST STOP"
	return ""

func _update_streaming() -> void:
	var traveled := max(0.0, -truck.position.z - 120.0)
	var next_chunk := max(0, int(floor(traveled / CHUNK_LENGTH)))
	if next_chunk == active_chunk and stream_chunks.size() >= 5:
		return
	active_chunk = next_chunk
	for chunk_index in range(active_chunk, active_chunk + 6):
		_ensure_stream_chunk(chunk_index)
	var expired: Array[int] = []
	for old_index in stream_chunks.keys():
		if int(old_index) < active_chunk - 2:
			expired.append(int(old_index))
	for old_index in expired:
		var old_root: Node3D = stream_chunks[old_index]
		old_root.queue_free()
		stream_chunks.erase(old_index)

func _ensure_stream_chunk(chunk_index: int) -> void:
	if stream_chunks.has(chunk_index):
		return
	var root := Node3D.new()
	root.name = "RouteChunk_%03d" % chunk_index
	root.position = Vector3(0, 0, -120.0 - float(chunk_index) * CHUNK_LENGTH)
	add_child(root)
	var rng := RandomNumberGenerator.new()
	rng.seed = stream_seed + chunk_index * 7919
	var biome := int(floor(float(chunk_index) / 50.0)) % 5 # 50 km macro-regions.
	for local_z in range(-480, 481, 80):
		_add_chunk_road_segment(root, local_z, biome, rng)
		if biome == 0 and abs(local_z) % 160 == 0:
			_add_chunk_city_road_detail(root, local_z, rng, chunk_index % 4)
			_add_chunk_city_signal(root, local_z)
	_add_chunk_road_network(root, biome, rng, chunk_index)
	for prop_index in range(8):
		var local_z := -500.0 + float(prop_index) * 125.0 + rng.randf_range(-28.0, 28.0)
		var side := -1.0 if prop_index % 2 == 0 else 1.0
		var lateral := rng.randf_range(9.0, 18.0) * side
		_add_chunk_prop(root, biome, Vector3(lateral, 0, local_z), rng, prop_index, chunk_index % 4)
	_add_chunk_free_assets(root, biome, rng, chunk_index)
	if biome == 0:
		_add_chunk_city_gate(root, rng)
	elif biome == 1:
		_add_chunk_village_gate(root, rng)
	elif biome == 2:
		_add_chunk_forest_gate(root, rng)
	elif biome == 3:
		_add_chunk_mountain_gate(root, rng)
	else:
		_add_chunk_plain_gate(root, rng)
	_add_chunk_event_landmark(root, biome, rng)
	_add_chunk_mileage_marker(root, chunk_index, rng)
	if biome == 0 and chunk_index % 3 == 0:
		_add_chunk_branch(root, -220.0, 1.0, 0.32, "CityRamp")
	elif biome == 1 and chunk_index % 4 == 1:
		_add_chunk_branch(root, 180.0, -1.0, 0.48, "FarmSideRoad")
	elif biome == 3 and chunk_index % 5 == 2:
		_add_chunk_branch(root, -80.0, 1.0, 0.62, "MountainViewRoad")
	if chunk_index % 4 == 0:
		_add_chunk_rest_area(root, rng)
		stream_chunks[chunk_index] = root

func _add_chunk_free_assets(root: Node3D, biome: int, rng: RandomNumberGenerator, chunk_index: int) -> void:
	# Use collected GLB assets as authored accents while procedural geometry remains the fallback.
	var primary_path := ""
	var primary_pos := Vector3.ZERO
	var primary_scale := 1.0
	if biome == 0:
		primary_path = FreeAssetCatalog.traffic_path(chunk_index)
		primary_pos = Vector3(9.0 + rng.randf_range(0.0, 3.0), 0.0, -260.0 + rng.randf_range(-25.0, 25.0))
		primary_scale = 0.75
	elif biome == 1:
		primary_path = FreeAssetCatalog.nature_path(chunk_index + 2)
		primary_pos = Vector3(-11.0, 0.0, -210.0 + rng.randf_range(-24.0, 24.0))
		primary_scale = 1.1
	elif biome == 2:
		primary_path = FreeAssetCatalog.nature_path(chunk_index)
		primary_pos = Vector3(11.0, 0.0, -310.0 + rng.randf_range(-25.0, 25.0))
		primary_scale = 1.25
	elif biome == 3:
		primary_path = FreeAssetCatalog.nature_path(chunk_index + 1)
		primary_pos = Vector3(-12.0, 0.0, -360.0 + rng.randf_range(-20.0, 20.0))
		primary_scale = 1.35
	else:
		primary_path = FreeAssetCatalog.road_path(chunk_index + 1)
		primary_pos = Vector3(10.0, 0.0, -240.0 + rng.randf_range(-25.0, 25.0))
		primary_scale = 0.8
	var instance := FreeAssetCatalog.instantiate(root, primary_path, primary_pos, primary_scale, rng.randf_range(-0.18, 0.18))
	FreeAssetCatalog.add_lod_visibility(instance, 50.0, 135.0)

func _add_chunk_road_network(root: Node3D, biome: int, rng: RandomNumberGenerator, chunk_index: int) -> void:
	# Every streamed kilometer gets at least one visible secondary road.
	# The road type changes by biome so the world reads as a network, not a single ribbon.
	var secondary_offset := 15.0 if biome == 0 or biome == 4 else 12.0
	var road_width := 6.0 if biome == 0 or biome == 4 else 4.2
	var road_name := ["CityRingRoad", "FarmSideRoad", "ForestServiceRoad", "MountainViewRoad", "PlainsFrontageRoad"][biome]
	for segment_index in range(5):
		var local_z := -400.0 + float(segment_index) * 200.0
		var world_z := root.position.z + local_z
		var base_center := _road_center_at(world_z)
		var bend := sin(world_z * 0.0017 + float(chunk_index) * 0.7) * 1.4
		var branch := Node3D.new()
		branch.name = road_name + "_%02d" % segment_index
		branch.position = Vector3(base_center + secondary_offset * (-1.0 if chunk_index % 2 == 0 else 1.0) + bend, _road_height_at(world_z) + 0.03, local_z)
		branch.rotation.y = atan2(_road_center_at(world_z + 10.0) - base_center, 10.0)
		root.add_child(branch)
		_box(branch, Vector3(road_width, 0.14, 170.0), Vector3.ZERO, Color("#52586c"), road_name + "Surface")
		_box(branch, Vector3(0.14, 0.22, 170.0), Vector3(-road_width * 0.5, 0.13, 0), INK, road_name + "Edge")
		_box(branch, Vector3(0.14, 0.22, 170.0), Vector3(road_width * 0.5, 0.13, 0), INK, road_name + "Edge")
		for marker_z in [-52.0, 0.0, 52.0]:
			_box(branch, Vector3(0.16, 0.035, 4.2), Vector3(0, 0.11, marker_z), CREAM, road_name + "LaneMark")
		if biome == 3:
			for marker_z in [-65.0, 65.0]:
				_box(branch, Vector3(0.12, 1.6, 0.12), Vector3(-road_width * 0.5 - 0.2, 0.8, marker_z), Color("#ef6f61"), road_name + "SnowPole")
	# Add explicit connectors so secondary roads read as connected routes.
	if chunk_index % 2 == 0 or biome == 0:
		for connector_z in [-300.0, 300.0]:
			var connector := Node3D.new()
			connector.name = road_name + "Connector"
			connector.position = Vector3(_road_center_at(root.position.z + connector_z), _road_height_at(root.position.z + connector_z) + 0.08, connector_z)
			connector.rotation.z = deg_to_rad(90.0)
			root.add_child(connector)
			_box(connector, Vector3(0.9, 0.12, secondary_offset), Vector3(secondary_offset * 0.5, 0, 0), ASPHALT, road_name + "ConnectorSurface")
			_box(connector, Vector3(0.12, 0.18, secondary_offset), Vector3(secondary_offset * 0.5, 0.12, -road_width * 0.5), CREAM, road_name + "ConnectorMark")
	# Route signage makes each road leg legible instead of decorative geometry only.
	var sign := Node3D.new()
	sign.name = road_name + "RouteSign"
	sign.position = Vector3(secondary_offset * (-1.0 if chunk_index % 2 == 0 else 1.0), 0.0, -455.0)
	root.add_child(sign)
	_box(sign, Vector3(0.16, 2.4, 0.16), Vector3.ZERO + Vector3(0, 1.2, 0), INK, road_name + "SignPost")
	_box(sign, Vector3(2.8, 0.9, 0.14), Vector3(0, 2.45, 0), Color("#3478a8"), road_name + "RoutePanel")
	_box(sign, Vector3(1.55, 0.10, 0.08), Vector3(0.3, 2.45, -0.1), CREAM, road_name + "RouteArrow")

func _road_center_at(world_z: float) -> float:
	var macro := sin(world_z * 0.0027 + 0.8) * 3.0
	var long_curve := sin(world_z * 0.00072 + 2.1) * 2.4
	return clamp(macro + long_curve, -5.0, 5.0)

func _road_height_at(world_z: float) -> float:
	var macro_region := int(floor(max(0.0, -world_z - 120.0) / 50000.0)) % 5
	var rolling := sin((world_z - 95.0) * 0.0018) * 2.2 + sin((world_z - 95.0) * 0.00043) * 1.5
	if macro_region == 3:
		return rolling + sin((world_z - 95.0) * 0.0008) * 8.0
	if macro_region == 1 or macro_region == 4:
		return rolling * 0.45
	return rolling

func _add_chunk_road_segment(root: Node3D, local_z: float, biome: int, rng: RandomNumberGenerator) -> void:
	var world_z := root.position.z + local_z
	var center := _road_center_at(world_z)
	var ahead := _road_center_at(world_z + 8.0)
	var height := _road_height_at(world_z)
	var ahead_height := _road_height_at(world_z + 8.0)
	var segment := Node3D.new()
	segment.name = "CurvedRoadSegment"
	segment.position = Vector3(center, height, local_z)
	segment.rotation.y = atan2(ahead - center, 8.0)
	segment.rotation.x = -atan2(ahead_height - height, 8.0)
	root.add_child(segment)
	var road_width := 12.0
	if biome == 0 and rng.randf() > 0.7:
		road_width = 16.0
	elif biome == 3 and rng.randf() > 0.55:
		road_width = 9.5
	_box(segment, Vector3(road_width, 0.18, 90.0), Vector3.ZERO, ASPHALT, "ChunkRoadSurface")
	for marker_z in [-30.0, 0.0, 28.0]:
		_box(segment, Vector3(0.22, 0.04, 5.5), Vector3(0, 0.12, marker_z), CREAM, "ChunkLaneMarker")
	for side in [-1.0, 1.0]:
		_box(segment, Vector3(0.16, 0.32, 90.0), Vector3(side * road_width * 0.5, 0.15, 0), INK, "ChunkRoadEdge")
		for marker_z in [-30.0, 0.0, 30.0]:
			var edge_marker := _box(segment, Vector3(0.12, 0.18, 0.16), Vector3(side * (road_width * 0.5 + 0.12), 0.38, marker_z), Color("#ffd166"), "ChunkEdgeReflector")
			var edge_material := edge_marker.material_override as StandardMaterial3D
			edge_material.emission_enabled = true
			edge_material.emission = Color("#ffb84d")
			edge_material.emission_energy_multiplier = 1.4
	_add_chunk_biome_road_detail(segment, biome, road_width, rng, int(root.name.trim_prefix("RouteChunk_")) % 4)

func _add_chunk_biome_road_detail(segment: Node3D, biome: int, road_width: float, rng: RandomNumberGenerator, district: int = 0) -> void:
	if biome == 1:
		# Rural roads get grass shoulders, farm gates and wooden fencing.
		for side in [-1.0, 1.0]:
			_box(segment, Vector3(2.2, 0.06, 86.0), Vector3(side * (road_width * 0.5 + 1.3), 0.02, 0), Color("#a8c46f"), "VillageGrassShoulder")
			for post_z in [-30.0, 0.0, 30.0]:
				_box(segment, Vector3(0.14, 1.0, 0.14), Vector3(side * 8.0, 0.5, post_z), Color("#8c6048"), "VillageFencePost")
		if district == 2:
			_box(segment, Vector3(4.0, 0.08, 86.0), Vector3(0, 0.05, 0), Color("#5fb5d0"), "ValleyStream")
		elif district == 3:
			for orchard_x in [-8.0, 8.0]:
				for orchard_z in [-28.0, 0.0, 28.0]:
					_add_chunk_tree(segment, Vector3(orchard_x, 0, orchard_z), 0.65, int(abs(orchard_z)))
	elif biome == 2:
		# Forest roads get reflective guardrails and mossy roadside markers.
		for side in [-1.0, 1.0]:
			_box(segment, Vector3(0.14, 0.85, 84.0), Vector3(side * (road_width * 0.5 + 0.8), 0.6, 0), Color("#66728b"), "ForestGuardrail")
			for marker_z in [-28.0, 0.0, 28.0]:
				_box(segment, Vector3(0.22, 0.55, 0.12), Vector3(side * 7.0, 0.35, marker_z), Color("#74d0ad"), "ForestReflector")
		if district == 1:
			_box(segment, Vector3(3.0, 0.05, 82.0), Vector3(0, 0.03, 0), Color("#355b52"), "RainforestWetCenter")
		elif district == 2:
			_box(segment, Vector3(2.0, 0.04, 82.0), Vector3(-7.0, 0.04, 0), Color("#477f98"), "LakeForestWaterEdge")
		elif district == 3:
			_box(segment, Vector3(0.24, 1.6, 82.0), Vector3(0, 0.8, 0), Color("#8d9caf"), "CanyonDivider")
	elif biome == 3:
		# Snow roads use tall snow poles, wider shoulders and chevrons.
		for side in [-1.0, 1.0]:
			_box(segment, Vector3(1.8, 0.12, 86.0), Vector3(side * (road_width * 0.5 + 1.4), 0.03, 0), Color("#d7e4ee"), "SnowShoulder")
			for marker_z in [-30.0, 0.0, 30.0]:
				_box(segment, Vector3(0.12, 2.4, 0.12), Vector3(side * 6.9, 1.2, marker_z), Color("#ef6f61"), "SnowPole")
		if district == 0:
			_box(segment, Vector3(3.0, 0.10, 82.0), Vector3(0, 0.04, 0), Color("#d7e4ee"), "GlacierSnowDeck")
		elif district == 2:
			_box(segment, Vector3(0.22, 1.2, 82.0), Vector3(-5.7, 0.7, 0), Color("#7b7890"), "MineRockWall")
		elif district == 3:
			_box(segment, Vector3(0.35, 0.35, 82.0), Vector3(0, 0.28, 0), Color("#38405b"), "TunnelApproach")
	elif biome == 4:
		# Plains become broad highways with rumble strips and a central divider.
		_box(segment, Vector3(0.24, 0.08, 86.0), Vector3(0, 0.17, 0), Color("#ffd166"), "HighwayCenterLine")
		for side in [-1.0, 1.0]:
			_box(segment, Vector3(0.28, 0.05, 86.0), Vector3(side * (road_width * 0.5 - 0.4), 0.18, 0), CREAM, "HighwayRumbleStrip")
		if district == 1:
			_box(segment, Vector3(5.0, 0.04, 80.0), Vector3(8.0, 0.04, 0), Color("#477f98"), "WetlandRoadsideWater")
		elif district == 2:
			_box(segment, Vector3(0.30, 1.2, 80.0), Vector3(7.2, 0.7, 0), Color("#d5dded"), "WindFarmFence")
		elif district == 3:
			_box(segment, Vector3(2.0, 0.05, 80.0), Vector3(-7.0, 0.04, 0), Color("#31517c"), "SolarFieldEdge")

func _add_chunk_city_road_detail(root: Node3D, local_z: float, rng: RandomNumberGenerator, district: int) -> void:
	var world_z := root.position.z + local_z
	var center := _road_center_at(world_z)
	var height := _road_height_at(world_z)
	var detail := Node3D.new()
	detail.position = Vector3(center, height, local_z)
	detail.rotation.y = atan2(_road_center_at(world_z + 8.0) - center, 8.0)
	root.add_child(detail)
	for side in [-1.0, 1.0]:
		_box(detail, Vector3(2.0, 0.16, 82.0), Vector3(side * 8.0, 0.12, 0), Color("#858b9d"), "CitySidewalk")
		for lamp_z in [-30.0, 0.0, 30.0]:
			if district == 3 and abs(lamp_z) < 1.0:
				continue
			_box(detail, Vector3(0.16, 4.8, 0.16), Vector3(side * 8.8, 2.45, lamp_z), INK, "ChunkStreetLamp")
			var lamp := _box(detail, Vector3(0.42, 0.18, 0.32), Vector3(side * 8.45, 4.55, lamp_z), Color("#ffd166"), "ChunkLampGlow")
			var lamp_material := lamp.material_override as StandardMaterial3D
			lamp_material.emission_enabled = true
			lamp_material.emission = Color("#ffb35c")
			lamp_material.emission_energy_multiplier = 2.2
	if district == 2:
		_box(detail, Vector3(1.2, 0.12, 70.0), Vector3(0, 0.22, 0), Color("#66728b"), "IndustrialMedian")
	if rng.randf() > (0.15 + district * 0.12):
		for stripe in range(-4, 5):
			_box(detail, Vector3(0.42, 0.025, 7.0), Vector3(float(stripe) * 0.62, 0.22, 0), CREAM, "CityCrosswalk")

func _add_chunk_city_signal(root: Node3D, local_z: float) -> void:
	var signal_root := Node3D.new()
	signal_root.name = "ChunkSignalIntersection"
	signal_root.position = Vector3(_road_center_at(root.position.z + local_z), _road_height_at(root.position.z + local_z), local_z)
	root.add_child(signal_root)
	for side in [-1.0, 1.0]:
		_box(signal_root, Vector3(0.18, 4.0, 0.18), Vector3(side * 7.0, 2.0, 0), INK, "ChunkSignalPole")
		var red := _box(signal_root, Vector3(0.42, 0.42, 0.25), Vector3(side * 7.0, 4.25, 0), CORAL, "ChunkSignalRed")
		var green := _box(signal_root, Vector3(0.42, 0.42, 0.25), Vector3(side * 7.0, 3.65, 0), MINT, "ChunkSignalGreen")
		traffic_signal_lamps.append(red)
		traffic_signal_lamps.append(green)

func _near_signal_intersection(world_z: float) -> bool:
	return abs(fmod(abs(world_z), 160.0) - 0.0) < 12.0 or abs(fmod(abs(world_z), 160.0) - 160.0) < 12.0

func _signal_is_red(world_z: float) -> bool:
	return fmod(Time.get_ticks_msec() / 1000.0 + abs(world_z) * 0.001, 12.0) < 5.0

func _update_signal_visuals() -> void:
	var red_on := _signal_is_red(truck.position.z)
	for i in traffic_signal_lamps.size():
		if is_instance_valid(traffic_signal_lamps[i]):
			traffic_signal_lamps[i].visible = (i % 2 == 0) == red_on

func _add_chunk_prop(root: Node3D, biome: int, pos: Vector3, rng: RandomNumberGenerator, index: int, district: int = 0) -> void:
	if biome == 0:
		var building_size := Vector3(rng.randf_range(3.5, 7.5), rng.randf_range(3.0, 10.0), rng.randf_range(3.5, 7.5))
		if district == 0: # downtown skyline
			building_size = Vector3(rng.randf_range(5.0, 9.0), rng.randf_range(14.0, 28.0), rng.randf_range(5.0, 9.0))
		elif district == 1: # residential blocks
			building_size = Vector3(rng.randf_range(5.0, 8.0), rng.randf_range(4.0, 9.0), rng.randf_range(5.0, 8.0))
		elif district == 2: # industrial sheds
			building_size = Vector3(rng.randf_range(8.0, 14.0), rng.randf_range(3.0, 6.0), rng.randf_range(9.0, 18.0))
		else: # outer ring low-rise
			building_size = Vector3(rng.randf_range(3.5, 7.5), rng.randf_range(2.5, 5.0), rng.randf_range(3.5, 7.5))
		_box(root, building_size, pos + Vector3(0, 2.0, 0), [Color("#e58c78"), Color("#8e9bd1"), Color("#f4b86b")][index % 3], "ChunkCityBuilding")
		_box(root, Vector3(building_size.x * 0.75, 0.22, 0.15), pos + Vector3(0, 2.0, -building_size.z * 0.52), Color("#9fe3ff"), "ChunkWindow")
		if district == 2:
			_box(root, Vector3(building_size.x * 0.5, 0.3, 0.2), pos + Vector3(0, building_size.y * 0.65, -building_size.z * 0.53), Color("#ffd166"), "IndustrialSign")
	elif biome == 1:
		if district == 1:
			_box(root, Vector3(6.0, 2.8, 5.0), pos + Vector3(0, 1.4, 0), Color("#f4b86b"), "ChunkVillageHouse")
			_box(root, Vector3(6.4, 0.25, 5.4), pos + Vector3(0, 3.0, 0), CORAL, "ChunkVillageRoof")
		elif district == 2:
			_box(root, Vector3(7.0, 2.0, 3.0), pos + Vector3(0, 1.0, 0), Color("#8e9bd1"), "ChunkValleyBarn")
		else:
			_box(root, Vector3(5.0, 2.4, 4.0), pos + Vector3(0, 1.2, 0), Color("#f4b86b"), "ChunkFarmHouse")
			_box(root, Vector3(5.4, 0.25, 4.4), pos + Vector3(0, 2.7, 0), CORAL, "ChunkFarmRoof")
		for crop in range(3):
			_box(root, Vector3(4.5, 0.08, 0.28), pos + Vector3(0, 0.08, -2.0 + crop * 1.7), Color("#c78c55"), "ChunkCropRow")
	elif biome == 2:
		if district == 0:
			_add_chunk_tree(root, pos, rng.randf_range(1.2, 2.0), index + 2)
		elif district == 1:
			_add_chunk_tree(root, pos, rng.randf_range(0.8, 1.6), index)
			_box(root, Vector3(2.0, 0.08, 2.0), pos + Vector3(0, 0.05, 0), Color("#557b54"), "RainforestMoss")
		elif district == 2:
			_add_chunk_tree(root, pos, rng.randf_range(0.75, 1.3), index)
			_box(root, Vector3(6.0, 0.06, 4.0), pos + Vector3(0, 0.02, 2.0), Color("#477f98"), "ForestPond")
		else:
			var canyon_rock := _cylinder(root, rng.randf_range(1.4, 2.8), rng.randf_range(3.0, 7.0), pos + Vector3(0, 1.6, 0), Color("#59627b"), "CanyonRock")
			canyon_rock.rotation_degrees.z = rng.randf_range(-20.0, 20.0)
	elif biome == 3:
		if district == 0:
			var glacier := _cylinder(root, rng.randf_range(1.0, 2.2), rng.randf_range(3.0, 7.0), pos + Vector3(0, 1.5, 0), Color("#9fe3ff"), "GlacierIce")
			glacier.rotation_degrees.z = rng.randf_range(-18.0, 18.0)
		elif district == 1:
			_add_chunk_tree(root, pos, rng.randf_range(1.0, 1.7), index + 1)
		else:
			var rock := _cylinder(root, rng.randf_range(1.0, 2.2), rng.randf_range(2.0, 5.0), pos + Vector3(0, 1.0, 0), [Color("#59627b"), Color("#7b7890"), Color("#8d9caf")][index % 3], "ChunkMountainRock")
			rock.rotation_degrees.z = rng.randf_range(-18.0, 18.0)
			if district == 2:
				_box(root, Vector3(2.0, 0.18, 0.18), pos + Vector3(0, 2.5, -1.2), Color("#ffd166"), "MineWarningStripe")
	else:
		if district == 1:
			_box(root, Vector3(rng.randf_range(4.0, 8.0), 0.08, rng.randf_range(5.0, 12.0)), pos, Color("#5fb5d0"), "WetlandPool")
			_box(root, Vector3(0.18, 1.2, 0.18), pos + Vector3(1.6, 0.6, 0), Color("#8c6048"), "WetlandPost")
		elif district == 2:
			_box(root, Vector3(0.18, 8.0, 0.18), pos + Vector3(0, 4.0, 0), Color("#d5dded"), "WindTurbinePole")
			for angle in [0.0, PI * 0.666, PI * 1.333]:
				var blade := _box(root, Vector3(0.12, 2.5, 0.1), pos + Vector3(0, 8.0, 0), CREAM, "WindTurbineBlade")
				blade.rotation_degrees.z = rad_to_deg(angle)
		elif district == 3:
			_box(root, Vector3(6.0, 0.08, 7.0), pos, Color("#31517c"), "PlainSolarPanel")
			_box(root, Vector3(0.12, 1.2, 0.12), pos + Vector3(0, 0.6, 0), Color("#d5dded"), "PlainSolarPost")
		else:
			_box(root, Vector3(rng.randf_range(3.0, 7.0), 0.2, rng.randf_range(4.0, 10.0)), pos, [Color("#d3a35f"), Color("#a8c46f"), Color("#e7c97b")][index % 3], "ChunkPlainField")

func _add_chunk_tree(root: Node3D, pos: Vector3, scale_value: float, index: int) -> void:
	_box(root, Vector3(0.55 * scale_value, 2.7 * scale_value, 0.55 * scale_value), pos + Vector3(0, 1.35 * scale_value, 0), Color("#76513d"), "ChunkTreeTrunk")
	var crown := _cylinder(root, 1.8 * scale_value, 3.8 * scale_value, pos + Vector3(0, 3.4 * scale_value, 0), [Color("#4c9c79"), Color("#397a68"), Color("#6da66b")][index % 3], "ChunkTreeCrown")
	crown.rotation_degrees.z = float(index * 17 % 25)

func _add_chunk_city_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	_box(root, Vector3(18.0, 0.35, 0.55), Vector3(0, 7.2, -52), Color("#66728b"), "ChunkCityArch")
	_box(root, Vector3(0.45, 7.0, 0.55), Vector3(-8.7, 3.5, -52), CORAL, "ChunkCityPillar")
	_box(root, Vector3(0.45, 7.0, 0.55), Vector3(8.7, 3.5, -52), CORAL, "ChunkCityPillar")

func _add_chunk_village_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	_box(root, Vector3(0.3, 5.0, 0.3), Vector3(-8.7, 2.5, -52), INK, "ChunkFarmPole")
	_box(root, Vector3(0.3, 5.0, 0.3), Vector3(8.7, 2.5, -52), INK, "ChunkFarmPole")
	_box(root, Vector3(17.8, 0.28, 0.3), Vector3(0, 5.0, -52), Color("#f4b86b"), "ChunkFarmBeam")

func _add_chunk_forest_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	for side in [-1.0, 1.0]:
		_add_chunk_tree(root, Vector3(side * 8.5, 0, -52), rng.randf_range(1.4, 1.9), int(rng.randi()))

func _add_chunk_mountain_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	_box(root, Vector3(16.0, 0.5, 0.8), Vector3(0, 5.8, -52), Color("#38405b"), "ChunkPassBeam")
	_box(root, Vector3(0.7, 5.8, 0.8), Vector3(-7.6, 2.9, -52), Color("#59627b"), "ChunkPassPillar")
	_box(root, Vector3(0.7, 5.8, 0.8), Vector3(7.6, 2.9, -52), Color("#59627b"), "ChunkPassPillar")

func _add_chunk_plain_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	for side in [-1.0, 1.0]:
		_box(root, Vector3(0.22, 8.0, 0.22), Vector3(side * 12.0, 4.0, -52), Color("#d5dded"), "ChunkWindPole")
		_box(root, Vector3(0.14, 3.5, 0.14), Vector3(side * 12.0, 8.0, -52), CREAM, "ChunkWindBlade")

func _add_chunk_event_landmark(root: Node3D, biome: int, rng: RandomNumberGenerator) -> void:
	if biome == 0:
		# 3D city interchange with elevated ramps.
		_box(root, Vector3(18.0, 0.35, 5.0), Vector3(0, 3.7, 0), Color("#66728b"), "CityFlyover")
		for side in [-1.0, 1.0]:
			_box(root, Vector3(0.55, 3.8, 0.55), Vector3(side * 7.5, 1.8, 0), INK, "FlyoverPillar")
	elif biome == 1:
		# Wooden bridge over a shallow stream.
		_box(root, Vector3(17.0, 0.45, 7.0), Vector3(0, 0.6, 0), Color("#8c6048"), "VillageWoodBridge")
		_box(root, Vector3(15.0, 0.08, 5.0), Vector3(0, 0.12, 0), Color("#5fb5d0"), "VillageStream")
		for side in [-1.0, 1.0]:
			_box(root, Vector3(0.28, 1.2, 7.0), Vector3(side * 7.2, 1.1, 0), Color("#f4b86b"), "BridgeWoodRail")
	elif biome == 2:
		# Forest lake and dock, built from 3D meshes.
		_box(root, Vector3(17.0, 0.08, 18.0), Vector3(0, 0.03, 0), Color("#477f98"), "ForestLake")
		_box(root, Vector3(5.0, 0.18, 0.7), Vector3(8.0, 0.22, 0), Color("#8c6048"), "ForestDock")
		for dock_z in [-2.0, 0.0, 2.0]:
			_box(root, Vector3(0.18, 0.3, 0.18), Vector3(5.7, 0.3, dock_z), INK, "DockPost")
	elif biome == 3:
		# Snow mountain tunnel portal.
		_box(root, Vector3(15.0, 6.5, 1.0), Vector3(0, 3.25, 0), Color("#38405b"), "SnowTunnelFace")
		_box(root, Vector3(7.0, 4.0, 1.2), Vector3(0, 1.5, -0.7), INK, "SnowTunnelOpening")
		for x in [-4.0, -2.0, 0.0, 2.0, 4.0]:
			_box(root, Vector3(0.24, 0.24, 0.18), Vector3(x, 4.2, -1.0), Color("#fff0a7"), "TunnelMarker")
	else:
		# Large solar field for the open plains.
		for row in range(3):
			for col in range(4):
				var x := 10.0 + float(col) * 2.1
				var z := -4.0 + float(row) * 3.2
				_box(root, Vector3(1.6, 0.08, 2.0), Vector3(x, 1.3, z), Color("#31517c"), "SolarPanel")
				_box(root, Vector3(0.12, 1.2, 0.12), Vector3(x, 0.65, z), Color("#d5dded"), "SolarPost")

func _add_chunk_mileage_marker(root: Node3D, chunk_index: int, rng: RandomNumberGenerator) -> void:
	var marker_z := rng.randf_range(-410.0, -300.0)
	var side := -1.0 if chunk_index % 2 == 0 else 1.0
	var x := side * 7.2
	_box(root, Vector3(0.16, 2.2, 0.16), Vector3(x, 1.1, marker_z), INK, "KilometerPost")
	_box(root, Vector3(1.8, 0.8, 0.12), Vector3(x, 2.25, marker_z), [CORAL, MINT, Color("#66728b")][chunk_index % 3], "KilometerPlate")
	_box(root, Vector3(1.1, 0.12, 0.06), Vector3(x, 2.25, marker_z - 0.08), CREAM, "KilometerTextStripe")

func _add_chunk_rest_area(root: Node3D, rng: RandomNumberGenerator) -> void:
	var rest_z := rng.randf_range(80.0, 260.0)
	var side := -1.0 if rng.randf() > 0.5 else 1.0
	var rest_x := side * 15.0
	_box(root, Vector3(10.0, 0.08, 28.0), Vector3(rest_x, 0.03, rest_z), Color("#5b6d73"), "RestAreaLot")
	_box(root, Vector3(7.0, 2.8, 3.8), Vector3(rest_x, 1.4, rest_z - 8.0), Color("#8e9bd1"), "RestAreaBuilding")
	_box(root, Vector3(7.5, 0.25, 4.3), Vector3(rest_x, 2.95, rest_z - 8.0), Color("#ffd166"), "RestAreaRoof")
	for parking in [-5.0, 0.0, 5.0]:
		_box(root, Vector3(3.6, 0.04, 7.0), Vector3(rest_x + side * 3.0, 0.08, rest_z + parking), CREAM, "RestParkingBay")

func _add_chunk_branch(root: Node3D, local_z: float, side: float, angle: float, branch_name: String) -> void:
	var world_z := root.position.z + local_z
	var center := _road_center_at(world_z)
	var height := _road_height_at(world_z)
	var branch := Node3D.new()
	branch.name = branch_name
	branch.position = Vector3(center + side * 5.0, height + 0.04, local_z)
	branch.rotation.y = side * angle
	root.add_child(branch)
	_box(branch, Vector3(5.0, 0.16, 82.0), Vector3.ZERO, ASPHALT, branch_name + "Surface")
	_box(branch, Vector3(0.16, 0.3, 82.0), Vector3(-2.35, 0.16, 0), INK, branch_name + "Edge")
	_box(branch, Vector3(0.16, 0.3, 82.0), Vector3(2.35, 0.16, 0), INK, branch_name + "Edge")
	_box(branch, Vector3(0.18, 2.0, 0.18), Vector3(side * 2.8, 1.0, -34.0), INK, branch_name + "SignPost")
	_box(branch, Vector3(1.8, 0.7, 0.12), Vector3(side * 2.8, 2.05, -34.0), Color("#3478a8"), branch_name + "Sign")
