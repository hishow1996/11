extends Node3D

# Anime Haul 3D — Android-friendly third-person truck driving prototype.
# Art: stylized low-poly 3D with warm cel-like colors and ink-dark outlines simulated by silhouettes.
# Audio: realistic-style local diesel and air-brake WAV loops.

var truck: Node3D
var camera: Camera3D
var cockpit_mode := false
var speed := 0.0
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
var traffic_lanes := [-3.2, 0.0, 3.2]
var traffic_speeds := [0.82, 1.05, 0.68]
var traffic_types := ["car", "van", "bus"]
var traffic_lights: Array[MeshInstance3D] = []
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
var station_positions: Array[Vector3] = []
var refueling := false
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

const ROAD_WIDTH := 12.0
const ROAD_LENGTH := 240.0
const INK := Color("#211c37")
const ASPHALT := Color("#40455b")
const CREAM := Color("#fff1cf")
const CORAL := Color("#ef6f61")
const MINT := Color("#74d0ad")
const SKY := Color("#86d6e8")
const SAVE_PATH := "user://anime_haul_save.json"

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
	material.roughness = roughness
	material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return material

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, name := "Box") -> MeshInstance3D:
	var outlined_parts := ["Trailer", "Cab", "Windshield", "FrontBumper", "TrailerStripe", "Body", "Glass", "Lamp"]
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
	quad.material = material
	particles.draw_pass_1 = quad
	particles.position = Vector3(0, 10, 0)
	particles.visibility_aabb = AABB(Vector3(-18, -2, -24), Vector3(36, 22, 48))
	add_child(particles)
	return particles

func _build_world() -> void:
	var ground := _box(self, Vector3(180, 0.4, ROAD_LENGTH), Vector3(0, -0.35, -ROAD_LENGTH * 0.25), Color("#9bb07f"), "Grass")
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	road_surface = _box(self, Vector3(ROAD_WIDTH, 0.18, ROAD_LENGTH), Vector3(0, -0.12, -ROAD_LENGTH * 0.25), ASPHALT, "Road")
	road_surface.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for z in range(-120, 110, 12):
		_box(self, Vector3(0.22, 0.04, 5.5), Vector3(0, 0.01, z), CREAM, "LaneMarker")
		_box(self, Vector3(0.18, 0.35, 12.0), Vector3(-6.35, 0.1, z), INK, "RoadEdge")
		_box(self, Vector3(0.18, 0.35, 12.0), Vector3(6.35, 0.1, z), INK, "RoadEdge")
		_add_guardrail(Vector3(-7.0, 0, z), -1.0)
		_add_guardrail(Vector3(7.0, 0, z), 1.0)
		_add_reflector(Vector3(-6.75, 0.32, z + 4.0))
		_add_reflector(Vector3(6.75, 0.32, z + 4.0))
		_add_puddle(Vector3(sin(float(z)) * 2.2, 0.06, z + 2.5), 0.7 + fmod(abs(z), 2.0) * 0.22)
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
	_add_fuel_station(Vector3(-13.0, 0, -92.0), "CITY FUEL")
		if int(abs(z)) % 20 == 12:
			_add_city_landmark(float(z))
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
	for z in range(74, 112, 12):
		_add_plain_field(float(z))
		_add_plain_landmark(float(z))
	_add_bridge(92.0)
	_add_direction_sign(Vector3(-7.4, 0, -86), "CITY")
	_add_direction_sign(Vector3(7.4, 0, 42), "PASS")

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
	var cone := _cylinder(root, 7.0, 18.0, Vector3(0, 8.8, 0), Color("#53617d"), "Mountain")
	var cap := _cylinder(root, 3.5, 0.8, Vector3(0, 18.3, 0), Color("#f5f2df"), "SnowCap")
	cone.rotation_degrees.y = 22.0
	cap.rotation_degrees.y = 22.0

func _add_tree(pos: Vector3, scale_factor: float) -> void:
	var tree := Node3D.new()
	tree.position = pos
	tree.scale = Vector3.ONE * scale_factor
	add_child(tree)
	_cylinder(tree, 0.25, 2.5, Vector3(0, 1.2, 0), Color("#6e4639"), "Trunk")
	_cylinder(tree, 1.7, 3.2, Vector3(0, 3.1, 0), Color("#4c9c79"), "Foliage")
	_cylinder(tree, 1.2, 2.4, Vector3(0, 4.8, 0), Color("#74d0ad"), "FoliageTop")

func _build_truck() -> void:
	truck = Node3D.new()
	truck.name = "PlayerTruck"
	truck.position = Vector3(0, 0.65, 95)
	add_child(truck)
	_box(truck, Vector3(4.9, 2.25, 7.2), Vector3(0, 1.35, 0.9), CREAM, "Trailer")
	_box(truck, Vector3(4.98, 0.36, 7.0), Vector3(0, 2.28, 0.9), CORAL, "TrailerStripe")
	_box(truck, Vector3(4.0, 2.7, 2.7), Vector3(0, 1.55, -3.25), Color("#ff9c65"), "Cab")
	_box(truck, Vector3(3.2, 1.0, 0.15), Vector3(0, 2.15, -4.65), Color("#9fe3ff"), "Windshield")
	_box(truck, Vector3(4.2, 0.18, 0.18), Vector3(0, 0.35, -4.7), INK, "FrontBumper")
	_box(truck, Vector3(3.5, 0.12, 0.22), Vector3(0, 2.55, -3.45), Color("#ffd166"), "AnimeRoofStripe")
	_box(truck, Vector3(0.55, 0.5, 0.22), Vector3(-1.5, 2.72, -3.55), CORAL, "RoofLamp")
	_box(truck, Vector3(0.55, 0.5, 0.22), Vector3(1.5, 2.72, -3.55), CORAL, "RoofLamp")
	_box(truck, Vector3(1.8, 0.8, 0.16), Vector3(0, 1.45, 4.52), Color("#ffcf5c"), "AnimeCargoBadge")
	_box(truck, Vector3(0.22, 1.4, 0.22), Vector3(-1.25, 3.1, -3.45), INK, "Antenna")
	_box(truck, Vector3(0.28, 0.62, 0.42), Vector3(-2.25, 1.85, -3.72), INK, "MirrorArm")
	_box(truck, Vector3(0.28, 0.62, 0.42), Vector3(2.25, 1.85, -3.72), INK, "MirrorArm")
	_box(truck, Vector3(1.8, 0.38, 0.16), Vector3(0, 0.86, -4.76), Color("#66728b"), "FrontGrille")
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

func _build_traffic() -> void:
	for i in 3:
		var car := Node3D.new()
		car.name = "Traffic_%d" % i
		car.position = Vector3(traffic_lanes[i], 0.55, truck.position.z - 24.0 - float(i) * 28.0)
		add_child(car)
		var body_size := Vector3(2.5, 1.15, 4.2)
		if traffic_types[i] == "van":
			body_size = Vector3(2.65, 1.7, 5.0)
		elif traffic_types[i] == "bus":
			body_size = Vector3(3.0, 2.5, 7.0)
		_box(car, body_size, Vector3.ZERO, [MINT, Color("#f4b86b"), Color("#bb86fc")][i], "Body")
		_box(car, Vector3(body_size.x * 0.72, body_size.y * 0.52, 1.2), Vector3(0, body_size.y * 0.48, -body_size.z * 0.16), Color("#9fe3ff"), "Glass")
		_cylinder(car, 0.36, body_size.x * 0.82, Vector3(-body_size.x * 0.40, 0, -body_size.z * 0.25), INK, "Wheel")
		_cylinder(car, 0.36, body_size.x * 0.82, Vector3(body_size.x * 0.40, 0, -body_size.z * 0.25), INK, "Wheel")
		var tail_lamp := _box(car, Vector3(0.30, 0.24, 0.12), Vector3(-body_size.x * 0.32, body_size.y * 0.12, body_size.z * 0.5), CORAL, "TrafficTailLamp")
		var tail_material := tail_lamp.material_override as StandardMaterial3D
		tail_material.emission_enabled = true
		tail_material.emission = CORAL
		tail_material.emission_energy_multiplier = 1.6
		traffic_lights.append(tail_lamp)
		var head_lamp := _box(car, Vector3(0.30, 0.24, 0.12), Vector3(body_size.x * 0.32, body_size.y * 0.12, -body_size.z * 0.5), Color("#fff0a7"), "TrafficHeadLamp")
		var head_material := head_lamp.material_override as StandardMaterial3D
		head_material.emission_enabled = true
		head_material.emission = Color("#fff0a7")
		head_material.emission_energy_multiplier = 1.8
		traffic_lights.append(head_lamp)
		traffic.append(car)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 7.6, 15.0)
	camera.rotation_degrees = Vector3(-17, 180, 0)
	camera.near = 0.1
	camera.far = 155.0
	camera.current = true
	add_child(camera)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	var top := ColorRect.new()
	top.color = Color(INK, 0.93)
	top.size = Vector2(1280, 94)
	layer.add_child(top)
	ui_route = _label(layer, Vector2(32, 12), 23, CREAM)
	ui_speed = _label(layer, Vector2(935, 17), 34, CREAM)
	ui_stats = _label(layer, Vector2(32, 52), 16, Color("#c0cde4"))
	ui_toast = _label(layer, Vector2(470, 115), 20, CREAM)
	ui_toast.size = Vector2(340, 44)
	ui_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minimap = Control.new()
	minimap.name = "RouteMinimap"
	minimap.position = Vector2(28, 110)
	minimap.size = Vector2(270, 170)
	minimap.set_script(load("res://scripts/minimap.gd"))
	layer.add_child(minimap)
	var hint := _label(layer, Vector2(32, 650), 15, Color("#d5dded"))
	hint.text = "触摸按钮驾驶  •  左右变道  •  避开车辆  •  到达目的地交付货物"
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
	pause_button.pressed.connect(_toggle_pause)
	layer.add_child(pause_button)
	var camera_button := Button.new()
	camera_button.text = "视角"
	camera_button.position = Vector2(1118, 18)
	camera_button.size = Vector2(70, 52)
	camera_button.process_mode = Node.PROCESS_MODE_ALWAYS
	camera_button.add_theme_font_size_override("font_size", 16)
	camera_button.pressed.connect(_toggle_camera_mode)
	layer.add_child(camera_button)
	var garage_button := Button.new()
	garage_button.text = "车库"
	garage_button.position = Vector2(1035, 18)
	garage_button.size = Vector2(72, 52)
	garage_button.process_mode = Node.PROCESS_MODE_ALWAYS
	garage_button.add_theme_font_size_override("font_size", 16)
	garage_button.pressed.connect(_toggle_garage)
	layer.add_child(garage_button)
	var settings_button := Button.new()
	settings_button.text = "设置"
	settings_button.position = Vector2(950, 18)
	settings_button.size = Vector2(72, 52)
	settings_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_button.add_theme_font_size_override("font_size", 16)
	settings_button.pressed.connect(_toggle_settings)
	layer.add_child(settings_button)
	_build_garage_panel(layer)
	_build_settings_panel(layer)
	_update_ui()

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
	layer.add_child(garage_panel)
	garage_label = Label.new()
	garage_label.position = Vector2(20, 16)
	garage_label.size = Vector2(350, 42)
	garage_label.add_theme_font_size_override("font_size", 18)
	garage_label.add_theme_color_override("font_color", INK)
	garage_panel.add_child(garage_label)
	var upgrades := ["发动机", "轮胎", "油箱", "装甲"]
	for i in upgrades.size():
		var button := Button.new()
		button.text = upgrades[i] + "升级  €" + str(500 + i * 150)
		button.position = Vector2(18, 68 + i * 50)
		button.size = Vector2(350, 40)
		button.add_theme_font_size_override("font_size", 16)
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
	var target_speed := throttle * max_speed - braking * (12.0 + float(tire_level) * 0.8)
	speed = lerp(speed, max(target_speed, 0.0), delta * 3.8)
	var steering_grip := 1.0 + float(tire_level) * 0.08
	truck.position.x = clamp(truck.position.x + steer * delta * 6.4 * steering_grip, -4.0, 4.0)
	truck.rotation.z = lerp(truck.rotation.z, -steer * 0.075, delta * 8.0)
	truck.rotation.x = lerp(truck.rotation.x, sin(Time.get_ticks_msec() * 0.006) * speed * 0.0018, delta * 4.0)
	for wheel in wheel_nodes:
		wheel.rotation.x -= speed * delta * 1.8
	distance += speed * delta * 0.016
	truck.position.z -= speed * delta * 0.7
	_update_refueling(delta)
	var fuel_capacity := 100.0 + float(tank_level) * 10.0
	fuel = max(0.0, fuel - speed * delta * 0.0014)
	time_left = max(0.0, time_left - delta)
	thunder_cooldown -= delta
	if braking > 0.2 and speed > 2.0 and not brake_player.playing:
		brake_player.play()
	for i in traffic.size():
		var car := traffic[i]
		car.position.z += speed * delta * 0.7 * traffic_speeds[i]
		if car.position.z > truck.position.z + 22.0:
			car.position.z = truck.position.z - 100.0 - float(i) * 20.0
			car.position.x = traffic_lanes[i]
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
	_update_day_night()
	_update_weather_visuals()
	_update_weather_audio(delta)
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
		road_material.albedo_color = road_material.albedo_color.lerp(Color("#29364d"), 0.12)
		road_material.roughness = lerp(road_material.roughness, 0.18, 0.08)
		road_material.metallic = lerp(road_material.metallic, 0.22, 0.08)
	elif current_weather == "snow":
		road_material.albedo_color = road_material.albedo_color.lerp(Color("#8d9caf"), 0.10)
		road_material.roughness = lerp(road_material.roughness, 0.68, 0.08)
		road_material.metallic = lerp(road_material.metallic, 0.04, 0.08)
	else:
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

func _update_scene_name() -> void:
	var z := truck.position.z
	if z > 70.0:
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
	camera.look_at(look_target, Vector3.UP)

func _complete_delivery() -> void:
	money += 640
	toast = "DELIVERY COMPLETE   +€640"
	toast_time = 4.0
	_haptic(220, 0.9)
	distance = 0.0
	cargo_index = (cargo_index + 1) % 3
	route_goal = 10.0 + float(cargo_index * 2)
	destination = ["INNSBRUCK", "MILAN", "LYON"][cargo_index]
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
	ui_route.text = "%s   •   CONTRACT  /  %s  →  %s" % [current_scene, cargo, destination]
	ui_speed.text = "%02d km/h" % int(speed * 4.4)
	var weather_name := {"clear": "晴", "rain": "雨", "snow": "雪"}.get(current_weather, "多云")
	ui_stats.text = "TIME %s   •   %s   •   ROUTE %.1f / %.1f km   •   FUEL %d%%   •   DAMAGE %d%%   •   € %d" % [_format_clock(), weather_name, distance, route_goal, int(fuel), int(damage), money]
	ui_toast.text = toast if toast_time > 0.0 else ""
	if minimap:
		minimap.update_state(truck.position.x, distance, route_goal, current_scene, destination)
