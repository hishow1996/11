extends Node3D

# 漫漫货运 3D — Android-friendly third-person truck driving prototype.
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
var best_distance := 0.0
var achievements: Dictionary = {}
var delivery_count := 0
var leaderboard: Array = []
var damage := 0.0
var route_goal := 12.0
var cargo_index := 0
var livery_index := 0
var destination := "LUCERNE"
var task_index := 0
var task_distance_goal := 12.0
var task_time_limit := 184.0
var task_title := "普通货运"
var task_cargo := "普通货运"
var task_condition := "delivery"
var task_time_remaining := 184.0
var task_reward := 640
var task_active := false
var task_score := 100.0
var task_incidents := 0
var task_peak_speed := 0.0
var task_score_cooldown := 0.0
var game_started := false
var start_flow_layer: CanvasLayer
var start_flow_root: Control
var start_flow_design: Control
var start_flow_backdrop: ColorRect
var game_hud_layer: CanvasLayer
var intro_panel: Control
var main_menu_panel: Control
var menu_v2_panel: Control
var loading_bar: ProgressBar
var intro_logo: Label
var menu_status: Label
var task_combo := 0.0
var best_task_combo := 0.0
var last_delivery_grade := "—"
var last_delivery_payout := 0
var task_button: Button
var freight_market_panel: Panel
var freight_market_list: VBoxContainer
var freight_market_status: Label
var freight_offers: Array[Dictionary] = []
var freight_selected_offer: Dictionary = {}
var freight_detail_title: Label
var freight_detail_text: Label
var freight_accept_button: Button
var freight_category_filter := "全部"
var freight_sort_descending := true
var freight_sort_button: Button
var headlight_mode_button: Button
var time_left := 184.0
var paused := false
var camera_toggle_cooldown := 0.0
var traffic: Array[Node3D] = []
var traffic_lanes := [-3.2, 0.0, 3.2, -3.2, 3.2, 0.0]
var traffic_speeds := [0.82, 1.05, 0.68, 0.92, 0.76, 1.12]
var traffic_types := ["car", "van", "bus", "wagon", "coach", "service"]
var traffic_lane_targets: Array[float] = []
var traffic_lane_cooldowns: Array[float] = []
var traffic_lights: Array[MeshInstance3D] = []
var traffic_tail_lamps: Array[MeshInstance3D] = []
var traffic_turn_lamps: Array[MeshInstance3D] = []
var traffic_signal_lamps: Array[MeshInstance3D] = []
var pedestrian_nodes: Array[Node3D] = []
var toast := "READY TO HAUL"
var toast_time := 3.0
var ui_speed: Label
var ui_route: Label
var ui_stats: Label
var ui_toast: Label
var ui_grade_flash: Label
var engine_player: AudioStreamPlayer
var bgm_player: AudioStreamPlayer
var radio_button: Button
var radio_station := 1
var radio_station_names := ["电台 OFF", "轻快频道", "燃向频道"]
var radio_station_paths := ["", "res://audio/bgm_route_loop.wav", "res://audio/bgm_burn_loop.wav"]
var brake_player: AudioStreamPlayer
var rain_player: AudioStreamPlayer
var wind_player: AudioStreamPlayer
var wet_tire_player: AudioStreamPlayer
var snow_tire_player: AudioStreamPlayer
var spatial_tire_player: AudioStreamPlayer3D
var thunder_player: AudioStreamPlayer
var sfx_players: Dictionary = {}
var virtual_controls: Control
var minimap: Control
var scenery: Array[Node3D] = []
var current_scene := "乡村公路"
var current_weather := "clear"
var weather_intensity := 0.0
var weather_target_intensity := 0.0
var thunder_cooldown := 18.0
var weather_event_cooldown := 24.0
var weather_event_remaining := 0.0
var weather_event_type := ""
var game_hour := 8.0
var day_length_seconds := 420.0
var world_environment: WorldEnvironment
var environment: Environment
var sun: DirectionalLight3D
var moon: DirectionalLight3D
var star_particles: GPUParticles3D
var star_material: StandardMaterial3D
var rain_particles: GPUParticles3D
var snow_particles: GPUParticles3D
var sakura_particles: GPUParticles3D
var speed_lines: GPUParticles3D
var lightning_light: OmniLight3D
var delivery_flash: OmniLight3D
var collision_sparks: GPUParticles3D
var collision_smoke: GPUParticles3D
var collision_debris: GPUParticles3D
var sky_material: ProceduralSkyMaterial
var road_surface: MeshInstance3D
var city_lights: Array[OmniLight3D] = []
var wheel_nodes: Array[MeshInstance3D] = []
var authored_wheel_nodes: Array[Node3D] = []
var authored_front_wheels: Array[Node3D] = []
var authored_livery_parts: Array[MeshInstance3D] = []
var authored_headlamps: Array[MeshInstance3D] = []
var authored_brake_lamps: Array[MeshInstance3D] = []
var authored_signal_lamps: Array[MeshInstance3D] = []
var headlight_nodes: Array[OmniLight3D] = []
var road_puddles: Array[MeshInstance3D] = []
var hit_shake := 0.0
var collision_effect_cooldown := 0.0
var guardrail_audio_cooldown := 0.0
var puddle_audio_active := false
var wet_lateral_slip := 0.0
var wet_skid_cooldown := 0.0
var last_gear := 0
var last_indicator_on := false
var previous_wiper_active := false
var wiper_audio_cooldown := 0.0
var delivery_camera_boost := 0.0
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
var settings_panel: Variant
var quality_mode := 1
var traffic_ai_frame := 0
var steering_sensitivity := 1.0
var master_volume := 0.8
var music_volume := 0.8
var sfx_volume := 0.8
var control_scale := 1.0
var control_opacity := 0.84
var touch_steer := 0.0
var touch_throttle := 0.0
var touch_brake := 0.0
var manual_turn_left := false
var manual_turn_right := false
var hazard_lights := false
var horn_active := false
var high_beam := false
var drive_mode := "D"
var reverse_mode := false
var brake_input_was_active := false
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
var windshield_glass: MeshInstance3D
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
const SAVE_BACKUP_PATH := "user://anime_haul_save.backup.json"
const SAVE_TEMP_PATH := "user://anime_haul_save.tmp.json"
var ROAD_CLEAR_TEXTURE = load("res://art/runtime/road_surface.png")
var ROAD_WET_TEXTURE = load("res://art/runtime/road_wet.png")
var ROAD_SNOW_TEXTURE = load("res://art/runtime/road_snow.png")
var RAIN_STREAK_TEXTURE = load("res://art/runtime/rain_streak.png")
var SNOW_FLAKE_TEXTURE = load("res://art/runtime/snow_flake.png")
var ORANGE_LIVERY_TEXTURE = load("res://art/runtime/truck_livery_orange.png")
var BLUE_LIVERY_TEXTURE = load("res://art/runtime/truck_livery_blue.png")
var UI_FUEL_TEXTURE = load("res://art/runtime/ui_fuel.png")
var UI_WEATHER_TEXTURE = load("res://art/runtime/ui_weather.png")
var UI_ROUTE_TEXTURE = load("res://art/runtime/ui_route.png")
var LANDMARK_CITY_TEXTURE = load("res://art/runtime/landmark_city.png")
var LANDMARK_RURAL_TEXTURE = load("res://art/runtime/landmark_rural.png")
var LANDMARK_FOREST_TEXTURE = load("res://art/runtime/landmark_forest.png")
var LANDMARK_MOUNTAIN_TEXTURE = load("res://art/runtime/landmark_mountain.png")
var LANDMARK_PLAINS_TEXTURE = load("res://art/runtime/landmark_plains.png")
var FACILITY_FUEL_TEXTURE = load("res://art/runtime/facility_fuel.png")
var FACILITY_REPAIR_TEXTURE = load("res://art/runtime/facility_repair.png")
var TRAFFIC_CAR_TEXTURE = load("res://art/runtime/traffic_car.png")
var TRAFFIC_VAN_TEXTURE = load("res://art/runtime/traffic_van.png")
var TRAFFIC_BUS_TEXTURE = load("res://art/runtime/traffic_bus.png")
var PLAYER_TRUCK_LOD0 = load("res://assets/vehicles/player_truck/player_truck_lod0.glb")
var PLAYER_TRUCK_LOD1 = load("res://assets/vehicles/player_truck/player_truck_lod1.glb")
var PLAYER_TRUCK_LOD2 = load("res://assets/vehicles/player_truck/player_truck_lod2.glb")

func _ready() -> void:
	_load_save()
	_build_environment()
	_build_weather_effects()
	_build_collision_effects()
	_build_world()
	_build_truck()
	_build_traffic()
	_build_camera()
	_build_ui()
	_build_audio()
	_apply_quality(quality_mode)
	_apply_sensitivity(steering_sensitivity)
	_apply_volume(master_volume)
	_build_start_flow()
	call_deferred("_play_start_flow")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()

func _load_save() -> void:
	for load_path in [SAVE_PATH, SAVE_BACKUP_PATH]:
		if not FileAccess.file_exists(load_path):
			continue
		var file: Variant = FileAccess.open(load_path, FileAccess.READ)
		if file == null:
			continue
		var data = JSON.parse_string(file.get_as_text())
		if data is Dictionary:
			_apply_save_data(data)
			return

func _apply_save_data(data: Dictionary) -> void:
	money = max(0, int(data.get("money", money)))
	best_distance = max(0.0, float(data.get("best_distance", best_distance)))
	achievements = data.get("achievements", {})
	if not achievements is Dictionary:
		achievements = {}
	delivery_count = max(0, int(data.get("delivery_count", delivery_count)))
	leaderboard = data.get("leaderboard", leaderboard)
	if not leaderboard is Array:
		leaderboard = []
	fuel = clamp(float(data.get("fuel", fuel)), 0.0, 200.0)
	damage = clamp(float(data.get("damage", damage)), 0.0, 100.0)
	distance = max(0.0, float(data.get("distance", distance)))
	cargo_index = clamp(int(data.get("cargo_index", cargo_index)), 0, 2)
	livery_index = clamp(int(data.get("livery_index", livery_index)), 0, 1)
	game_hour = fmod(max(0.0, float(data.get("game_hour", game_hour))), 24.0)
	engine_level = clamp(int(data.get("engine_level", engine_level)), 0, 5)
	tire_level = clamp(int(data.get("tire_level", tire_level)), 0, 5)
	tank_level = clamp(int(data.get("tank_level", tank_level)), 0, 5)
	armor_level = clamp(int(data.get("armor_level", armor_level)), 0, 5)
	quality_mode = clamp(int(data.get("quality_mode", quality_mode)), 0, 2)
	steering_sensitivity = clamp(float(data.get("steering_sensitivity", steering_sensitivity)), 0.55, 1.6)
	master_volume = clamp(float(data.get("master_volume", master_volume)), 0.0, 1.0)
	music_volume = clamp(float(data.get("music_volume", music_volume)), 0.0, 1.0)
	sfx_volume = clamp(float(data.get("sfx_volume", sfx_volume)), 0.0, 1.0)
	radio_station = clamp(int(data.get("radio_station", radio_station)), 0, 2)
	control_scale = clamp(float(data.get("control_scale", control_scale)), 0.75, 1.35)
	control_opacity = clamp(float(data.get("control_opacity", control_opacity)), 0.35, 1.0)
	route_goal = 10.0 + float(cargo_index * 2)
	destination = ["LUCERNE", "INNSBRUCK", "MILAN"][cargo_index]
	task_index = clamp(int(data.get("task_index", task_index)), 0, 3)
	_setup_task(task_index)
	task_title = str(data.get("task_title", task_title))
	destination = str(data.get("destination", destination))
	task_distance_goal = float(data.get("task_distance_goal", task_distance_goal))
	task_time_limit = float(data.get("task_time_limit", task_time_limit))
	task_reward = int(data.get("task_reward", task_reward))
	task_condition = str(data.get("task_condition", task_condition))
	task_cargo = str(data.get("task_cargo", task_cargo))
	task_time_remaining = clamp(float(data.get("task_time_remaining", task_time_remaining)), 0.0, task_time_limit)
	task_active = bool(data.get("task_active", task_active))
	route_goal = task_distance_goal
	task_score = clamp(float(data.get("task_score", task_score)), 0.0, 100.0)
	task_incidents = max(0, int(data.get("task_incidents", task_incidents)))
	task_peak_speed = max(0.0, float(data.get("task_peak_speed", task_peak_speed)))
	task_combo = max(0.0, float(data.get("task_combo", task_combo)))
	best_task_combo = max(0.0, float(data.get("best_task_combo", best_task_combo)))
	last_delivery_grade = str(data.get("last_delivery_grade", last_delivery_grade))
	last_delivery_payout = max(0, int(data.get("last_delivery_payout", last_delivery_payout)))
	high_beam = bool(data.get("high_beam", high_beam))
	drive_mode = str(data.get("drive_mode", drive_mode))
	if drive_mode not in ["D", "N", "R"]:
		drive_mode = "D"

func _save_game() -> void:
	var data: Variant = {
		"money": money,
		"best_distance": best_distance,
		"achievements": achievements,
		"delivery_count": delivery_count,
		"leaderboard": leaderboard,
		"fuel": fuel,
		"damage": damage,
		"distance": distance,
		"cargo_index": cargo_index,
		"livery_index": livery_index,
		"task_index": task_index,
		"task_title": task_title,
		"destination": destination,
		"task_distance_goal": task_distance_goal,
		"task_time_limit": task_time_limit,
		"task_reward": task_reward,
		"task_condition": task_condition,
		"task_cargo": task_cargo,
		"task_time_remaining": task_time_remaining,
		"task_active": task_active,
		"task_score": task_score,
		"task_incidents": task_incidents,
		"task_peak_speed": task_peak_speed,
		"task_combo": task_combo,
		"best_task_combo": best_task_combo,
		"last_delivery_grade": last_delivery_grade,
		"last_delivery_payout": last_delivery_payout,
		"high_beam": high_beam,
		"drive_mode": drive_mode,
		"game_hour": game_hour,
		"engine_level": engine_level,
		"tire_level": tire_level,
		"tank_level": tank_level,
		"armor_level": armor_level,
		"quality_mode": quality_mode,
		"steering_sensitivity": steering_sensitivity,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"radio_station": radio_station,
		"control_scale": control_scale,
		"control_opacity": control_opacity
	}
	if FileAccess.file_exists(SAVE_TEMP_PATH):
		DirAccess.remove_absolute(SAVE_TEMP_PATH)
	var temp_file: Variant = FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if temp_file == null:
		return
	temp_file.store_string(JSON.stringify(data))
	temp_file.close()
	if FileAccess.file_exists(SAVE_PATH):
		var previous_bytes: PackedByteArray = FileAccess.get_file_as_bytes(SAVE_PATH)
		var backup_file: Variant = FileAccess.open(SAVE_BACKUP_PATH, FileAccess.WRITE)
		if backup_file:
			backup_file.store_buffer(previous_bytes)
			backup_file.close()
	DirAccess.rename_absolute(SAVE_TEMP_PATH, SAVE_PATH)

func _haptic(duration_ms: int, amplitude: float) -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(duration_ms, amplitude)

func _mat(color: Color, roughness := 0.82) -> StandardMaterial3D:
	var material: Variant = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.62 if color == ASPHALT else roughness
	material.metallic = 0.08 if color == ASPHALT else 0.0
	material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return material

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, name := "Box") -> MeshInstance3D:
	var outlined_parts: Variant = ["Trailer", "Cab", "Windshield", "FrontBumper", "TrailerStripe", "Body", "Glass", "Lamp", "CabSideWindow", "BumperLamp", "CityBalcony"]
	var mesh: Variant = BoxMesh.new()
	mesh.size = size
	if name in outlined_parts:
		var outline_mesh: Variant = BoxMesh.new()
		outline_mesh.size = size * 1.075
		var outline: Variant = MeshInstance3D.new()
		outline.name = name + "_AnimeOutline"
		outline.mesh = outline_mesh
		outline.material_override = _mat(INK, 1.0)
		outline.position = pos
		parent.add_child(outline)
	var node: Variant = MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	parent.add_child(node)
	return node

func _cylinder(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color, name := "Cylinder") -> MeshInstance3D:
	var mesh: Variant = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	if name in ["FrontWheel", "RearWheel", "Wheel", "Hub"]:
		var outline_mesh: Variant = CylinderMesh.new()
		outline_mesh.top_radius = radius * 1.11
		outline_mesh.bottom_radius = radius * 1.11
		outline_mesh.height = height * 1.08
		var outline: Variant = MeshInstance3D.new()
		outline.name = name + "_AnimeOutline"
		outline.mesh = outline_mesh
		outline.material_override = _mat(INK, 1.0)
		outline.position = pos
		parent.add_child(outline)
	var node: Variant = MeshInstance3D.new()
	node.name = name
	node.mesh = mesh
	node.material_override = _mat(color)
	node.position = pos
	parent.add_child(node)
	return node

func _cone(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color, name := "Cone") -> MeshInstance3D:
	var mesh: Variant = CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	var node: Variant = MeshInstance3D.new()
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
	var sky: Variant = Sky.new()
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
	environment.adjustment_enabled = true
	environment.adjustment_brightness = 1.04
	environment.adjustment_contrast = 1.08
	environment.adjustment_saturation = 1.12
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
	star_particles = _star_particles()

func _star_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "NightSkyStars"
	particles.amount = 140
	particles.lifetime = 30.0
	particles.local_coords = true
	particles.emitting = false
	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(42.0, 10.0, 42.0)
	process_material.direction = Vector3.ZERO
	process_material.initial_velocity_min = 0.0
	process_material.initial_velocity_max = 0.0
	process_material.gravity = Vector3.ZERO
	process_material.scale_min = 0.45
	process_material.scale_max = 1.25
	var star_mesh := QuadMesh.new()
	star_mesh.size = Vector2(0.055, 0.055)
	star_material = StandardMaterial3D.new()
	star_material.albedo_color = Color(0.88, 0.94, 1.0, 0.0)
	star_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	star_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	star_mesh.material = star_material
	particles.process_material = process_material
	particles.draw_pass_1 = star_mesh
	particles.visibility_aabb = AABB(Vector3(-45, -4, -45), Vector3(90, 24, 90))
	add_child(particles)
	return particles

func _build_weather_effects() -> void:
	rain_particles = _weather_particles("RainParticles", Color("#a8d8ff"), 420, 0.75, 28.0)
	snow_particles = _weather_particles("SnowParticles", Color("#fff7df"), 260, 4.5, 2.2)
	sakura_particles = _sakura_particles()
	speed_lines = _speed_line_particles()
	lightning_light = OmniLight3D.new()
	lightning_light.name = "LightningFlash"
	lightning_light.light_color = Color("#e8f4ff")
	lightning_light.light_energy = 0.0
	lightning_light.omni_range = 55.0
	lightning_light.position = Vector3(0, 12, -20)
	add_child(lightning_light)
	delivery_flash = OmniLight3D.new()
	delivery_flash.name = "DeliveryAnimeFlash"
	delivery_flash.light_color = Color("#ffd166")
	delivery_flash.light_energy = 0.0
	delivery_flash.omni_range = 14.0
	delivery_flash.position = Vector3(0, 3.0, -4.0)
	add_child(delivery_flash)

func _weather_particles(name: String, color: Color, amount: int, lifetime: float, velocity: float) -> GPUParticles3D:
	var particles: Variant = GPUParticles3D.new()
	particles.name = name
	particles.amount = amount
	particles.lifetime = lifetime
	particles.local_coords = true
	particles.emitting = false
	var process_material: Variant = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, -1, 0)
	process_material.initial_velocity_min = velocity * 0.72
	process_material.initial_velocity_max = velocity
	process_material.gravity = Vector3(0, -2.0 if name == "RainParticles" else -0.45, 0)
	process_material.scale_min = 0.045 if name == "RainParticles" else 0.10
	process_material.scale_max = 0.075 if name == "RainParticles" else 0.18
	process_material.color = color
	particles.process_material = process_material
	var quad: Variant = QuadMesh.new()
	quad.size = Vector2(0.045, 0.28) if name == "RainParticles" else Vector2(0.16, 0.16)
	var material: Variant = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.texture = RAIN_STREAK_TEXTURE if name == "RainParticles" else SNOW_FLAKE_TEXTURE
	quad.material = material
	particles.draw_pass_1 = quad
	particles.position = Vector3(0, 10, 0)
	particles.visibility_aabb = AABB(Vector3(-18, -2, -24), Vector3(36, 22, 48))
	add_child(particles)
	return particles

func _sakura_particles() -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = "SakuraPetalParticles"
	particles.amount = 180
	particles.lifetime = 5.5
	particles.local_coords = true
	particles.emitting = false
	var process_material := ParticleProcessMaterial.new()
	process_material.direction = Vector3(0.18, -0.22, 0.12)
	process_material.spread = 42.0
	process_material.initial_velocity_min = 0.7
	process_material.initial_velocity_max = 2.6
	process_material.gravity = Vector3(0, -0.32, 0)
	process_material.scale_min = 0.08
	process_material.scale_max = 0.16
	process_material.color = Color("#ffb7cf")
	var petal := QuadMesh.new()
	petal.size = Vector2(0.16, 0.08)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#ffb7cf")
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	petal.material = material
	particles.process_material = process_material
	particles.draw_pass_1 = petal
	particles.position = Vector3(0, 8, 0)
	particles.visibility_aabb = AABB(Vector3(-22, -2, -28), Vector3(44, 18, 56))
	add_child(particles)
	return particles

func _speed_line_particles() -> GPUParticles3D:
	var particles: Variant = GPUParticles3D.new()
	particles.name = "AnimeSpeedLines"
	particles.amount = 90
	particles.lifetime = 0.7
	particles.emitting = false
	var process_material: Variant = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, 0, 1)
	process_material.spread = 24.0
	process_material.initial_velocity_min = 6.0
	process_material.initial_velocity_max = 12.0
	process_material.gravity = Vector3.ZERO
	process_material.color = Color(0.75, 0.9, 1.0, 0.52)
	particles.process_material = process_material
	var mesh: Variant = QuadMesh.new()
	mesh.size = Vector2(0.035, 0.72)
	var material: Variant = StandardMaterial3D.new()
	material.albedo_color = Color(0.75, 0.9, 1.0, 0.52)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mesh.material = material
	particles.draw_pass_1 = mesh
	particles.visibility_aabb = AABB(Vector3(-10, -3, -10), Vector3(20, 8, 30))
	add_child(particles)
	return particles

func _build_collision_effects() -> void:
	collision_sparks = _collision_particles("CollisionSparks", Color("#ffd166"), 28, 0.7, 8.0, 0.05)
	collision_smoke = _collision_particles("CollisionSmoke", Color(0.45, 0.48, 0.56, 0.42), 18, 1.6, 1.5, 0.22)
	collision_debris = _collision_particles("CollisionDebris", Color("#66728b"), 18, 1.1, 4.0, 0.12)

func _collision_particles(name: String, color: Color, amount: int, lifetime: float, velocity: float, size: float) -> GPUParticles3D:
	var particles: Variant = GPUParticles3D.new()
	particles.name = name
	particles.amount = amount
	particles.lifetime = lifetime
	particles.emitting = false
	var process_material: Variant = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, 0.7, 1)
	process_material.spread = 55.0
	process_material.initial_velocity_min = velocity * 0.45
	process_material.initial_velocity_max = velocity
	process_material.gravity = Vector3(0, -5.0 if name != "CollisionSmoke" else 0.8, 0)
	process_material.scale_min = 0.5
	process_material.scale_max = 1.2
	process_material.color = color
	particles.process_material = process_material
	var mesh: PrimitiveMesh = SphereMesh.new() if name == "CollisionSmoke" else BoxMesh.new()
	if mesh is SphereMesh:
		(mesh as SphereMesh).radius = size
		(mesh as SphereMesh).height = size * 2.0
	else:
		(mesh as BoxMesh).size = Vector3.ONE * size
	var material: Variant = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if color.a < 0.9 else BaseMaterial3D.TRANSPARENCY_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	particles.draw_pass_1 = mesh
	particles.visibility_aabb = AABB(Vector3(-6, -3, -6), Vector3(12, 10, 12))
	add_child(particles)
	return particles

func _build_world() -> void:
	var ground: Variant = _box(self, Vector3(180, 0.4, ROAD_LENGTH), Vector3(0, -0.35, -ROAD_LENGTH * 0.25), Color("#9bb07f"), "Grass")
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
	var rail: Variant = Node3D.new()
	rail.position = pos
	add_child(rail)
	_box(rail, Vector3(0.12, 0.75, 11.5), Vector3.ZERO, Color("#aeb8c5"), "Guardrail")
	for post_z in [-4.5, 0.0, 4.5]:
		_box(rail, Vector3(0.16, 0.9, 0.16), Vector3(0, -0.35, post_z), INK, "GuardPost")

func _add_reflector(pos: Vector3) -> void:
	var reflector: Variant = _box(self, Vector3(0.10, 0.22, 0.06), pos, Color("#ffe28a"), "RoadReflector")
	var material: Variant = reflector.material_override as StandardMaterial3D
	material.emission_enabled = true
	material.emission = Color("#ffb84d")
	material.emission_energy_multiplier = 1.8

func _add_puddle(pos: Vector3, width: float) -> void:
	var puddle: Variant = _box(self, Vector3(width, 0.018, 1.6 + width), pos, Color("#526d88"), "RoadPuddle")
	var puddle_material: Variant = puddle.material_override as StandardMaterial3D
	puddle_material.roughness = 0.08
	puddle_material.metallic = 0.52
	puddle_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puddle_material.albedo_color = Color(0.20, 0.32, 0.45, 0.52)
	road_puddles.append(puddle)

func _add_road_crack(pos: Vector3, length: float) -> void:
	var crack: Variant = _box(self, Vector3(0.045, 0.012, length), pos, Color("#252b3d"), "RoadCrack")
	crack.rotation_degrees.y = -18.0 + fmod(abs(pos.z), 36.0)

func _add_chevron_pair(z: float) -> void:
	for side in [-1.0, 1.0]:
		var sign_root: Variant = Node3D.new()
		sign_root.position = Vector3(side * 7.25, 0, z)
		add_child(sign_root)
		_box(sign_root, Vector3(0.12, 1.7, 0.12), Vector3(0, 0.85, 0), INK, "ChevronPost")
		var board: Variant = _box(sign_root, Vector3(0.9, 0.5, 0.10), Vector3(0, 1.8, 0), Color("#ffd166"), "ChevronBoard")
		board.rotation_degrees.y = 0.0 if side < 0.0 else 180.0

func _add_direction_sign(pos: Vector3, text_hint: String) -> void:
	var sign_root: Variant = Node3D.new()
	sign_root.position = pos
	add_child(sign_root)
	_box(sign_root, Vector3(0.18, 3.0, 0.18), Vector3(0, 1.5, 0), INK, "SignPost")
	_box(sign_root, Vector3(2.6, 1.0, 0.12), Vector3(0, 3.15, 0), Color("#3478a8"), "DirectionSign")
	_box(sign_root, Vector3(1.6, 0.12, 0.05), Vector3(0, 3.15, -0.08), CREAM, "SignStripe")

func _add_city_lamp(parent: Node3D, pos: Vector3) -> void:
	_box(parent, Vector3(0.16, 4.4, 0.16), pos + Vector3(0, 2.2, 0), INK, "StreetLamp")
	_box(parent, Vector3(1.0, 0.16, 0.16), pos + Vector3(0.35, 4.35, 0), INK, "LampArm")
	var glow: Variant = _box(parent, Vector3(0.34, 0.18, 0.34), pos + Vector3(0.78, 4.25, 0), Color("#ffd166"), "LampGlow")
	var glow_material: Variant = glow.material_override as StandardMaterial3D
	glow_material.emission_enabled = true
	glow_material.emission = Color("#ff9a42")
	glow_material.emission_energy_multiplier = 2.5
	var point_light: Variant = OmniLight3D.new()
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
		var block: Variant = Node3D.new()
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
				var window: Variant = _box(block, Vector3(1.1, 0.65, 0.18), Vector3(window_x, window_y, -3.55), Color("#9fe3ff"), "CityWindow")
				if int(abs(z) + window_y + window_x) % 3 == 0:
					var window_material: Variant = window.material_override as StandardMaterial3D
					window_material.emission_enabled = true
					window_material.emission = Color("#ffd166")
					window_material.emission_energy_multiplier = 1.8
		_add_city_lamp(block, Vector3(0, 0, -5.0))
		_register_scenery(block)

func _add_fuel_station(pos: Vector3, label_text: String) -> void:
	var station: Variant = Node3D.new()
	station.position = pos
	add_child(station)
	station_positions.append(pos)
	_box(station, Vector3(7.5, 0.12, 8.0), Vector3.ZERO, Color("#5b6d73"), "StationLot")
	_box(station, Vector3(6.0, 0.28, 2.2), Vector3(0, 3.4, 0), Color("#ef6f61"), "StationCanopy")
	for pump_x in [-2.0, 0.0, 2.0]:
		_box(station, Vector3(0.8, 1.6, 0.8), Vector3(pump_x, 0.9, 0), Color("#d5dded"), "FuelPump")
		var pump_light: Variant = _box(station, Vector3(0.38, 0.22, 0.12), Vector3(pump_x, 1.65, -0.42), Color("#74d0ad"), "PumpLight")
		var pump_material: Variant = pump_light.material_override as StandardMaterial3D
		pump_material.emission_enabled = true
		pump_material.emission = Color("#74d0ad")
		pump_material.emission_energy_multiplier = 2.0
	_box(station, Vector3(1.0, 4.0, 0.5), Vector3(3.9, 2.0, 0), Color("#ffd166"), "FuelSign")
	_box(station, Vector3(0.8, 0.18, 0.12), Vector3(3.9, 3.25, -0.28), CREAM, "FuelSignStripe")
	_register_scenery(station)

func _add_repair_station(pos: Vector3) -> void:
	var station: Variant = Node3D.new()
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
	var tower: Variant = Node3D.new()
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
		var signal_root: Variant = Node3D.new()
		signal_root.position = Vector3(side * 6.9, 0, z - 2.0)
		add_child(signal_root)
		_box(signal_root, Vector3(0.18, 4.0, 0.18), Vector3(0, 2.0, 0), INK, "TrafficPole")
		var red: Variant = _box(signal_root, Vector3(0.42, 0.42, 0.25), Vector3(0, 4.2, 0), CORAL, "TrafficRed")
		var red_material: Variant = red.material_override as StandardMaterial3D
		red_material.emission_enabled = true
		red_material.emission = CORAL
		red_material.emission_energy_multiplier = 1.5

func _add_bridge(z: float) -> void:
	var bridge: Variant = Node3D.new()
	bridge.position = Vector3(0, 0, z)
	add_child(bridge)
	_box(bridge, Vector3(22.0, 0.6, 10.0), Vector3(0, -0.05, 0), Color("#66728b"), "BridgeDeck")
	for side in [-1.0, 1.0]:
		_box(bridge, Vector3(0.3, 1.6, 10.0), Vector3(side * 7.0, 0.9, 0), Color("#aeb8c5"), "BridgeRail")
		for pillar_z in [-3.0, 3.0]:
			_box(bridge, Vector3(0.45, 5.0, 0.45), Vector3(side * 5.5, -2.5, pillar_z), INK, "BridgePillar")
	_register_scenery(bridge)

func _add_village_farm(z: float) -> void:
	var farm: Variant = Node3D.new()
	farm.position = Vector3(-12.0, 0, z)
	add_child(farm)
	_box(farm, Vector3(8.0, 3.2, 7.0), Vector3.ZERO, Color("#f4b86b"), "FarmHouse")
	_box(farm, Vector3(8.5, 0.3, 7.5), Vector3(0, 1.9, 0), CORAL, "FarmRoof")
	for row in 4:
		_box(farm, Vector3(7.0, 0.08, 0.35), Vector3(0, 0.08, -4.0 + row * 2.0), Color("#c78c55"), "CropRow")
	_register_scenery(farm)
	var silo: Variant = Node3D.new()
	silo.position = Vector3(13.0, 1.5, z + 4.0)
	add_child(silo)
	_cylinder(silo, 1.6, 5.5, Vector3.ZERO, Color("#d5dded"), "Silo")
	_register_scenery(silo)

func _add_village_landmark(z: float) -> void:
	var mill: Variant = Node3D.new()
	mill.position = Vector3(11.5, 0, z - 3.0)
	add_child(mill)
	_box(mill, Vector3(1.4, 5.5, 1.4), Vector3(0, 2.75, 0), Color("#f4b86b"), "WindmillTower")
	for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
		var blade: Variant = _box(mill, Vector3(0.18, 3.4, 0.12), Vector3(0, 5.8, 0), CREAM, "WindmillBlade")
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
	var boulder: Variant = Node3D.new()
	boulder.position = Vector3(-10.8, 0.9, z - 3.0)
	boulder.scale = Vector3(1.4, 0.8, 1.1)
	add_child(boulder)
	_cylinder(boulder, 1.4, 2.0, Vector3.ZERO, Color("#4a5268"), "ForestBoulder")
	var log: Variant = _box(self, Vector3(1.0, 0.8, 4.8), Vector3(11.0, 0.45, z + 2.0), Color("#78533c"), "FallenLog")
	log.rotation_degrees.y = 18.0

func _add_mountain_pass(z: float) -> void:
	for side in [-1.0, 1.0]:
		var cliff: Variant = Node3D.new()
		cliff.position = Vector3(side * 14.0, 3.5, z)
		cliff.scale = Vector3(1.0, 1.4 + fmod(abs(z), 3.0) * 0.15, 1.0)
		add_child(cliff)
		_cylinder(cliff, 5.0, 10.0, Vector3.ZERO, Color("#66728b"), "RockWall")
		_cylinder(cliff, 3.2, 0.4, Vector3(0, 5.2, 0), Color("#f5f2df"), "SnowEdge")
		_register_scenery(cliff)

func _add_mountain_landmark(z: float) -> void:
	var tunnel: Variant = Node3D.new()
	tunnel.position = Vector3(0, 0, z - 4.5)
	add_child(tunnel)
	_box(tunnel, Vector3(13.0, 5.5, 1.2), Vector3(0, 2.75, 0), Color("#38405b"), "TunnelFace")
	_box(tunnel, Vector3(7.0, 3.5, 1.4), Vector3(0, 1.4, -0.7), INK, "TunnelOpening")
	for x in [-4.0, -2.0, 0.0, 2.0, 4.0]:
		var lamp: Variant = _box(tunnel, Vector3(0.28, 0.28, 0.18), Vector3(x, 3.8, -1.0), Color("#fff0a7"), "TunnelLamp")
		var lamp_material: Variant = lamp.material_override as StandardMaterial3D
		lamp_material.emission_enabled = true
		lamp_material.emission = Color("#fff0a7")
		lamp_material.emission_energy_multiplier = 2.0
	_register_scenery(tunnel)

func _add_mountain_warning(z: float) -> void:
	for side in [-1.0, 1.0]:
		var sign: Variant = Node3D.new()
		sign.position = Vector3(side * 6.9, 0, z + 2.5)
		add_child(sign)
		_box(sign, Vector3(0.12, 2.0, 0.12), Vector3(0, 1.0, 0), INK, "WarningPost")
		_box(sign, Vector3(0.9, 0.65, 0.12), Vector3(0, 2.0, 0), Color("#ffd166"), "MountainWarning")

func _add_plain_field(z: float) -> void:
	for side in [-1.0, 1.0]:
		var field: Variant = Node3D.new()
		field.position = Vector3(side * 13.0, 0, z)
		add_child(field)
		_box(field, Vector3(10.0, 0.08, 9.0), Vector3.ZERO, Color("#d8b867"), "WheatField")
		for row in 5:
			_box(field, Vector3(0.12, 0.5, 7.5), Vector3(-4.0 + row * 2.0, 0.3, 0), Color("#a67c43"), "WheatRow")
		_register_scenery(field)

func _add_plain_landmark(z: float) -> void:
	var lake: Variant = _box(self, Vector3(15.0, 0.06, 7.0), Vector3(-14.0, 0.02, z), Color("#5fb5d0"), "PlainLake")
	var lake_material: Variant = lake.material_override as StandardMaterial3D
	lake_material.roughness = 0.12
	lake_material.metallic = 0.35
	for side in [-1.0, 1.0]:
		var turbine: Variant = Node3D.new()
		turbine.position = Vector3(side * 15.0, 0, z + 2.0)
		add_child(turbine)
		_box(turbine, Vector3(0.2, 7.0, 0.2), Vector3(0, 3.5, 0), Color("#d5dded"), "TurbinePole")
		for angle in [0.0, PI * 0.666, PI * 1.333]:
			var blade: Variant = _box(turbine, Vector3(0.12, 2.4, 0.1), Vector3(0, 7.0, 0), CREAM, "TurbineBlade")
			blade.rotation_degrees.z = rad_to_deg(angle)

func _add_mountain_cluster(pos: Vector3, scale_factor: float) -> void:
	var root: Variant = Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * scale_factor
	add_child(root)
	var cone: Variant = _cone(root, 7.0, 18.0, Vector3(0, 8.8, 0), Color("#53617d"), "Mountain")
	var snow: Variant = _cone(root, 3.6, 5.0, Vector3(0, 17.2, 0), Color("#f5f2df"), "SnowCap")
	cone.rotation_degrees.y = 22.0
	snow.rotation_degrees.y = 22.0

func _add_tree(pos: Vector3, scale_factor: float) -> void:
	var tree: Variant = Node3D.new()
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
	var trailer_body: Variant = _box(truck, Vector3(4.9, 2.25, 7.2), Vector3(0, 1.35, 0.9), CREAM, "Trailer")
	var trailer_stripe: Variant = _box(truck, Vector3(4.98, 0.36, 7.0), Vector3(0, 2.28, 0.9), CORAL, "TrailerStripe")
	var cab_body: Variant = _box(truck, Vector3(4.0, 2.7, 2.7), Vector3(0, 1.55, -3.25), Color("#ff9c65"), "Cab")
	truck_livery_parts.append(trailer_body)
	truck_livery_parts.append(trailer_stripe)
	truck_livery_parts.append(cab_body)
	_box(truck, Vector3(3.2, 1.0, 0.15), Vector3(0, 2.15, -4.65), Color("#9fe3ff"), "Windshield")
	_box(truck, Vector3(4.2, 0.18, 0.18), Vector3(0, 0.35, -4.7), INK, "FrontBumper")
	_box(truck, Vector3(3.5, 0.12, 0.22), Vector3(0, 2.55, -3.45), Color("#ffd166"), "AnimeRoofStripe")
	_box(truck, Vector3(0.55, 0.5, 0.22), Vector3(-1.5, 2.72, -3.55), CORAL, "RoofLamp")
	_box(truck, Vector3(0.55, 0.5, 0.22), Vector3(1.5, 2.72, -3.55), CORAL, "RoofLamp")
	var cargo_badge: Variant = _box(truck, Vector3(1.8, 0.8, 0.16), Vector3(0, 1.45, 4.52), Color("#ffcf5c"), "AnimeCargoBadge")
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
		var bumper_lamp: Variant = _box(truck, Vector3(0.34, 0.16, 0.12), Vector3(bumper_x, 0.44, -4.9), Color("#fff0a7"), "BumperLamp")
		var bumper_material: Variant = bumper_lamp.material_override as StandardMaterial3D
		bumper_material.emission_enabled = true
		bumper_material.emission = Color("#fff0a7")
		bumper_material.emission_energy_multiplier = 2.0
	for x in [-2.1, 2.1]:
		var front_wheel: Variant = _cylinder(truck, 0.62, 0.42, Vector3(x, 0.62, -2.8), INK, "FrontWheel")
		front_wheel.rotation_degrees.z = 90.0
		wheel_nodes.append(front_wheel)
		var rear_wheel: Variant = _cylinder(truck, 0.62, 0.42, Vector3(x, 0.62, 2.5), INK, "RearWheel")
		rear_wheel.rotation_degrees.z = 90.0
		wheel_nodes.append(rear_wheel)
	for x in [-2.1, 2.1]:
		var front_hub: Variant = _cylinder(truck, 0.25, 0.44, Vector3(x, 0.62, -2.8), Color("#ffce68"), "Hub")
		front_hub.rotation_degrees.z = 90.0
		var rear_hub: Variant = _cylinder(truck, 0.25, 0.44, Vector3(x, 0.62, 2.5), Color("#ffce68"), "Hub")
		rear_hub.rotation_degrees.z = 90.0
	var exhaust: Variant = _cylinder(truck, 0.22, 0.9, Vector3(-1.55, 1.15, 4.65), INK, "ExhaustPipe")
	exhaust.rotation_degrees.x = 90.0
	exhaust_particles = _build_exhaust_particles()
	for lamp_x in [-1.6, 1.6]:
		var lamp: Variant = _box(truck, Vector3(0.3, 0.3, 0.2), Vector3(lamp_x, 1.8, -4.65), Color("#fff0a7"), "Lamp")
		var lamp_material: Variant = lamp.material_override as StandardMaterial3D
		lamp_material.emission_enabled = true
		lamp_material.emission = Color("#fff0a7")
		lamp_material.emission_energy_multiplier = 3.0
		var headlight: Variant = OmniLight3D.new()
		headlight.position = Vector3(lamp_x, 1.75, -5.1)
		headlight.light_color = Color("#fff0b2")
		headlight.light_energy = 0.0
		headlight.omni_range = 18.0
		headlight.shadow_enabled = false
		truck.add_child(headlight)
		headlight_nodes.append(headlight)
		var brake_lamp: Variant = _box(truck, Vector3(0.32, 0.26, 0.16), Vector3(lamp_x, 1.65, 4.58), CORAL, "BrakeLamp")
		brake_lamps.append(brake_lamp)
		var signal_lamp: Variant = _box(truck, Vector3(0.22, 0.22, 0.16), Vector3(lamp_x, 1.95, 4.58), Color("#ff9a42"), "SignalLamp")
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
		var cargo_label: Variant = _label3d(truck, "MOUNTAIN TEA", Vector3(side * 2.57, 1.48, 0.9), CREAM, 26)
		cargo_label.rotation_degrees = Vector3(0, 90.0 if side < 0.0 else -90.0, 0)
		cargo_label.modulate = Color("#fff1cf")
		cargo_decal_labels.append(cargo_label)
		var badge_light: Variant = _box(truck, Vector3(0.06, 0.24, 0.65), Vector3(side * 2.63, 1.52, 0.9), Color("#ffd166"), "CargoBadgeLight")
		var badge_material: Variant = badge_light.material_override as StandardMaterial3D
		badge_material.emission_enabled = true
		badge_material.emission = Color("#ffd166")
		badge_material.emission_energy_multiplier = 0.0
		cargo_badge_lights.append(badge_light)
	for side in [-1.0, 1.0]:
		for trailer_z in [-2.8, -1.0, 0.8, 2.6, 4.1]:
			var reflector: Variant = _box(truck, Vector3(0.07, 0.20, 0.48), Vector3(side * 2.66, 0.82, trailer_z), Color("#ef6f61"), "TrailerReflector")
			var reflector_material: Variant = reflector.material_override as StandardMaterial3D
			reflector_material.emission_enabled = true
			reflector_material.emission = Color("#ef6f61")
			reflector_material.emission_energy_multiplier = 0.0
			safety_reflectors.append(reflector)
	for stripe_index in range(6):
		var warning_stripe: Variant = _box(truck, Vector3(0.34, 0.10, 0.08), Vector3(-1.1 + stripe_index * 0.44, 0.62, 4.72), Color("#ffd166" if stripe_index % 2 == 0 else CORAL), "RearWarningStripe")
		warning_stripe.rotation_degrees.y = 20.0 if stripe_index % 2 == 0 else -20.0
		var plate: Variant = _label3d(truck, "AH-2048", Vector3(0, 0.68, 4.82), CREAM, 18)
		plate.rotation_degrees = Vector3(0, 180, 0)
		_build_cockpit_interior()
		_attach_authored_truck_lods()

func _attach_authored_truck_lods() -> void:
	# The authored GLB is the visible exterior; procedural geometry remains available
	# as a safe fallback for Android builds and continues to drive lights/instruments.
	for child in truck.get_children():
		if child is GeometryInstance3D or child is Label3D or child is GPUParticles3D:
			child.visible = false
	var lods: Variant = [PLAYER_TRUCK_LOD0, PLAYER_TRUCK_LOD1, PLAYER_TRUCK_LOD2]
	var ranges: Variant = [[0.0, 18.0], [18.0, 55.0], [55.0, 130.0]]
	for i in lods.size():
		var lod_scene: Variant = lods[i] as PackedScene
		if lod_scene == null:
			continue
		var authored: Variant = lod_scene.instantiate() as Node3D
		if authored == null:
			continue
		authored.name = "AuthoredTruckLOD%d" % i
		authored.position = Vector3.ZERO
		authored.scale = Vector3.ONE
		truck.add_child(authored)
		for geometry in authored.find_children("*", "GeometryInstance3D", true, false):
			var instance: Variant = geometry as GeometryInstance3D
			if instance is MeshInstance3D and instance.material_override == null:
				var source_material: Variant = (instance as MeshInstance3D).get_active_material(0)
				if source_material:
					instance.material_override = source_material.duplicate()
			if instance is MeshInstance3D:
				var cel_material: Variant = (instance as MeshInstance3D).material_override as BaseMaterial3D
				if cel_material:
					cel_material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
					cel_material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
					cel_material.roughness = 0.72
					cel_material.metallic = 0.0
			instance.visibility_range_begin = ranges[i][0]
			instance.visibility_range_end = ranges[i][1]
			instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			if instance.name.begins_with("Wheel_"):
				authored_wheel_nodes.append(instance)
				if instance.name in ["Wheel_1", "Wheel_2"]:
					authored_front_wheels.append(instance)
			if instance.name in ["Cab_Body", "Trailer_Body"] and instance is MeshInstance3D:
				authored_livery_parts.append(instance)
			if instance.name == "Headlight" and instance is MeshInstance3D:
				authored_headlamps.append(instance)
			if instance.name == "Brake_Lamp" and instance is MeshInstance3D:
				authored_brake_lamps.append(instance)
			if instance.name == "Signal_Lamp" and instance is MeshInstance3D:
				authored_signal_lamps.append(instance)
	_apply_livery(livery_index)

func _label3d(parent: Node3D, text_value: String, pos: Vector3, color: Color, size: int = 32) -> Label3D:
	var label: Variant = Label3D.new()
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
	var cabin: Variant = Node3D.new()
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
		windshield_glass = _box(cabin, Vector3(3.35, 1.55, 0.05), Vector3(0, 2.42, -4.56), Color("#9fd7e8", 0.10), "WindshieldGlass")
		var glass_material: Variant = windshield_glass.material_override as StandardMaterial3D
		glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		glass_material.roughness = 0.12
		glass_material.metallic = 0.04
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
		var mirror: Variant = _box(cabin, Vector3(0.72, 0.42, 0.08), Vector3(side * 2.0, 2.25, -3.55), Color("#74a9c4"), "InteriorMirror")
		var mirror_mesh: Variant = PlaneMesh.new()
		mirror_mesh.size = Vector2(0.72, 0.42)
		mirror.mesh = mirror_mesh
		mirror.rotation_degrees.x = 90.0
		mirror.rotation_degrees.y = side * 12.0
		var mirror_viewport: Variant = SubViewport.new()
		mirror_viewport.name = "MirrorViewport_%s" % ("L" if side < 0.0 else "R")
		mirror_viewport.size = Vector2i(256, 128)
		mirror_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		mirror_viewport.handle_input_locally = false
		mirror_viewport.world_3d = get_viewport().world_3d
		cabin.add_child(mirror_viewport)
		var mirror_camera: Variant = Camera3D.new()
		mirror_camera.name = "MirrorCamera"
		mirror_camera.fov = 62.0
		mirror_camera.near = 0.2
		mirror_camera.far = 90.0
		mirror_viewport.add_child(mirror_camera)
		mirror_camera.current = true
		var mirror_material: Variant = StandardMaterial3D.new()
		mirror_material.albedo_texture = mirror_viewport.get_texture()
		mirror_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mirror_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		mirror_material.roughness = 0.18
		mirror.material_override = mirror_material
		interior_mirrors.append(mirror)
		mirror_viewports.append(mirror_viewport)
		mirror_cameras.append(mirror_camera)
		_box(cabin, Vector3(0.10, 0.62, 0.10), Vector3(side * 1.72, 1.95, -3.48), INK, "MirrorMount")
	# Twin windshield wiper arms visibly sweep in rain and snow.
	for side in [-1.0, 1.0]:
		var wiper: Variant = _box(cabin, Vector3(0.10, 0.92, 0.08), Vector3(side * 0.86, 1.98, -4.48), INK, "WindshieldWiper")
		wiper.rotation_degrees.z = side * 18.0
		interior_wipers.append(wiper)
	# Warm cabin lamps are dimmed at daytime and brightened at night.
	for side in [-1.0, 1.0]:
		var lamp: Variant = _box(cabin, Vector3(0.22, 0.06, 0.16), Vector3(side * 0.8, 2.35, -1.7), Color("#ffd166"), "CabinLamp")
		var lamp_material: Variant = lamp.material_override as StandardMaterial3D
		lamp_material.emission_enabled = true
		lamp_material.emission = Color("#ffd166")
		interior_lamps.append(lamp)
	# Anime driver: readable silhouette, hair, face highlights and uniform trim.
	var driver: Variant = Node3D.new()
	driver.name = "AnimeDriver"
	driver.position = Vector3(-0.92, 0.0, -2.05)
	cabin.add_child(driver)
	_box(driver, Vector3(0.88, 1.05, 0.52), Vector3(0, 1.05, 0), Color("#4f78bd"), "DriverBody")
	_box(driver, Vector3(0.94, 0.16, 0.58), Vector3(0, 1.58, -0.02), CORAL, "DriverScarf")
	var driver_head: Variant = SphereMesh.new()
	driver_head.radius = 0.34
	driver_head.height = 0.68
	var driver_head_node: Variant = MeshInstance3D.new()
	driver_head_node.name = "DriverHead"
	driver_head_node.mesh = driver_head
	driver_head_node.material_override = _mat(Color("#ffd8b0"))
	driver_head_node.position = Vector3(0, 1.88, -0.04)
	driver.add_child(driver_head_node)
	_cone(driver, 0.42, 0.32, Vector3(0, 2.25, -0.02), Color("#263456"), "DriverHair")
	_box(driver, Vector3(0.08, 0.08, 0.04), Vector3(-0.13, 1.95, -0.31), INK, "DriverEye")
	_box(driver, Vector3(0.08, 0.08, 0.04), Vector3(0.13, 1.95, -0.31), INK, "DriverEye")
	_box(driver, Vector3(0.18, 0.05, 0.04), Vector3(0, 1.82, -0.32), CORAL, "DriverMouth")
	_box(driver, Vector3(0.18, 0.66, 0.18), Vector3(-0.62, 1.28, -0.65), INK, "DriverArm")
	_box(driver, Vector3(0.18, 0.66, 0.18), Vector3(0.18, 1.28, -0.65), INK, "DriverArm")
	_apply_livery(livery_index)

func _apply_livery(index: int) -> void:
	var liveries: Variant = [
		[Color("#ff9c65"), CORAL, Color("#ffcf5c")],
		[Color("#6f9fe8"), Color("#536fc2"), MINT],
		[Color("#6bbf91"), Color("#397a68"), Color("#ffd166")],
		[Color("#a88bd8"), Color("#6f5ca8"), Color("#9fe3ff")]
	]
	var palette: Array = liveries[abs(index) % liveries.size()]
	var livery_texture: Texture2D = ORANGE_LIVERY_TEXTURE if abs(index) % 2 == 0 else BLUE_LIVERY_TEXTURE
	for part_index in truck_livery_parts.size():
		var part_material: Variant = truck_livery_parts[part_index].material_override as StandardMaterial3D
		part_material.albedo_color = palette[part_index % palette.size()]
		part_material.albedo_texture = livery_texture if part_index < 2 else null
		part_material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	var cargo_names: Variant = ["MOUNTAIN TEA", "STRAWBERRY JAM", "ALPINE PARTS"]
	for label in cargo_decal_labels:
		label.text = cargo_names[abs(index) % cargo_names.size()]
		for badge_light in cargo_badge_lights:
			var badge_material: Variant = badge_light.material_override as StandardMaterial3D
			badge_material.albedo_color = palette[2]
			badge_material.emission = palette[2]
		for part in authored_livery_parts:
			var authored_material: Variant = part.material_override as StandardMaterial3D
			if authored_material:
				authored_material.albedo_color = palette[0] if part.name == "Cab_Body" else palette[1]
				authored_material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
		if interior_nav_display:
			interior_nav_display.modulate = palette[2]

func _build_exhaust_particles() -> GPUParticles3D:
	var particles: Variant = GPUParticles3D.new()
	particles.name = "ExhaustSmoke"
	particles.amount = 18
	particles.lifetime = 1.8
	particles.emitting = true
	var process_material: Variant = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0, 1, 1)
	process_material.initial_velocity_min = 0.25
	process_material.initial_velocity_max = 0.7
	process_material.gravity = Vector3(0, 0.15, 0)
	process_material.scale_min = 0.08
	process_material.scale_max = 0.18
	process_material.color = Color(0.55, 0.58, 0.64, 0.28)
	particles.process_material = process_material
	var quad: Variant = QuadMesh.new()
	quad.size = Vector2(0.22, 0.22)
	var material: Variant = StandardMaterial3D.new()
	material.albedo_color = Color(0.55, 0.58, 0.64, 0.28)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	quad.material = material
	particles.draw_pass_1 = quad
	particles.position = Vector3(-1.55, 1.65, 4.7)
	truck.add_child(particles)
	return particles

func _build_traffic() -> void:
	for i in traffic_types.size():
		var car: Variant = Node3D.new()
		car.name = "Traffic_%d" % i
		car.position = Vector3(traffic_lanes[i], 0.55, truck.position.z - 24.0 - float(i) * 28.0)
		add_child(car)
		var body_size: Variant = Vector3(2.5, 1.15, 4.2)
		if traffic_types[i] == "van" or traffic_types[i] == "service":
			body_size = Vector3(2.65, 1.7, 5.0)
		elif traffic_types[i] == "bus" or traffic_types[i] == "coach":
			body_size = Vector3(3.0, 2.5, 7.0)
		elif traffic_types[i] == "wagon":
			body_size = Vector3(2.55, 1.35, 4.8)
		var traffic_colors: Variant = [MINT, Color("#f4b86b"), Color("#bb86fc"), Color("#ef6f61"), Color("#9fe3ff"), Color("#ffd166")]
		var traffic_body: Variant = _box(car, body_size, Vector3.ZERO, traffic_colors[i], "Body")
		var traffic_material: Variant = traffic_body.material_override as StandardMaterial3D
		if traffic_types[i] == "van" or traffic_types[i] == "service":
			traffic_material.albedo_texture = TRAFFIC_VAN_TEXTURE
		elif traffic_types[i] == "bus" or traffic_types[i] == "coach":
			traffic_material.albedo_texture = TRAFFIC_BUS_TEXTURE
		else:
			traffic_material.albedo_texture = TRAFFIC_CAR_TEXTURE
		_box(car, Vector3(body_size.x * 0.72, body_size.y * 0.52, 1.2), Vector3(0, body_size.y * 0.48, -body_size.z * 0.16), Color("#9fe3ff"), "Glass")
		_cylinder(car, 0.36, body_size.x * 0.82, Vector3(-body_size.x * 0.40, 0, -body_size.z * 0.25), INK, "Wheel")
		_cylinder(car, 0.36, body_size.x * 0.82, Vector3(body_size.x * 0.40, 0, -body_size.z * 0.25), INK, "Wheel")
		var tail_lamp: Variant = _box(car, Vector3(0.30, 0.24, 0.12), Vector3(-body_size.x * 0.32, body_size.y * 0.12, body_size.z * 0.5), CORAL, "TrafficTailLamp")
		var tail_material: Variant = tail_lamp.material_override as StandardMaterial3D
		tail_material.emission_enabled = true
		tail_material.emission = CORAL
		tail_material.emission_energy_multiplier = 1.6
		traffic_lights.append(tail_lamp)
		traffic_tail_lamps.append(tail_lamp)
		var head_lamp: Variant = _box(car, Vector3(0.30, 0.24, 0.12), Vector3(body_size.x * 0.32, body_size.y * 0.12, -body_size.z * 0.5), Color("#fff0a7"), "TrafficHeadLamp")
		var head_material: Variant = head_lamp.material_override as StandardMaterial3D
		head_material.emission_enabled = true
		head_material.emission = Color("#fff0a7")
		head_material.emission_energy_multiplier = 1.8
		traffic_lights.append(head_lamp)
		var turn_lamp: Variant = _box(car, Vector3(0.18, 0.16, 0.10), Vector3(-body_size.x * 0.36, body_size.y * 0.18, body_size.z * 0.5), Color("#ffb35c"), "TrafficTurnLamp")
		var turn_material: Variant = turn_lamp.material_override as StandardMaterial3D
		turn_material.emission_enabled = true
		turn_material.emission = Color("#ffb35c")
		turn_material.emission_energy_multiplier = 2.0
		turn_lamp.visible = false
		traffic_turn_lamps.append(turn_lamp)
		traffic_lane_targets.append(traffic_lanes[i])
		traffic_lane_cooldowns.append(0.0)
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
	game_hud_layer = CanvasLayer.new()
	var layer: Variant = game_hud_layer
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	var top: Variant = ColorRect.new()
	top.color = Color(INK, 0.0)
	top.size = Vector2(1, 1)
	layer.add_child(top)
	_hud_card(layer, Vector2(330, 22), Vector2(292, 142), Color("#211c37", 0.92))
	_hud_card(layer, Vector2(970, 22), Vector2(112, 92), Color("#211c37", 0.94))
	_hud_card(layer, Vector2(1090, 22), Vector2(166, 92), Color("#211c37", 0.94))
	_hud_card(layer, Vector2(970, 124), Vector2(286, 118), Color("#211c37", 0.90))
	_hud_icon(layer, UI_ROUTE_TEXTURE, Vector2(332, 42), Vector2(28, 28))
	_hud_icon(layer, UI_FUEL_TEXTURE, Vector2(978, 70), Vector2(24, 24))
	_hud_icon(layer, UI_WEATHER_TEXTURE, Vector2(1100, 70), Vector2(24, 24))
	ui_route = _label(layer, Vector2(350, 40), 18, CREAM)
	ui_route.size = Vector2(252, 112)
	ui_route.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_speed = _label(layer, Vector2(988, 34), 34, CREAM)
	ui_speed.size = Vector2(76, 56)
	ui_speed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_stats = _label(layer, Vector2(990, 137), 14, Color("#c0cde4"))
	ui_stats.size = Vector2(260, 98)
	ui_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui_toast = _label(layer, Vector2(470, 206), 20, CREAM)
	ui_toast.size = Vector2(340, 44)
	ui_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_grade_flash = _label(layer, Vector2(430, 270), 30, CREAM)
	ui_grade_flash.size = Vector2(420, 116)
	ui_grade_flash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_grade_flash.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ui_grade_flash.visible = false
	var grade_style := StyleBoxFlat.new()
	grade_style.bg_color = Color(INK, 0.94)
	grade_style.border_color = Color("#ffd166")
	grade_style.set_border_width_all(4)
	grade_style.set_corner_radius_all(24)
	ui_grade_flash.add_theme_stylebox_override("normal", grade_style)
	task_button = Button.new()
	task_button.position = Vector2(650, 24)
	task_button.size = Vector2(150, 48)
	task_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(task_button)
	task_button.pressed.connect(_toggle_freight_market)
	layer.add_child(task_button)
	radio_button = Button.new()
	radio_button.position = Vector2(650, 78)
	radio_button.size = Vector2(150, 38)
	radio_button.add_theme_font_size_override("font_size", 14)
	_style_ui_button(radio_button)
	radio_button.pressed.connect(_cycle_radio_station)
	layer.add_child(radio_button)
	_set_radio_station(radio_station, false)
	headlight_mode_button = Button.new()
	headlight_mode_button.position = Vector2(810, 24)
	headlight_mode_button.size = Vector2(108, 48)
	headlight_mode_button.add_theme_font_size_override("font_size", 15)
	_style_ui_button(headlight_mode_button)
	headlight_mode_button.pressed.connect(_toggle_high_beam)
	layer.add_child(headlight_mode_button)
	minimap = Control.new()
	minimap.name = "RouteMinimap"
	minimap.position = Vector2(24, 22)
	minimap.size = Vector2(292, 190)
	minimap.set_script(load("res://scripts/minimap.gd"))
	layer.add_child(minimap)
	var hint: Variant = _label(layer, Vector2(330, 174), 13, Color("#d5dded"))
	hint.text = "触摸驾驶  •  左右变道  •  避开交通  •  到达目的地交付"
	virtual_controls = Control.new()
	virtual_controls.name = "AnalogDrivingControls"
	virtual_controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	virtual_controls.mouse_filter = Control.MOUSE_FILTER_PASS
	virtual_controls.set_script(load("res://scripts/virtual_controls.gd"))
	virtual_controls.steering_changed.connect(_on_touch_steering)
	virtual_controls.throttle_changed.connect(_on_touch_throttle)
	virtual_controls.brake_changed.connect(_on_touch_brake)
	virtual_controls.turn_left_pressed.connect(_on_turn_left_pressed)
	virtual_controls.turn_right_pressed.connect(_on_turn_right_pressed)
	virtual_controls.hazard_pressed.connect(_on_hazard_pressed)
	virtual_controls.horn_changed.connect(_on_horn_changed)
	virtual_controls.gear_changed.connect(_on_gear_changed)
	virtual_controls.gear_mode = drive_mode
	virtual_controls.set_layout(control_scale, control_opacity, Vector2.ZERO)
	layer.add_child(virtual_controls)
	var pause_button: Variant = Button.new()
	pause_button.text = "Ⅱ"
	pause_button.position = Vector2(1197, 202)
	pause_button.size = Vector2(52, 52)
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.add_theme_font_size_override("font_size", 23)
	_style_ui_button(pause_button)
	pause_button.pressed.connect(_toggle_pause)
	layer.add_child(pause_button)
	var camera_button: Variant = Button.new()
	camera_button.text = "视角"
	camera_button.position = Vector2(1118, 202)
	camera_button.size = Vector2(70, 52)
	camera_button.process_mode = Node.PROCESS_MODE_ALWAYS
	camera_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(camera_button)
	camera_button.pressed.connect(_toggle_camera_mode)
	layer.add_child(camera_button)
	var garage_button: Variant = Button.new()
	garage_button.text = "车库"
	garage_button.position = Vector2(1035, 202)
	garage_button.size = Vector2(72, 52)
	garage_button.process_mode = Node.PROCESS_MODE_ALWAYS
	garage_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(garage_button)
	garage_button.pressed.connect(_toggle_garage)
	layer.add_child(garage_button)
	var settings_button: Variant = Button.new()
	settings_button.text = "设置"
	settings_button.position = Vector2(950, 202)
	settings_button.size = Vector2(72, 52)
	settings_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(settings_button)
	settings_button.pressed.connect(_toggle_settings)
	layer.add_child(settings_button)
	_build_garage_panel(layer)
	_build_settings_panel(layer)
	_build_freight_market(layer)
	_update_ui()

func _build_freight_market(layer: CanvasLayer) -> void:
	freight_market_panel = Panel.new()
	freight_market_panel.position = Vector2(170, 42)
	freight_market_panel.size = Vector2(940, 636)
	freight_market_panel.visible = false
	freight_market_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(INK, 0.97)
	panel_style.border_color = Color("#ffd166")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(24)
	freight_market_panel.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(freight_market_panel)
	var title := Label.new()
	title.text = "货运市场  /  可用合同"
	title.position = Vector2(28, 20)
	title.size = Vector2(470, 42)
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", CREAM)
	freight_market_panel.add_child(title)
	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.position = Vector2(804, 20)
	close_button.size = Vector2(112, 42)
	close_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(close_button)
	close_button.pressed.connect(_close_freight_market)
	freight_market_panel.add_child(close_button)
	freight_market_status = Label.new()
	freight_market_status.position = Vector2(28, 64)
	freight_market_status.size = Vector2(880, 28)
	freight_market_status.add_theme_font_size_override("font_size", 14)
	freight_market_status.add_theme_color_override("font_color", Color("#b8c7df"))
	freight_market_panel.add_child(freight_market_status)
	var filter_panel := Panel.new()
	filter_panel.position = Vector2(24, 108)
	filter_panel.size = Vector2(160, 498)
	var filter_style := StyleBoxFlat.new()
	filter_style.bg_color = Color("#252e50", 0.96)
	filter_style.set_corner_radius_all(16)
	filter_panel.add_theme_stylebox_override("panel", filter_style)
	freight_market_panel.add_child(filter_panel)
	var filter_title := Label.new()
	filter_title.text = "合同筛选"
	filter_title.position = Vector2(18, 18)
	filter_title.size = Vector2(124, 28)
	filter_title.add_theme_font_size_override("font_size", 17)
	filter_title.add_theme_color_override("font_color", CREAM)
	filter_panel.add_child(filter_title)
	var filters: Array = ["全部", "普通货运", "限时急件", "天气敏感", "高价值"]
	for i in filters.size():
		var filter_button := Button.new()
		filter_button.text = filters[i]
		filter_button.position = Vector2(14, 62 + i * 54)
		filter_button.size = Vector2(132, 42)
		filter_button.add_theme_font_size_override("font_size", 14)
		_style_ui_button(filter_button)
		filter_button.pressed.connect(func(): _set_freight_filter(filters[i]))
		filter_panel.add_child(filter_button)
	var list_title := Label.new()
	list_title.text = "路线合同"
	list_title.position = Vector2(208, 110)
	list_title.size = Vector2(390, 30)
	list_title.add_theme_font_size_override("font_size", 18)
	list_title.add_theme_color_override("font_color", CREAM)
	freight_market_panel.add_child(list_title)
	freight_sort_button = Button.new()
	freight_sort_button.position = Vector2(470, 104)
	freight_sort_button.size = Vector2(146, 32)
	freight_sort_button.add_theme_font_size_override("font_size", 13)
	_style_ui_button(freight_sort_button)
	freight_sort_button.pressed.connect(_toggle_freight_price_sort)
	freight_market_panel.add_child(freight_sort_button)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(208, 148)
	scroll.size = Vector2(408, 452)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	freight_market_panel.add_child(scroll)
	freight_market_list = VBoxContainer.new()
	freight_market_list.add_theme_constant_override("separation", 10)
	freight_market_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(freight_market_list)
	var detail_panel := Panel.new()
	detail_panel.position = Vector2(634, 108)
	detail_panel.size = Vector2(278, 498)
	var detail_style := StyleBoxFlat.new()
	detail_style.bg_color = Color("#252e50", 0.96)
	detail_style.border_color = Color("#52688f")
	detail_style.set_border_width_all(1)
	detail_style.set_corner_radius_all(16)
	detail_panel.add_theme_stylebox_override("panel", detail_style)
	freight_market_panel.add_child(detail_panel)
	freight_detail_title = Label.new()
	freight_detail_title.text = "合同详情"
	freight_detail_title.position = Vector2(18, 18)
	freight_detail_title.size = Vector2(240, 50)
	freight_detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	freight_detail_title.add_theme_font_size_override("font_size", 20)
	freight_detail_title.add_theme_color_override("font_color", CREAM)
	detail_panel.add_child(freight_detail_title)
	freight_detail_text = Label.new()
	freight_detail_text.position = Vector2(18, 82)
	freight_detail_text.size = Vector2(240, 270)
	freight_detail_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	freight_detail_text.add_theme_font_size_override("font_size", 14)
	freight_detail_text.add_theme_color_override("font_color", Color("#c0cde4"))
	detail_panel.add_child(freight_detail_text)
	freight_accept_button = Button.new()
	freight_accept_button.text = "接取这份合同"
	freight_accept_button.position = Vector2(18, 414)
	freight_accept_button.size = Vector2(240, 52)
	freight_accept_button.add_theme_font_size_override("font_size", 16)
	_style_ui_button(freight_accept_button)
	freight_accept_button.pressed.connect(_accept_selected_freight_offer)
	detail_panel.add_child(freight_accept_button)
	_generate_freight_offers()

func _generate_freight_offers() -> void:
	var routes: Array = [
		{"from": "慕尼黑", "to": "米兰", "cargo": "精密机械", "distance": 12.0, "time": 184.0, "reward": 920, "condition": "delivery", "risk": "普通"},
		{"from": "因斯布鲁克", "to": "苏黎世", "cargo": "冷藏鲜花", "distance": 8.0, "time": 150.0, "reward": 1080, "condition": "night", "risk": "夜行加成"},
		{"from": "里昂", "to": "日内瓦", "cargo": "医疗物资", "distance": 6.0, "time": 125.0, "reward": 1180, "condition": "rain", "risk": "天气敏感"},
		{"from": "维也纳", "to": "布拉格", "cargo": "动漫周边", "distance": 10.0, "time": 210.0, "reward": 760, "condition": "clean", "risk": "无损奖励"},
		{"from": "米兰", "to": "巴黎", "cargo": "高级轿车", "distance": 15.0, "time": 240.0, "reward": 1320, "condition": "clean", "risk": "高价值货物"}
	]
	freight_offers.clear()
	for i in routes.size():
		var route: Dictionary = routes[(i + task_index) % routes.size()].duplicate()
		route["offer_id"] = i
		freight_offers.append(route)
	_refresh_freight_market()

func _refresh_freight_market() -> void:
	if not freight_market_list:
		return
	for child in freight_market_list.get_children():
		child.queue_free()
	var visible_offers: Array[Dictionary] = []
	for offer in freight_offers:
		if freight_category_filter == "全部" or _freight_offer_category(offer) == freight_category_filter:
			visible_offers.append(offer)
	visible_offers.sort_custom(Callable(self, "_compare_freight_offer_price"))
	if freight_sort_button:
		freight_sort_button.text = "报酬：高 → 低" if freight_sort_descending else "报酬：低 → 高"
	for offer in visible_offers:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(390, 82)
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color("#303b5a", 0.96)
		card_style.border_color = Color("#52617e")
		card_style.set_border_width_all(1)
		card_style.set_corner_radius_all(14)
		card.add_theme_stylebox_override("panel", card_style)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		card.add_child(row)
		var details := Label.new()
		details.text = "%s → %s\n%s\n€%d  ·  %.1f km  ·  %ds" % [offer["from"], offer["to"], offer["cargo"], offer["reward"], offer["distance"], int(offer["time"])]
		details.custom_minimum_size = Vector2(270, 72)
		details.add_theme_font_size_override("font_size", 13)
		details.add_theme_color_override("font_color", CREAM)
		row.add_child(details)
		var inspect_button := Button.new()
		inspect_button.text = "查看"
		inspect_button.custom_minimum_size = Vector2(80, 48)
		inspect_button.add_theme_font_size_override("font_size", 14)
		_style_ui_button(inspect_button)
		inspect_button.pressed.connect(func(): _select_freight_offer(offer))
		row.add_child(inspect_button)
		freight_market_list.add_child(card)
	if freight_market_status:
		freight_market_status.text = "分类：%s  ·  可用合同 %d 份  ·  显示 %d 份  ·  %s" % [freight_category_filter, freight_offers.size(), visible_offers.size(), "按报酬从高到低" if freight_sort_descending else "按报酬从低到高"]
	if visible_offers.size() > 0:
		_select_freight_offer(visible_offers[0])
	else:
		freight_selected_offer = {}
		freight_detail_title.text = "暂无匹配合同"
		freight_detail_text.text = "调整左侧筛选条件后重试。"
		freight_accept_button.disabled = true

func _freight_offer_category(offer: Dictionary) -> String:
	if str(offer["risk"]).find("高价值") >= 0:
		return "高价值"
	if str(offer["condition"]) == "rain":
		return "天气敏感"
	if str(offer["condition"]) == "night" or float(offer["time"]) <= 150.0:
		return "限时急件"
	return "普通货运"

func _set_freight_filter(category: String) -> void:
	freight_category_filter = category
	_refresh_freight_market()

func _toggle_freight_price_sort() -> void:
	freight_sort_descending = not freight_sort_descending
	_refresh_freight_market()

func _compare_freight_offer_price(left: Dictionary, right: Dictionary) -> bool:
	var left_reward: int = int(left["reward"])
	var right_reward: int = int(right["reward"])
	if left_reward == right_reward:
		return int(left["offer_id"]) < int(right["offer_id"])
	return left_reward > right_reward if freight_sort_descending else left_reward < right_reward

func _select_freight_offer(offer: Dictionary) -> void:
	freight_selected_offer = offer
	freight_detail_title.text = "%s\n%s → %s" % [offer["cargo"], offer["from"], offer["to"]]
	freight_detail_text.text = "货物类型：%s\n运输距离：%.1f km\n预计时限：%d 秒\n基础报酬：€%d\n合同标签：%s\n\n驾驶评分、无损运输和天气条件会影响最终结算。" % [ _freight_offer_category(offer), offer["distance"], int(offer["time"]), offer["reward"], offer["risk"]]
	freight_accept_button.disabled = false

func _accept_selected_freight_offer() -> void:
	if not freight_selected_offer.is_empty():
		_accept_offer(freight_selected_offer)

func _toggle_freight_market() -> void:
	if task_active:
		toast = "当前合同运输中，抵达目的地后再接下一单"
		toast_time = 2.4
		return
	freight_market_panel.visible = not freight_market_panel.visible
	paused = freight_market_panel.visible
	if freight_market_panel.visible:
		_generate_freight_offers()

func _close_freight_market() -> void:
	freight_market_panel.visible = false
	paused = false

func _accept_offer(offer: Dictionary) -> void:
	if task_active:
		return
	task_title = str(offer["cargo"])
	task_cargo = str(offer["cargo"])
	destination = str(offer["to"])
	task_distance_goal = float(offer["distance"])
	route_goal = task_distance_goal
	task_time_limit = float(offer["time"])
	task_reward = int(offer["reward"])
	task_condition = str(offer["condition"])
	task_time_remaining = task_time_limit
	task_active = true
	distance = 0.0
	task_score = 100.0
	task_incidents = 0
	task_peak_speed = 0.0
	task_score_cooldown = 0.0
	task_combo = 0.0
	freight_market_panel.visible = false
	paused = false
	toast = "已接取合同：%s → %s" % [offer["cargo"], offer["to"]]
	toast_time = 3.0
	_play_sfx("ui_click", -10.0)
	_save_game()

func _build_start_flow() -> void:
	start_flow_layer = CanvasLayer.new()
	start_flow_layer.layer = 20
	start_flow_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(start_flow_layer)
	start_flow_root = Control.new()
	start_flow_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_flow_root.resized.connect(_layout_start_flow)
	start_flow_layer.add_child(start_flow_root)
	start_flow_design = Control.new()
	start_flow_design.size = Vector2(1280, 720)
	start_flow_root.add_child(start_flow_design)
	start_flow_backdrop = ColorRect.new()
	start_flow_backdrop.color = Color(INK, 0.82)
	start_flow_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_flow_design.add_child(start_flow_backdrop)
	intro_panel = Control.new()
	intro_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_flow_design.add_child(intro_panel)
	intro_logo = Label.new()
	intro_logo.text = "漫漫货运"
	intro_logo.position = Vector2(315, 238)
	intro_logo.size = Vector2(650, 92)
	intro_logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_logo.add_theme_font_size_override("font_size", 72)
	intro_logo.add_theme_color_override("font_color", CREAM)
	intro_logo.add_theme_color_override("font_shadow_color", CORAL)
	intro_logo.add_theme_constant_override("shadow_offset_x", 5)
	intro_logo.add_theme_constant_override("shadow_offset_y", 5)
	intro_panel.add_child(intro_logo)
	var subtitle := Label.new()
	subtitle.text = "动漫卡车运输冒险"
	subtitle.position = Vector2(390, 338)
	subtitle.size = Vector2(500, 34)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color("#ffb7cf"))
	intro_panel.add_child(subtitle)
	var loading_text := Label.new()
	loading_text.text = "正在准备路线与天气系统..."
	loading_text.position = Vector2(430, 500)
	loading_text.size = Vector2(420, 30)
	loading_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_text.add_theme_font_size_override("font_size", 16)
	loading_text.add_theme_color_override("font_color", Color("#d5dded"))
	intro_panel.add_child(loading_text)
	loading_bar = ProgressBar.new()
	loading_bar.position = Vector2(430, 545)
	loading_bar.size = Vector2(420, 12)
	loading_bar.show_percentage = false
	loading_bar.value = 0.0
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color("#313b58")
	bar_bg.set_corner_radius_all(6)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = CORAL
	bar_fill.set_corner_radius_all(6)
	loading_bar.add_theme_stylebox_override("background", bar_bg)
	loading_bar.add_theme_stylebox_override("fill", bar_fill)
	intro_panel.add_child(loading_bar)
	main_menu_panel = Control.new()
	main_menu_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_menu_panel.visible = false
	start_flow_design.add_child(main_menu_panel)
	var menu_card := Panel.new()
	menu_card.position = Vector2(86, 118)
	menu_card.size = Vector2(410, 484)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(INK, 0.92)
	card_style.border_color = Color("#68799f", 0.9)
	card_style.set_border_width_all(2)
	card_style.set_corner_radius_all(26)
	menu_card.add_theme_stylebox_override("panel", card_style)
	main_menu_panel.add_child(menu_card)
	var menu_title := Label.new()
	menu_title.text = "漫漫货运"
	menu_title.position = Vector2(38, 34)
	menu_title.size = Vector2(334, 56)
	menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_title.add_theme_font_size_override("font_size", 38)
	menu_title.add_theme_color_override("font_color", CREAM)
	menu_title.add_theme_color_override("font_shadow_color", CORAL)
	menu_title.add_theme_constant_override("shadow_offset_x", 3)
	menu_title.add_theme_constant_override("shadow_offset_y", 3)
	menu_card.add_child(menu_title)
	var menu_subtitle := Label.new()
	menu_subtitle.text = "公路运输冒险"
	menu_subtitle.position = Vector2(38, 88)
	menu_subtitle.size = Vector2(334, 28)
	menu_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_subtitle.add_theme_font_size_override("font_size", 17)
	menu_subtitle.add_theme_color_override("font_color", Color("#ffb7cf"))
	menu_card.add_child(menu_subtitle)
	var continue_button := Button.new()
	continue_button.text = "继续驾驶"
	continue_button.position = Vector2(66, 150)
	continue_button.size = Vector2(278, 56)
	continue_button.add_theme_font_size_override("font_size", 20)
	_style_ui_button(continue_button)
	continue_button.pressed.connect(func(): _start_game(false))
	menu_card.add_child(continue_button)
	var free_drive_button := Button.new()
	free_drive_button.text = "自由驾驶"
	free_drive_button.position = Vector2(66, 220)
	free_drive_button.size = Vector2(278, 56)
	free_drive_button.add_theme_font_size_override("font_size", 20)
	_style_ui_button(free_drive_button)
	free_drive_button.pressed.connect(func(): _start_game(true))
	menu_card.add_child(free_drive_button)
	var settings_button := Button.new()
	settings_button.text = "设置"
	settings_button.position = Vector2(66, 290)
	settings_button.size = Vector2(132, 48)
	settings_button.add_theme_font_size_override("font_size", 17)
	_style_ui_button(settings_button)
	settings_button.pressed.connect(_open_start_settings)
	menu_card.add_child(settings_button)
	var quit_button := Button.new()
	quit_button.text = "退出"
	quit_button.position = Vector2(212, 290)
	quit_button.size = Vector2(132, 48)
	quit_button.add_theme_font_size_override("font_size", 17)
	_style_ui_button(quit_button)
	quit_button.pressed.connect(func(): get_tree().quit())
	menu_card.add_child(quit_button)
	menu_status = Label.new()
	menu_status.text = "天气系统已就绪  •  电台：轻快频道"
	menu_status.position = Vector2(35, 376)
	menu_status.size = Vector2(340, 58)
	menu_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_status.add_theme_font_size_override("font_size", 14)
	menu_status.add_theme_color_override("font_color", Color("#b8c7df"))
	menu_card.add_child(menu_status)
	game_hud_layer.visible = false
	for player in [engine_player, bgm_player, rain_player, wind_player, wet_tire_player, snow_tire_player, spatial_tire_player]:
		if player:
			player.stop()
	_build_menu_left_legacy()
	_layout_start_flow()

func _build_menu_bottom_nav() -> void:
	menu_v2_panel = Control.new()
	menu_v2_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_v2_panel.visible = false
	start_flow_design.add_child(menu_v2_panel)
	var profile_panel := Panel.new()
	profile_panel.position = Vector2(28, 22)
	profile_panel.size = Vector2(330, 78)
	var profile_style := StyleBoxFlat.new()
	profile_style.bg_color = Color("#20264d", 0.88)
	profile_style.border_color = CORAL
	profile_style.set_border_width_all(2)
	profile_style.set_corner_radius_all(18)
	profile_panel.add_theme_stylebox_override("panel", profile_style)
	menu_v2_panel.add_child(profile_panel)
	var profile := Label.new()
	profile.text = "漫漫货运\n▥  资金   €%d" % money
	profile.position = Vector2(18, 12)
	profile.size = Vector2(290, 56)
	profile.add_theme_font_size_override("font_size", 18)
	profile.add_theme_color_override("font_color", CREAM)
	profile_panel.add_child(profile)
	var top_status := Label.new()
	top_status.text = "☀  %s   |   %s   |   %s" % [_format_clock(), {"clear": "晴", "rain": "雨", "snow": "雪", "sakura": "樱花"}.get(current_weather, "多云"), radio_station_names[radio_station]]
	top_status.position = Vector2(970, 24)
	top_status.size = Vector2(280, 38)
	top_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_status.add_theme_font_size_override("font_size", 16)
	top_status.add_theme_color_override("font_color", CREAM)
	menu_v2_panel.add_child(top_status)
	var nav_panel := Panel.new()
	nav_panel.position = Vector2(28, 618)
	nav_panel.size = Vector2(570, 82)
	var nav_style := StyleBoxFlat.new()
	nav_style.bg_color = Color("#20264d", 0.94)
	nav_style.border_color = Color("#52688f")
	nav_style.set_border_width_all(1)
	nav_style.set_corner_radius_all(20)
	nav_panel.add_theme_stylebox_override("panel", nav_style)
	menu_v2_panel.add_child(nav_panel)
	var nav_items: Array = [
		["◉\n驾驶", Callable(self, "_start_menu_drive")],
		["▣\n货运市场", Callable(self, "_start_menu_market")],
		["◎\n世界地图", Callable(self, "_start_menu_map")],
		["⌂\n车库", Callable(self, "_start_menu_garage")],
		["⚙\n设置", Callable(self, "_start_menu_settings")]
	]
	for i in nav_items.size():
		var nav_button := Button.new()
		nav_button.text = nav_items[i][0]
		nav_button.position = Vector2(8 + i * 112, 8)
		nav_button.size = Vector2(104, 66)
		nav_button.add_theme_font_size_override("font_size", 15)
		nav_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		_style_ui_button(nav_button)
		if i == 0:
			var selected := StyleBoxFlat.new()
			selected.bg_color = Color("#ffd166", 0.18)
			selected.border_color = Color("#ffd166")
			selected.set_border_width_all(2)
			selected.set_corner_radius_all(14)
			nav_button.add_theme_stylebox_override("normal", selected)
			nav_button.add_theme_color_override("font_color", Color("#ffd166"))
		nav_button.pressed.connect(nav_items[i][1])
		nav_panel.add_child(nav_button)
	var vehicle_panel := Panel.new()
	vehicle_panel.position = Vector2(974, 636)
	vehicle_panel.size = Vector2(278, 64)
	var vehicle_style := StyleBoxFlat.new()
	vehicle_style.bg_color = Color("#182143", 0.92)
	vehicle_style.border_color = Color("#52688f")
	vehicle_style.set_border_width_all(1)
	vehicle_style.set_corner_radius_all(18)
	vehicle_panel.add_theme_stylebox_override("panel", vehicle_style)
	menu_v2_panel.add_child(vehicle_panel)
	var vehicle_status := Label.new()
	vehicle_status.text = "车辆状态  正常   |   油量 %d%%   |   里程 %.1f km" % [int(fuel), best_distance]
	vehicle_status.position = Vector2(10, 19)
	vehicle_status.size = Vector2(258, 28)
	vehicle_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vehicle_status.add_theme_font_size_override("font_size", 12)
	vehicle_status.add_theme_color_override("font_color", Color("#c7f4df"))
	vehicle_panel.add_child(vehicle_status)

func _start_menu_map() -> void:
	_start_game(true)
	toast = "世界地图：路线预览将在下一版开放"
	toast_time = 2.5

func _build_menu_left_legacy() -> void:
	menu_v2_panel = Control.new()
	menu_v2_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_v2_panel.visible = false
	start_flow_design.add_child(menu_v2_panel)
	var side_panel := Panel.new()
	side_panel.position = Vector2(0, 0)
	side_panel.size = Vector2(430, 720)
	var side_style := StyleBoxFlat.new()
	side_style.bg_color = Color("#151b3d", 0.94)
	side_style.border_color = Color("#313c6a", 0.85)
	side_style.set_border_width_all(2)
	side_panel.add_theme_stylebox_override("panel", side_style)
	menu_v2_panel.add_child(side_panel)
	var logo := Label.new()
	logo.text = "漫漫货运"
	logo.position = Vector2(54, 46)
	logo.size = Vector2(330, 72)
	logo.add_theme_font_size_override("font_size", 52)
	logo.add_theme_color_override("font_color", CREAM)
	logo.add_theme_color_override("font_shadow_color", CORAL)
	logo.add_theme_constant_override("shadow_offset_x", 4)
	logo.add_theme_constant_override("shadow_offset_y", 4)
	side_panel.add_child(logo)
	var profile := Label.new()
	profile.text = "漫漫物流公司\n资金   €%d" % money
	profile.position = Vector2(58, 132)
	profile.size = Vector2(300, 62)
	profile.add_theme_font_size_override("font_size", 18)
	profile.add_theme_color_override("font_color", Color("#d8e2ff"))
	side_panel.add_child(profile)
	var menu_items: Array = [
		["🚚  继续驾驶", Callable(self, "_start_menu_drive")],
		["▣  货运市场", Callable(self, "_start_menu_market")],
		["◎  自由驾驶", Callable(self, "_start_menu_free_drive")],
		["⌂  车库", Callable(self, "_start_menu_garage")],
		["⚙  设置", Callable(self, "_start_menu_settings")],
		["↪  退出", Callable(self, "_quit_from_menu")]
	]
	for i in menu_items.size():
		var menu_button := Button.new()
		menu_button.text = menu_items[i][0]
		menu_button.position = Vector2(38, 224 + i * 67)
		menu_button.size = Vector2(350, 54)
		menu_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		menu_button.add_theme_font_size_override("font_size", 20)
		_style_ui_button(menu_button)
		if i == 0:
			var selected := StyleBoxFlat.new()
			selected.bg_color = Color("#ffd166", 0.98)
			selected.border_color = Color("#fff1cf")
			selected.set_border_width_all(2)
			selected.set_corner_radius_all(14)
			menu_button.add_theme_stylebox_override("normal", selected)
			menu_button.add_theme_color_override("font_color", INK)
		menu_button.add_theme_color_override("font_hover_color", INK)
		menu_button.pressed.connect(menu_items[i][1])
		side_panel.add_child(menu_button)
	var status_panel := Panel.new()
	status_panel.position = Vector2(28, 654)
	status_panel.size = Vector2(374, 52)
	var status_style := StyleBoxFlat.new()
	status_style.bg_color = Color("#222b52", 0.96)
	status_style.border_color = Color("#51628b")
	status_style.set_border_width_all(1)
	status_style.set_corner_radius_all(18)
	status_panel.add_theme_stylebox_override("panel", status_style)
	side_panel.add_child(status_panel)
	var status := Label.new()
	status.text = "资金 €%d     等级 1     里程 %.1f km" % [money, best_distance]
	status.position = Vector2(18, 14)
	status.size = Vector2(338, 28)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.add_theme_font_size_override("font_size", 14)
	status.add_theme_color_override("font_color", CREAM)
	status_panel.add_child(status)
	var top_status := Label.new()
	top_status.text = "☀  %s    %s    %s" % [_format_clock(), {"clear": "晴", "rain": "雨", "snow": "雪", "sakura": "樱花"}.get(current_weather, "多云"), radio_station_names[radio_station]]
	top_status.position = Vector2(980, 28)
	top_status.size = Vector2(260, 38)
	top_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_status.add_theme_font_size_override("font_size", 16)
	top_status.add_theme_color_override("font_color", CREAM)
	menu_v2_panel.add_child(top_status)
	var vehicle_panel := Panel.new()
	vehicle_panel.position = Vector2(990, 654)
	vehicle_panel.size = Vector2(262, 52)
	var vehicle_style := StyleBoxFlat.new()
	vehicle_style.bg_color = Color("#182143", 0.92)
	vehicle_style.border_color = Color("#52688f")
	vehicle_style.set_border_width_all(1)
	vehicle_style.set_corner_radius_all(18)
	vehicle_panel.add_theme_stylebox_override("panel", vehicle_style)
	menu_v2_panel.add_child(vehicle_panel)
	var vehicle_status := Label.new()
	vehicle_status.text = "车辆状态 正常    油量 %d%%    里程 %.1f km" % [int(fuel), best_distance]
	vehicle_status.position = Vector2(12, 14)
	vehicle_status.size = Vector2(238, 26)
	vehicle_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vehicle_status.add_theme_font_size_override("font_size", 12)
	vehicle_status.add_theme_color_override("font_color", Color("#c7f4df"))
	vehicle_panel.add_child(vehicle_status)

func _start_menu_drive() -> void:
	_start_game(false)

func _start_menu_market() -> void:
	_start_game(false)
	_toggle_freight_market()

func _start_menu_free_drive() -> void:
	_start_game(true)

func _start_menu_garage() -> void:
	_start_game(true)
	_toggle_garage()

func _start_menu_settings() -> void:
	_start_game(true)
	_toggle_settings()

func _quit_from_menu() -> void:
	get_tree().quit()

func _layout_start_flow() -> void:
	if not start_flow_root or not start_flow_design:
		return
	var viewport_size := start_flow_root.size
	var safe_margin: float = clampf(min(viewport_size.x, viewport_size.y) * 0.025, 12.0, 32.0)
	var usable_size := viewport_size - Vector2(safe_margin * 2.0, safe_margin * 2.0)
	var fit_scale: float = min(usable_size.x / 1280.0, usable_size.y / 720.0)
	fit_scale = max(fit_scale, 0.5)
	start_flow_design.scale = Vector2.ONE * fit_scale
	start_flow_design.position = (viewport_size - start_flow_design.size * fit_scale) * 0.5

func _play_start_flow() -> void:
	intro_panel.visible = true
	main_menu_panel.visible = false
	menu_v2_panel.visible = false
	var loading_tween := create_tween()
	loading_tween.tween_property(loading_bar, "value", 100.0, 1.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await loading_tween.finished
	var logo_tween := create_tween().set_parallel(true)
	intro_logo.scale = Vector2(0.82, 0.82)
	intro_logo.pivot_offset = intro_logo.size * 0.5
	logo_tween.tween_property(intro_logo, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	logo_tween.tween_property(intro_logo, "modulate", Color.WHITE, 0.35)
	await get_tree().create_timer(1.25).timeout
	var fade := create_tween()
	fade.tween_property(intro_panel, "modulate:a", 0.0, 0.45)
	await fade.finished
	intro_panel.visible = false
	if start_flow_backdrop:
		start_flow_backdrop.color = Color(INK, 0.22)
	menu_v2_panel.modulate.a = 0.0
	menu_v2_panel.visible = true
	var menu_fade := create_tween()
	menu_fade.tween_property(menu_v2_panel, "modulate:a", 1.0, 0.4)

func _start_game(free_drive: bool) -> void:
	game_started = true
	start_flow_layer.visible = false
	menu_v2_panel.visible = false
	game_hud_layer.visible = true
	paused = false
	if free_drive:
		task_active = false
		toast = "自由驾驶模式：探索阿尔卑斯公路"
	else:
		toast = "欢迎回来，准备接取运输任务"
	toast_time = 3.0
	if engine_player and not engine_player.playing:
		engine_player.play()
	_set_radio_station(radio_station, false)
	for player in [rain_player, wind_player, wet_tire_player, snow_tire_player, spatial_tire_player]:
		if player and player.stream and not player.playing:
			player.play()
	_update_ui()

func _open_start_settings() -> void:
	menu_status.text = "设置将在进入驾驶后从 HUD 打开。"
	toast = "请先进入驾驶界面打开设置"
	toast_time = 2.2

func _style_ui_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", INK)
	var normal: Variant = StyleBoxFlat.new()
	normal.bg_color = Color("#3d4764", 0.96)
	normal.border_color = Color("#66789d", 0.9)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(12)
	button.add_theme_stylebox_override("normal", normal)
	var hover: Variant = normal.duplicate()
	hover.bg_color = Color("#ffd166", 0.96)
	button.add_theme_stylebox_override("hover", hover)

func _hud_card(layer: CanvasLayer, pos: Vector2, card_size: Vector2, color: Color) -> Panel:
	var card: Variant = Panel.new()
	card.position = pos
	card.size = card_size
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: Variant = StyleBoxFlat.new()
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
	var icon: Variant = TextureRect.new()
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
	settings_panel.size = Vector2(370, 490)
	settings_panel.visible = false
	settings_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_panel.set_script(load("res://scripts/settings_panel.gd"))
	settings_panel.quality_selected.connect(_apply_quality)
	settings_panel.sensitivity_changed.connect(_apply_sensitivity)
	settings_panel.volume_changed.connect(_apply_volume)
	settings_panel.music_volume_changed.connect(_apply_music_volume)
	settings_panel.sfx_volume_changed.connect(_apply_sfx_volume)
	settings_panel.control_layout_changed.connect(_apply_control_layout)
	settings_panel.closed.connect(_toggle_settings)
	layer.add_child(settings_panel)
	settings_panel.quality_mode = quality_mode
	settings_panel.sensitivity = steering_sensitivity
	settings_panel.volume = master_volume
	settings_panel.music_volume = music_volume
	settings_panel.sfx_volume = sfx_volume
	settings_panel.control_scale = control_scale
	settings_panel.control_opacity = control_opacity

func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
	_play_sfx("ui_click", -10.0)

func _apply_quality(mode: int) -> void:
	quality_mode = mode
	var ratios: Variant = [0.45, 0.72, 1.0]
	rain_particles.amount_ratio = ratios[mode]
	snow_particles.amount_ratio = ratios[mode]
	if sakura_particles:
		sakura_particles.amount = [70, 125, 180][mode]
		sakura_particles.amount_ratio = ratios[mode]
	if star_particles:
		star_particles.amount = [55, 95, 140][mode]
	if speed_lines:
		speed_lines.amount = [28, 54, 90][mode]
		speed_lines.visible = mode > 0
	if exhaust_particles:
		exhaust_particles.amount = [8, 12, 18][mode]
	if collision_sparks:
		collision_sparks.amount = [12, 20, 28][mode]
		collision_smoke.amount = [8, 12, 18][mode]
		collision_debris.amount = [6, 12, 18][mode]
	for i in traffic.size():
		traffic[i].visible = mode > 0 or i < 3
	for person in pedestrian_nodes:
		if is_instance_valid(person):
			person.visible = mode >= 1
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
	if virtual_controls and virtual_controls.has_method("set_sensitivity"):
		virtual_controls.set_sensitivity(value)
	_save_game()

func _apply_volume(value: float) -> void:
	master_volume = value
	_apply_music_volume(music_volume)
	_apply_sfx_volume(sfx_volume)
	_save_game()

func _apply_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	for player in [engine_player, bgm_player, rain_player, wind_player, wet_tire_player, snow_tire_player, thunder_player, spatial_tire_player]:
		if player:
			player.volume_db = linear_to_db(max(music_volume * master_volume, 0.001))
	_save_game()

func _apply_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	if brake_player:
		brake_player.volume_db = linear_to_db(max(sfx_volume * master_volume, 0.001)) - 4.0
	_save_game()

func _apply_control_layout(scale_value: float, opacity_value: float) -> void:
	control_scale = clampf(scale_value, 0.75, 1.35)
	control_opacity = clampf(opacity_value, 0.35, 1.0)
	if virtual_controls and virtual_controls.has_method("set_layout"):
		virtual_controls.set_layout(control_scale, control_opacity, Vector2.ZERO)
	_save_game()

func _build_garage_panel(layer: CanvasLayer) -> void:
	garage_panel = Panel.new()
	garage_panel.position = Vector2(850, 112)
	garage_panel.size = Vector2(390, 420)
	garage_panel.visible = false
	garage_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var garage_style: Variant = StyleBoxFlat.new()
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
	var upgrades: Variant = ["发动机", "轮胎", "油箱", "装甲", "橙色涂装", "蓝色涂装"]
	for i in upgrades.size():
		var button: Variant = Button.new()
		button.text = upgrades[i] + "升级  €" + str(500 + i * 150)
		button.position = Vector2(18, 68 + i * 50)
		button.size = Vector2(350, 40)
		button.add_theme_font_size_override("font_size", 16)
		_style_ui_button(button)
		var upgrade_id: Variant = ["engine", "tire", "tank", "armor", "livery_orange", "livery_blue"][i]
		button.pressed.connect(func(): _buy_upgrade(upgrade_id))
		garage_panel.add_child(button)
	_update_garage_label()

func _toggle_garage() -> void:
	garage_panel.visible = not garage_panel.visible
	_update_garage_label()
	_play_sfx("ui_click", -10.0)

func _update_garage_label() -> void:
	if garage_label:
		garage_label.text = "车库升级   € %d\n发动机 %d   轮胎 %d   油箱 %d   装甲 %d" % [money, engine_level, tire_level, tank_level, armor_level]

func _buy_upgrade(upgrade_id: String) -> void:
	var price: Variant = {"engine": 500, "tire": 650, "tank": 800, "armor": 950, "livery_orange": 300, "livery_blue": 300}.get(upgrade_id, 9999)
	if money < price:
		toast = "运费不足"
		_play_sfx("warning_alert", -10.0)
	else:
		money -= price
		match upgrade_id:
			"engine": engine_level += 1
			"tire": tire_level += 1
			"tank": tank_level += 1
			"armor": armor_level += 1
			"livery_orange": livery_index = 0
			"livery_blue": livery_index = 1
		_apply_livery(livery_index)
		toast = "升级完成：" + upgrade_id
		toast_time = 2.0
		_play_sfx("upgrade_purchase", -7.0)
		_save_game()
		_haptic(80, 0.45)
	_update_garage_label()

func _label(layer: CanvasLayer, pos: Vector2, size: int, color: Color) -> Label:
	var label: Variant = Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("#0d1020", 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(label)
	return label

func _add_button(layer: CanvasLayer, text: String, pos: Vector2, action: String) -> void:
	var button: Variant = Button.new()
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

func _on_turn_left_pressed() -> void:
	manual_turn_left = not manual_turn_left
	manual_turn_right = false
	hazard_lights = false
	_play_sfx("turn_signal", -13.0)

func _on_turn_right_pressed() -> void:
	manual_turn_right = not manual_turn_right
	manual_turn_left = false
	hazard_lights = false
	_play_sfx("turn_signal", -13.0)

func _on_hazard_pressed() -> void:
	hazard_lights = not hazard_lights
	manual_turn_left = false
	manual_turn_right = false
	_play_sfx("warning_alert", -10.0)

func _on_horn_changed(active: bool) -> void:
	horn_active = active
	if active:
		_play_sfx("warning_alert", -4.0)

func _on_gear_changed(mode: String) -> void:
	drive_mode = mode if mode in ["D", "N", "R"] else "D"
	toast = "档位：" + drive_mode
	toast_time = 1.5
	_play_sfx("gear_shift", -10.0)
	_save_game()

func _build_audio() -> void:
	engine_player = AudioStreamPlayer.new()
	var engine_stream: Variant = load("res://audio/engine_loop.wav")
	if engine_stream is AudioStream:
		engine_player.stream = engine_stream
	engine_player.volume_db = -10.0
	add_child(engine_player)
		if engine_player.stream:
			engine_player.play()
	bgm_player = _loop_audio("res://audio/bgm_route_loop.wav", -19.0)
	_set_radio_station(radio_station, false)
	brake_player = AudioStreamPlayer.new()
	var brake_stream: Variant = load("res://audio/air_brake.wav")
	if brake_stream is AudioStream:
		brake_player.stream = brake_stream
	brake_player.volume_db = -4.0
	add_child(brake_player)
	rain_player = _loop_audio("res://audio/rain_ambient.wav", -28.0)
	wind_player = _loop_audio("res://audio/wind_ambient.wav", -24.0)
	wet_tire_player = _loop_audio("res://audio/tire_wet.wav", -32.0)
	snow_tire_player = _loop_audio("res://audio/tire_snow.wav", -32.0)
	spatial_tire_player = _spatial_loop_audio("res://audio/tire_wet.wav", -34.0)
	thunder_player = AudioStreamPlayer.new()
	var thunder_stream: Variant = load("res://audio/thunder_rumble.wav")
	if thunder_stream is AudioStream:
		thunder_player.stream = thunder_stream
	thunder_player.volume_db = -9.0
	add_child(thunder_player)
	for sfx_name in ["reverse_beeper", "turn_signal", "gear_shift", "tire_skid", "collision_metal", "guardrail_scrape", "water_splash", "wiper_swipe", "refuel_start", "repair_start", "delivery_complete", "upgrade_purchase", "ui_click", "warning_alert"]:
		var sfx_player: Variant = AudioStreamPlayer.new()
		var sfx_stream: Variant = load("res://audio/" + sfx_name + ".wav")
		if sfx_stream is AudioStream:
			sfx_player.stream = sfx_stream
			sfx_player.volume_db = -8.0
		add_child(sfx_player)
		sfx_players[sfx_name] = sfx_player
	if sfx_players.has("ui_click"):
		var click_stream: Variant = load("res://assets/audio_sources/kenney_ui_audio/click1.wav")
		if click_stream is AudioStream:
			sfx_players["ui_click"].stream = click_stream

func _cycle_radio_station() -> void:
	_set_radio_station((radio_station + 1) % radio_station_paths.size(), true)

func _set_radio_station(station: int, announce: bool) -> void:
	radio_station = clampi(station, 0, radio_station_paths.size() - 1)
	if bgm_player:
		if radio_station == 0:
			bgm_player.stop()
		else:
			var stream: Variant = load(radio_station_paths[radio_station])
			if stream is AudioStream:
				bgm_player.stream = stream
				bgm_player.play()
	if radio_button:
		radio_button.text = "电台：" + radio_station_names[radio_station]
		radio_button.modulate = Color("#ff8fb3") if radio_station == 2 else (MINT if radio_station == 1 else Color("#9aa8c4"))
	if announce:
		toast = radio_station_names[radio_station]
		toast_time = 2.0
		_play_sfx("ui_click", -10.0)
		_save_game()

func _update_radio_mix() -> void:
	if not bgm_player:
		return
	if radio_station == 0:
		bgm_player.volume_db = -60.0
		return
	var base_volume: float = -20.0 if radio_station == 1 else -17.0
	var speed_bonus: float = clamp(speed / 21.0, 0.0, 1.0) * (1.5 if radio_station == 2 else 0.5)
	var night_duck: float = -1.5 if game_hour < 6.0 or game_hour >= 19.0 else 0.0
	var weather_duck: float = -2.0 if current_weather == "rain" else (-1.0 if current_weather == "snow" else 0.0)
	bgm_player.volume_db = base_volume + speed_bonus + night_duck + weather_duck + linear_to_db(max(music_volume * master_volume, 0.001))
	bgm_player.pitch_scale = 1.0 + (0.018 if radio_station == 2 and speed > 16.0 else 0.0)

func _play_sfx(sfx_name: String, volume_db := -8.0) -> void:
	var player: Variant = sfx_players.get(sfx_name)
	if player and player.stream:
		player.volume_db = volume_db + linear_to_db(max(sfx_volume * master_volume, 0.001))
		player.play()

func _loop_audio(path: String, volume: float) -> AudioStreamPlayer:
	var player: Variant = AudioStreamPlayer.new()
	var stream: Variant = load(path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	if stream is AudioStream:
		player.stream = stream
	player.volume_db = volume
	add_child(player)
	if player.stream:
		player.play()
	return player

func _spatial_loop_audio(path: String, volume: float) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	var stream: Variant = load(path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	if stream is AudioStream:
		player.stream = stream
	player.volume_db = volume
	player.max_distance = 38.0
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	add_child(player)
	if player.stream:
		player.play()
	return player

func _process(delta: float) -> void:
	if not game_started:
		return
	if paused:
		return
	save_timer += delta
	if save_timer >= 10.0:
		save_timer = 0.0
		_save_game()
	best_distance = max(best_distance, distance)
	if distance >= 50.0:
		_unlock_achievement("LONG_HAUL", "完成 50 公里长途驾驶")
	if distance >= 100.0:
		_unlock_achievement("ULTRA_HAUL", "完成 100 公里超长运输")
	if game_hour < 6.0 or game_hour >= 19.0:
		_unlock_achievement("NIGHT_DRIVER", "完成夜间驾驶")
	if current_weather == "rain" and weather_intensity > 0.5:
		_unlock_achievement("RAIN_RUNNER", "在暴雨中坚持驾驶")
	game_hour = fmod(game_hour + 24.0 * delta / day_length_seconds, 24.0)
	var keyboard_throttle: Variant = Input.get_action_strength("accelerate")
	var keyboard_brake: Variant = Input.get_action_strength("brake")
	var keyboard_steer: Variant = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var throttle: Variant = max(keyboard_throttle, touch_throttle)
	var braking: Variant = max(keyboard_brake, touch_brake)
	var steer_input: Variant = touch_steer if abs(touch_steer) > 0.01 else keyboard_steer
	var max_speed: Variant = 21.0 + float(engine_level) * 2.5
	var drive_factor: float = 1.0 if drive_mode == "D" else 0.0
	var speed_ratio: Variant = clamp(speed / max(max_speed, 1.0), 0.0, 1.0)
	var steering_response: Variant = lerp(5.0, 9.0, speed_ratio)
	steer = lerp(steer, steer_input, clamp(delta * steering_response, 0.0, 1.0))
	slope_percent = clamp((_road_height_at(truck.position.z - 8.0) - _road_height_at(truck.position.z)) / 8.0 * 100.0, -18.0, 18.0)
	var slope_drag: Variant = slope_percent * 0.055
	var wetness: float = weather_intensity if current_weather == "rain" else 0.0
	var snowiness: float = weather_intensity if current_weather == "snow" else 0.0
	var sakura_wind: float = weather_intensity if current_weather == "sakura" else 0.0
	var wet_grip: float = clampf(1.0 - wetness * 0.45 - snowiness * 0.30, 0.55, 1.0)
	var brake_pressed: Variant = braking > 0.15 and not brake_input_was_active
	if brake_pressed and throttle < 0.05 and abs(speed) < 0.8:
		reverse_mode = true
	if braking < 0.05 or throttle > 0.05:
		reverse_mode = false
	var reverse_active: Variant = drive_mode == "R" and throttle > 0.05 and (abs(speed) < 0.8 or speed < 0.0)
	var brake_force: float = (12.0 + float(tire_level) * 0.8) * wet_grip
	var drive_target_speed: float = throttle * max_speed * drive_factor - slope_drag
	if reverse_active:
		speed = lerp(speed, -5.5 * throttle, delta * 4.5)
		if not sfx_players["reverse_beeper"].playing:
			_play_sfx("reverse_beeper", -8.0)
	elif braking > 0.15 and speed > 0.0:
		speed = move_toward(speed, 0.0, delta * brake_force)
	else:
		speed = lerp(speed, max(drive_target_speed, 0.0), delta * 3.8)
		sfx_players["reverse_beeper"].stop()
	var current_gear: Variant = -1 if speed < -0.35 else (0 if abs(speed) < 0.35 else clamp(int(speed / 3.2) + 1, 1, 12))
	if current_gear != last_gear:
		if last_gear != 0:
			_play_sfx("gear_shift", -10.0)
		last_gear = current_gear
	var steering_grip: Variant = (1.0 + float(tire_level) * 0.08) * wet_grip
	var road_center: Variant = _road_center_at(truck.position.z)
	var lateral_rate: Variant = lerp(5.8, 3.2, speed_ratio) * steering_grip
	var slip_target: float = steer * speed_ratio * (wetness * 3.8 + snowiness * 1.8) if braking > 0.2 else steer * speed_ratio * (wetness * 0.65 + snowiness * 0.28)
	slip_target += sin(Time.get_ticks_msec() * 0.0017) * sakura_wind * speed_ratio * 0.08
	wet_lateral_slip = lerp(wet_lateral_slip, slip_target, clampf(delta * 2.4, 0.0, 1.0))
	truck.position.x = clamp(truck.position.x + steer * delta * lateral_rate + wet_lateral_slip * delta + (road_center - truck.position.x) * delta * 0.38, road_center - 4.0, road_center + 4.0)
	truck.position.y = 0.65 + _road_height_at(truck.position.z)
	if speed_lines:
		speed_lines.position = truck.position + Vector3(0, 1.5, 4.0)
		speed_lines.emitting = speed > 13.0 and current_weather != "snow"
		speed_lines.amount_ratio = clamp((speed - 13.0) / 10.0, 0.0, 1.0)
	var road_pitch: Variant = atan2(_road_height_at(truck.position.z - 8.0) - _road_height_at(truck.position.z), 8.0)
	var brake_glow: Variant = 1.0 if braking > 0.15 else 0.35
	for lamp in brake_lamps:
		var brake_material: Variant = lamp.material_override as StandardMaterial3D
		brake_material.emission_enabled = true
		brake_material.emission = CORAL
		brake_material.emission_energy_multiplier = brake_glow * 2.8
	for lamp in authored_brake_lamps:
		var authored_brake_material: Variant = lamp.material_override as StandardMaterial3D
		if authored_brake_material:
			authored_brake_material.emission_enabled = true
			authored_brake_material.emission = CORAL
			authored_brake_material.emission_energy_multiplier = brake_glow * 2.8
	var damage_warning: Variant = clamp((damage - 45.0) / 55.0, 0.0, 1.0)
	var warning_pulse: Variant = 0.65 + sin(Time.get_ticks_msec() * 0.012) * 0.35
	for reflector in safety_reflectors:
		var reflector_material: Variant = reflector.material_override as StandardMaterial3D
		if reflector_material:
			reflector_material.emission_enabled = damage_warning > 0.01
			reflector_material.emission = CORAL
			reflector_material.emission_energy_multiplier = damage_warning * warning_pulse * 2.4
	var manual_signal_active: Variant = manual_turn_left or manual_turn_right or hazard_lights
	var auto_signal_active: Variant = abs(steer) > 0.14
	var signal_on: Variant = (manual_signal_active or auto_signal_active) and fmod(Time.get_ticks_msec() / 1000.0, 0.65) < 0.32
	if signal_on and not last_indicator_on:
		_play_sfx("turn_signal", -13.0)
	last_indicator_on = signal_on
	for lamp in signal_lamps:
		lamp.visible = signal_on
	for lamp in authored_signal_lamps:
		lamp.visible = signal_on
	guardrail_audio_cooldown = max(0.0, guardrail_audio_cooldown - delta)
	wet_skid_cooldown = max(0.0, wet_skid_cooldown - delta)
	if wetness > 0.45 and braking > 0.2 and speed > 7.0 and abs(steer) > 0.18 and wet_skid_cooldown <= 0.0:
		_play_sfx("tire_skid", -8.0)
		wet_skid_cooldown = 0.65
	var road_offset: Variant = abs(truck.position.x - road_center)
		if road_offset > 3.65 and speed > 3.0 and guardrail_audio_cooldown <= 0.0:
			_play_sfx("guardrail_scrape", -10.0)
			guardrail_audio_cooldown = 0.8
			speed *= 0.92
			if task_active:
				task_score = max(0.0, task_score - 3.0)
				task_score_cooldown = 0.35
	var near_puddle: Variant = false
	for puddle in road_puddles:
		if is_instance_valid(puddle) and truck.global_position.distance_to(puddle.global_position) < 2.4:
			near_puddle = true
			break
	if near_puddle and not puddle_audio_active and current_weather == "rain" and abs(speed) > 2.0:
		_play_sfx("water_splash", -9.0)
	puddle_audio_active = near_puddle
	for lamp in authored_headlamps:
		lamp.visible = true
	if exhaust_particles:
		exhaust_particles.amount_ratio = clamp(0.18 + throttle * 0.72, 0.18, 1.0)
	truck.rotation.z = lerp(truck.rotation.z, -steer * 0.075, delta * 8.0)
	truck.rotation.x = lerp(truck.rotation.x, -road_pitch + sin(Time.get_ticks_msec() * 0.006) * speed * 0.0018, delta * 4.0)
	if engine_player:
		var engine_load: Variant = clamp(throttle + max(0.0, slope_percent) * 0.035, 0.0, 1.0)
		engine_player.pitch_scale = 0.82 + speed / max(max_speed, 1.0) * 0.32 + engine_load * 0.16
		engine_player.volume_db = linear_to_db(max(music_volume * master_volume, 0.001)) - 12.0 + engine_load * 4.0
	for wheel in wheel_nodes:
		wheel.rotation.x -= speed * delta * 1.8
	for wheel in authored_wheel_nodes:
		wheel.rotation.x -= speed * delta * 1.8
	for wheel in authored_front_wheels:
		wheel.rotation.y = steer * 0.22
	distance += speed * delta * 0.016
	truck.position.z -= speed * delta * 0.7
	_update_streaming()
	if spatial_tire_player:
		spatial_tire_player.global_position = truck.global_position + Vector3(0, 0.25, 0)
	_update_pedestrians(delta)
	_update_refueling(delta)
	_update_repairing(delta)
	var fuel_capacity: Variant = 100.0 + float(tank_level) * 10.0
	fuel = max(0.0, fuel - speed * delta * 0.0014)
	time_left = max(0.0, time_left - delta)
	thunder_cooldown -= delta
	collision_effect_cooldown = max(0.0, collision_effect_cooldown - delta)
	camera_toggle_cooldown = max(0.0, camera_toggle_cooldown - delta)
	if braking > 0.2 and speed > 2.0 and not brake_player.playing:
		brake_player.play()
		brake_input_was_active = braking > 0.15
	traffic_ai_frame = (traffic_ai_frame + 1) % 60
	var traffic_ai_stride: Variant = 1 if quality_mode >= 2 else (2 if quality_mode == 1 else 3)
	for i in traffic.size():
		var car: Variant = traffic[i]
		if not car.visible and quality_mode == 0:
			continue
		var traffic_factor: Variant = traffic_speeds[i]
		if current_scene.find("城市") >= 0 and _near_signal_intersection(car.position.z) and _signal_is_red(car.position.z):
			traffic_factor = 0.0
		for other_index in traffic.size():
			if other_index == i:
				continue
			var ahead_car: Variant = traffic[other_index]
			var same_lane_ahead: Variant = abs(ahead_car.position.x - car.position.x) < 1.25 and ahead_car.position.z < car.position.z and car.position.z - ahead_car.position.z < 8.0
			if same_lane_ahead:
				traffic_factor = min(traffic_factor, 0.12)
				break
		var traffic_braking: Variant = traffic_factor < 0.45
		var traffic_tail_material: Variant = traffic_tail_lamps[i].material_override as StandardMaterial3D
		traffic_tail_material.emission_energy_multiplier = 2.8 if traffic_braking else 1.1
		car.position.z += speed * delta * 0.7 * traffic_factor
		var car_center: Variant = _road_center_at(car.position.z)
		traffic_lane_cooldowns[i] = max(0.0, traffic_lane_cooldowns[i] - delta)
		var proposed_lane: Variant = traffic_lane_targets[i]
		if i % traffic_ai_stride == traffic_ai_frame % traffic_ai_stride:
			proposed_lane = _traffic_target_lane(i, car)
		if abs(proposed_lane - traffic_lane_targets[i]) > 0.1 and traffic_lane_cooldowns[i] <= 0.0:
			traffic_lane_targets[i] = proposed_lane
			traffic_lane_cooldowns[i] = 3.0
		var target_lane: Variant = traffic_lane_targets[i]
		var changing_lane: Variant = abs(target_lane - traffic_lanes[i]) > 0.1
		traffic_turn_lamps[i].visible = changing_lane and fmod(Time.get_ticks_msec() / 1000.0, 0.7) < 0.35
		var car_target_x: Variant = car_center + target_lane
		car.position.x = lerp(car.position.x, car_target_x, delta * 5.0)
		car.position.y = 0.55 + _road_height_at(car.position.z)
		car.rotation.y = atan2(_road_center_at(car.position.z - 8.0) - car_center, 8.0)
		car.rotation.x = -atan2(_road_height_at(car.position.z - 8.0) - _road_height_at(car.position.z), 8.0)
		if car.position.z > truck.position.z + 22.0:
			car.position.z = truck.position.z - 100.0 - float(i) * 20.0
			car.position.x = _road_center_at(car.position.z) + traffic_lanes[i]
			traffic_lane_targets[i] = traffic_lanes[i]
			traffic_lane_cooldowns[i] = 1.5
			traffic_turn_lamps[i].visible = false
		if abs(car.position.x - truck.position.x) < 2.5 and abs(car.position.z - truck.position.z) < 4.0 and speed > 11.0:
			var impact_speed: Variant = clamp(speed * (1.0 + traffic_speeds[i] * 0.25), 0.0, 30.0)
			var impact_intensity: Variant = clamp(impact_speed / 24.0, 0.15, 1.0)
			var side_hit: Variant = clamp(abs(car.position.x - truck.position.x) / 2.5, 0.0, 1.0)
			damage = min(100.0, damage + max(2.0, impact_speed * 0.58 - float(armor_level) * 2.5) * lerp(0.82, 1.18, side_hit))
			if task_active:
				task_incidents += 1
				task_score = max(0.0, task_score - 12.0)
				task_combo = 0.0
				task_score_cooldown = 0.8
			speed *= lerp(0.82, 0.28, impact_intensity)
			hit_shake = 0.35 + impact_intensity * 0.85
			toast = "碰撞冲击 %.0f%%" % (impact_intensity * 100.0)
			toast_time = 2.2
			_haptic(130, 0.75)
			_play_sfx("collision_metal", lerp(-12.0, -3.0, impact_intensity))
			if impact_intensity > 0.55:
				_play_sfx("tire_skid", -9.0)
			if collision_effect_cooldown <= 0.0:
				collision_effect_cooldown = 0.35
				var impact_side: Variant = sign(car.position.x - truck.position.x)
				var impact_position: Variant = truck.global_position + Vector3(impact_side * 1.5, 0.9, -2.8)
				for effect in [collision_sparks, collision_smoke, collision_debris]:
					effect.global_position = impact_position
					effect.amount_ratio = impact_intensity
					effect.restart()
				var impact_label: Variant = _label3d(self, "!!", impact_position + Vector3(0, 1.2, 0), Color("#ffd166"), 48)
				var impact_tween: Variant = create_tween()
				impact_tween.tween_property(impact_label, "position", impact_label.position + Vector3(0, 1.4, 0), 0.45)
				impact_tween.parallel().tween_property(impact_label, "modulate:a", 0.0, 0.45)
				impact_tween.tween_callback(impact_label.queue_free)
		_update_task_score(delta, throttle, braking)
		_update_task(delta)
	toast_time = max(0.0, toast_time - delta)
	_update_camera(delta)
	_update_scene_name()
	_update_signal_visuals()
	_update_day_night()
	_update_weather_event(delta)
	_update_weather_visuals()
	_update_weather_audio(delta)
	_update_radio_mix()
	_update_cockpit_instruments(delta)
	_update_ui()

func _update_day_night() -> void:
	var sun_angle: Variant = (game_hour - 6.0) / 24.0 * 360.0
	var daylight: Variant = clamp(sin((game_hour - 6.0) / 12.0 * PI), 0.0, 1.0)
	sun.rotation_degrees = Vector3(sun_angle - 90.0, -28.0, 0.0)
	sun.light_energy = lerp(0.04, 1.25, daylight)
	sun.light_color = Color(1.0, lerp(0.52, 0.95, daylight), lerp(0.40, 0.82, daylight))
	sun.shadow_enabled = daylight > 0.12
	moon.rotation_degrees = Vector3(sun_angle + 180.0, 150.0, 0.0)
	moon.light_energy = lerp(0.24, 0.0, daylight)
	var night: Variant = 1.0 - daylight
	environment.ambient_light_energy = lerp(0.16, 0.82, daylight)
	environment.glow_intensity = lerp(0.92, 0.58, daylight)
	environment.adjustment_contrast = lerp(1.14, 1.06, daylight)
	if game_hour >= 5.0 and game_hour < 8.0:
		environment.background_color = Color("#e1a77f").lerp(Color("#86d6e8"), (game_hour - 5.0) / 3.0)
	elif game_hour >= 17.0 and game_hour < 20.0:
		environment.background_color = Color("#86d6e8").lerp(Color("#e38769"), (game_hour - 17.0) / 3.0)
	elif daylight <= 0.02:
		environment.background_color = Color("#111b39")
	else:
		environment.background_color = Color("#86d6e8")
	var sky_top: Variant = Color("#4b78c2")
	var sky_horizon: Variant = Color("#86d6e8")
	var ground_horizon: Variant = Color("#9bb07f")
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
	var star_strength: float = clamp((0.28 - daylight) / 0.28, 0.0, 1.0)
	if star_particles:
		star_particles.position = truck.position + Vector3(0, 13.0, 0)
		star_particles.emitting = star_strength > 0.01
		star_particles.amount_ratio = star_strength
	if star_material:
		star_material.albedo_color = Color(0.88, 0.94, 1.0, star_strength * 0.86)
	sky_material.sky_top_color = sky_material.sky_top_color.lerp(sky_top, 0.08)
	sky_material.sky_horizon_color = sky_material.sky_horizon_color.lerp(sky_horizon, 0.08)
	sky_material.ground_horizon_color = sky_material.ground_horizon_color.lerp(ground_horizon, 0.08)
	# Snow reflects more moonlight; forest remains intentionally darker at night.
	if current_scene == "山区雪岭":
		environment.ambient_light_energy += night * 0.12
	elif current_scene == "深山老林":
		environment.ambient_light_energy -= night * 0.08
	_apply_region_palette()
	for city_light in city_lights:
		city_light.light_energy = clamp((1.0 - daylight) * 1.8, 0.0, 1.8) if current_scene == "动漫城市" else 0.0
	for headlight in headlight_nodes:
		var beam_factor: float = 1.65 if high_beam else 1.0
		headlight.light_energy = clamp((1.0 - daylight) * 2.8 * beam_factor, 0.0, 5.0)
		headlight.omni_range = 30.0 if high_beam else 18.0
	for lamp in authored_headlamps:
		var head_material: Variant = lamp.material_override as StandardMaterial3D
		if head_material:
			head_material.emission_enabled = true
			head_material.emission = Color("#ffd166")
			head_material.emission_energy_multiplier = lerp(0.35, 2.4, 1.0 - daylight) * (1.18 if high_beam else 1.0)
	for traffic_lamp in traffic_lights:
		var traffic_material: Variant = traffic_lamp.material_override as StandardMaterial3D
		traffic_material.emission_energy_multiplier = lerp(0.8, 2.2, 1.0 - daylight)

func _apply_region_palette() -> void:
	var palette: Variant = {
		"city": [Color("#cfe5ff"), Color("#a7c5e8"), Color("#9bb0cf")],
		"rural": [Color("#fff0c7"), Color("#b9d88c"), Color("#a8c46f")],
		"forest": [Color("#ccebd8"), Color("#79bfa2"), Color("#477f72")],
		"mountain": [Color("#e4efff"), Color("#aec7e8"), Color("#8d9caf")],
		"plains": [Color("#ffe6b0"), Color("#e6c87b"), Color("#c99d58")]
	}
	var key: Variant = "rural"
	if current_scene.find("城市") >= 0:
		key = "city"
	elif current_scene.find("森林") >= 0 or current_scene.find("深山") >= 0:
		key = "forest"
	elif current_scene.find("雪") >= 0 or current_scene.find("山区") >= 0:
		key = "mountain"
	elif current_scene.find("平原") >= 0:
		key = "plains"
	var colors: Variant = palette[key]
	environment.ambient_light_color = environment.ambient_light_color.lerp(colors[0], 0.06)
	environment.fog_light_color = environment.fog_light_color.lerp(colors[1], 0.05)
	sky_material.ground_horizon_color = sky_material.ground_horizon_color.lerp(colors[2], 0.05)

func _update_weather_visuals() -> void:
	var rain_strength: Variant = weather_intensity if current_weather == "rain" else 0.0
	var snow_strength: Variant = weather_intensity if current_weather == "snow" else 0.0
	var sakura_strength: Variant = weather_intensity if current_weather == "sakura" else 0.0
	rain_particles.emitting = rain_strength > 0.02
	snow_particles.emitting = snow_strength > 0.02
	sakura_particles.emitting = sakura_strength > 0.02
	rain_particles.amount_ratio = rain_strength
	snow_particles.amount_ratio = snow_strength
	sakura_particles.amount_ratio = sakura_strength
	var base_fog: Variant = 0.008
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
	elif current_weather == "sakura":
		base_fog += weather_intensity * 0.004
	if weather_event_type == "大雾":
		base_fog += 0.075
	environment.fog_density = lerp(environment.fog_density, base_fog, 0.08)
	var weather_fog_color: Variant = Color("#7895b8") if current_weather == "rain" else (Color("#d9e7f2") if current_weather == "snow" else (Color("#e7b8c8") if current_weather == "sakura" else Color("#bcd3dc")))
	environment.fog_light_color = environment.fog_light_color.lerp(weather_fog_color, 0.08)
	environment.ambient_light_energy = lerp(environment.ambient_light_energy, 0.42 if current_weather == "rain" else (0.72 if current_weather == "snow" else environment.ambient_light_energy), 0.025)
	var target_saturation: Variant = 0.82 if current_weather == "rain" else (0.96 if current_weather == "snow" else (1.18 if current_weather == "sakura" else 1.12))
	var target_brightness: Variant = 0.94 if current_weather == "rain" else (1.02 if current_weather == "snow" else (1.08 if current_weather == "sakura" else 1.04))
	environment.adjustment_saturation = lerp(environment.adjustment_saturation, target_saturation, 0.04)
	environment.adjustment_brightness = lerp(environment.adjustment_brightness, target_brightness, 0.04)
	var road_material: Variant = road_surface.material_override as StandardMaterial3D
	if windshield_glass:
		var glass_material: Variant = windshield_glass.material_override as StandardMaterial3D
		var glass_alpha: float = 0.08
		var glass_color := Color("#9fd7e8")
		var glass_roughness: float = 0.12
		if current_weather == "rain":
			glass_alpha = 0.16 + weather_intensity * 0.08
			glass_color = Color("#7ca8c6")
			glass_roughness = 0.28
		elif current_weather == "snow":
			glass_alpha = 0.18 + weather_intensity * 0.10
			glass_color = Color("#d9e7f2")
			glass_roughness = 0.42
		elif current_weather == "sakura":
			glass_alpha = 0.10 + weather_intensity * 0.04
			glass_color = Color("#f5c6d6")
			glass_roughness = 0.18
		if weather_event_type == "大雾":
			glass_alpha = 0.30
			glass_color = Color("#c5d6df")
			glass_roughness = 0.52
		glass_material.albedo_color = Color(glass_color, glass_alpha)
		glass_material.roughness = glass_roughness
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
	elif current_weather == "sakura":
		road_material.albedo_texture = ROAD_CLEAR_TEXTURE
		road_material.albedo_color = road_material.albedo_color.lerp(Color("#5f4f68"), 0.06)
		road_material.roughness = lerp(road_material.roughness, 0.72, 0.08)
		road_material.metallic = lerp(road_material.metallic, 0.02, 0.08)
	else:
		road_material.albedo_texture = ROAD_CLEAR_TEXTURE
		road_material.albedo_color = road_material.albedo_color.lerp(ASPHALT, 0.08)
		road_material.roughness = lerp(road_material.roughness, 0.82, 0.08)
		road_material.metallic = lerp(road_material.metallic, 0.0, 0.08)
	for puddle in road_puddles:
		puddle.visible = current_weather == "rain"
	if current_weather == "rain" and weather_intensity > 0.5 and thunder_cooldown <= 0.0 and not thunder_player.playing:
		lightning_light.light_energy = 6.0
		var flash: Variant = create_tween()
		flash.tween_property(lightning_light, "light_energy", 0.0, 0.16)

func _update_weather_event(delta: float) -> void:
	weather_event_cooldown = max(0.0, weather_event_cooldown - delta)
	if weather_event_remaining > 0.0:
		weather_event_remaining = max(0.0, weather_event_remaining - delta)
		if weather_event_remaining <= 0.0:
			weather_event_type = ""
			weather_event_cooldown = 32.0
			toast = "突发天气结束，视线恢复"
			toast_time = 2.4
		return
	if weather_event_cooldown > 0.0 or speed < 4.0:
		return
	var event_roll: Variant = int(abs(truck.position.z)) % 4
	weather_event_remaining = 14.0 + float(event_roll) * 4.0
	if event_roll == 0:
		weather_event_type = "暴雨"
		current_weather = "rain"
		weather_target_intensity = 0.92
		elif event_roll == 1:
			weather_event_type = "大雾"
			current_weather = "rain"
			weather_target_intensity = 0.48
		elif event_roll == 2:
			weather_event_type = "降雪"
			current_weather = "snow"
			weather_target_intensity = 0.86
		else:
			weather_event_type = "樱花飘落"
			current_weather = "sakura"
			weather_target_intensity = 0.78
	toast = "突发天气：" + weather_event_type
	toast_time = 3.0

func _format_clock() -> String:
	return "%02d:%02d" % [int(game_hour), int((game_hour - int(game_hour)) * 60.0)]

func _update_weather_audio(delta: float) -> void:
	# Weather is biome-driven for the prototype; later it can be replaced by a forecast manager.
	if weather_event_remaining <= 0.0:
		if current_scene == "山区雪岭":
			current_weather = "snow"
			weather_target_intensity = 0.78
		elif current_scene == "深山老林":
			current_weather = "rain"
			weather_target_intensity = 0.62
		elif current_scene == "动漫城市" and int(distance) % 3 == 0:
			if int(distance) % 6 == 0:
				current_weather = "sakura"
				weather_target_intensity = 0.72
			else:
				current_weather = "rain"
				weather_target_intensity = 0.38
		else:
			current_weather = "clear"
			weather_target_intensity = 0.0
		weather_intensity = move_toward(weather_intensity, weather_target_intensity, delta * 0.22)
	var speed_factor: Variant = clamp(speed / 21.0, 0.0, 1.0)
	var master_db: Variant = linear_to_db(max(music_volume * master_volume, 0.001))
	rain_player.volume_db = master_db + (-42.0 if current_weather != "rain" else lerp(-42.0, -12.0, weather_intensity))
	wind_player.volume_db = master_db + lerp(-30.0, -18.0, 0.35 + speed_factor * 0.65)
	wet_tire_player.volume_db = master_db + (-38.0 if current_weather != "rain" else lerp(-34.0, -9.0, speed_factor * weather_intensity))
	snow_tire_player.volume_db = master_db + (-38.0 if current_weather != "snow" else lerp(-34.0, -8.0, speed_factor * weather_intensity))
	wind_player.volume_db += 2.0 if current_weather == "sakura" else 0.0
	if spatial_tire_player:
		spatial_tire_player.volume_db = master_db + lerp(-42.0, -13.0, speed_factor) + (weather_intensity * 3.0 if current_weather == "rain" else 0.0)
		spatial_tire_player.pitch_scale = 0.86 + speed_factor * 0.28
	if current_weather == "rain" and weather_intensity > 0.5 and thunder_cooldown <= 0.0 and not thunder_player.playing:
		thunder_player.play()
		thunder_cooldown = 24.0 + randf() * 20.0

func _update_refueling(delta: float) -> void:
	var near_station: Variant = false
	for station_pos in station_positions:
		if truck.global_position.distance_to(station_pos) < 8.0:
			near_station = true
			break
	var can_refuel: Variant = near_station and speed < 1.5 and fuel < 99.5
	if can_refuel:
		var fuel_capacity: Variant = 100.0 + float(tank_level) * 10.0
		fuel = min(fuel_capacity, fuel + delta * 9.0)
		if not refueling:
			toast = "PARKED AT FUEL STATION"
			toast_time = 2.5
			_play_sfx("refuel_start", -9.0)
			_haptic(55, 0.25)
		refueling = true
	else:
		refueling = false

func _update_repairing(delta: float) -> void:
	var near_repair: Variant = false
	for station_pos in repair_positions:
		if truck.global_position.distance_to(station_pos) < 8.0:
			near_repair = true
			break
	var can_repair: Variant = near_repair and speed < 1.5 and damage > 0.5
	if can_repair and money >= 80:
		var repair_amount: Variant = min(damage, delta * 12.0)
		damage -= repair_amount
		money = max(0, money - int(ceil(repair_amount * 5.0)))
		if not repairing:
			toast = "REPAIRING TRUCK"
			toast_time = 2.5
			_play_sfx("repair_start", -9.0)
			_haptic(70, 0.3)
		repairing = true
	elif not can_repair or money < 80:
		if can_repair and money < 80 and not repairing:
			toast = "维修费用不足"
			toast_time = 2.0
		repairing = false

func _update_scene_name() -> void:
	var z: Variant = truck.position.z
	if z < -120.0:
		var chunk_index: Variant = int(floor((-z - 120.0) / CHUNK_LENGTH))
		var macro_region: Variant = int(floor(float(chunk_index) / 50.0))
		var macro_name: Variant = ["动漫城市新区", "乡村湖区", "深林国家公园", "高山雪谷", "金色平原"][macro_region % 5]
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
	var speed_zoom: Variant = clamp(abs(speed) / 21.0, 0.0, 1.0)
	var target: Vector3
	var look_target: Vector3
	if cockpit_mode:
		target = truck.global_position + Vector3(0, 2.65, -3.55)
		look_target = truck.global_position + Vector3(steer * 2.0, 2.45, -18.0)
		camera.fov = lerp(camera.fov, 70.0 + speed_zoom * 5.0, delta * 3.0)
	else:
		target = truck.global_position + Vector3(0, 5.2, 11.5)
		target.z += speed_zoom * 2.2
		target.y += delivery_camera_boost * 1.2
		look_target = truck.global_position + Vector3(0, 1.2, -5.0)
		camera.fov = lerp(camera.fov, 58.0 + speed_zoom * 7.0, delta * 3.0)
	hit_shake = move_toward(hit_shake, 0.0, delta * 2.8)
	delivery_camera_boost = move_toward(delivery_camera_boost, 0.0, delta * 1.6)
	var shake: Variant = Vector3(sin(Time.get_ticks_msec() * 0.08), cos(Time.get_ticks_msec() * 0.11), 0) * hit_shake * 0.22
	target += shake
	var camera_follow_speed: Variant = 4.0 if cockpit_mode else 3.2
	camera.global_position = camera.global_position.lerp(target, 1.0 - exp(-delta * camera_follow_speed))
	camera_look_target = camera_look_target.lerp(look_target, delta * 5.5)
	camera.look_at(camera_look_target, Vector3.UP)
	camera.rotation.z = lerp(camera.rotation.z, -steer * 0.035 + sin(Time.get_ticks_msec() * 0.09) * hit_shake * 0.018, delta * 6.0)

func _traffic_target_lane(index: int, car: Node3D) -> float:
	var preferred: Variant = traffic_lanes[index]
	var blocked: Variant = false
	for other_index in traffic.size():
		if other_index == index:
			continue
		var other: Variant = traffic[other_index]
		var same_lane: Variant = abs((other.position.x - car.position.x)) < 1.35
		var ahead: Variant = other.position.z < car.position.z and car.position.z - other.position.z < 16.0
		if same_lane and ahead:
			blocked = true
			break
	if abs(car.position.z - truck.position.z) < 18.0 and abs(car.position.x - truck.position.x) < 1.7:
		blocked = true
	if not blocked:
		return preferred
	var alternatives: Variant = [-3.2, 0.0, 3.2]
	for candidate in alternatives:
		if abs(candidate - preferred) < 0.1:
			continue
		var clear: Variant = true
		for other in traffic:
			var other_lane: Variant = traffic_lanes[traffic.find(other)]
			if abs(other_lane - candidate) < 0.1 and abs(other.position.z - car.position.z) < 18.0:
				clear = false
				break
		if clear:
			return candidate
	return preferred

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
		var gear: Variant = -1 if speed < -0.35 else (0 if abs(speed) < 0.35 else clamp(int(speed / 3.2) + 1, 1, 12))
		interior_gear_display.text = "GEAR R" if drive_mode == "R" else ("GEAR N" if drive_mode == "N" else ("GEAR D%02d" % gear if gear > 0 else "GEAR D"))
	if interior_indicator_display:
		var indicator_on: Variant = fmod(Time.get_ticks_msec() / 1000.0, 0.65) < 0.32
		var direction: Variant = "L" if steer < -0.14 else ("R" if steer > 0.14 else "○")
		var night_lights: Variant = game_hour < 6.0 or game_hour >= 19.0
		interior_indicator_display.text = "%s  %s%s" % [direction if indicator_on else "○", "HIGH BEAM" if high_beam else ("LIGHTS ON" if night_lights else "LIGHTS"), "" ]
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
		interior_nav_display.text = "%s\n%s\n%.1f km\n%s" % ["合同运输中" if task_active else "货运市场待命", destination, max(task_distance_goal - distance, 0.0), task_title]
		interior_nav_display.modulate = Color("#b8d8ff") if current_weather == "rain" else (Color("#f0f4ff") if current_weather == "snow" else (Color("#ffb7cf") if current_weather == "sakura" else MINT))
	for mirror in interior_mirrors:
		mirror.rotation_degrees.y = (12.0 if mirror.position.x > 0.0 else -12.0) + steer * 5.0
	if mirrors_enabled:
		for i in mirror_cameras.size():
			var mirror_camera: Variant = mirror_cameras[i]
			var side: Variant = -1.0 if i == 0 else 1.0
			mirror_camera.global_position = truck.global_position + Vector3(side * 1.7, 2.25, -2.8)
			mirror_camera.look_at(truck.global_position + Vector3(side * 3.0, 1.4, 18.0), Vector3.UP)
	var wiper_active: Variant = current_weather == "rain" or current_weather == "snow"
	wiper_audio_cooldown = max(0.0, wiper_audio_cooldown - delta)
	if wiper_active and not previous_wiper_active:
		_play_sfx("wiper_swipe", -14.0)
		wiper_audio_cooldown = 0.42
	previous_wiper_active = wiper_active
	if wiper_active:
		wiper_phase = fmod(wiper_phase + delta * (3.0 + weather_intensity * 3.0 + speed * 0.08), TAU)
		if wiper_phase < 0.18 and wiper_audio_cooldown <= 0.0:
			_play_sfx("wiper_swipe", -14.0)
			wiper_audio_cooldown = 0.42
		for i in interior_wipers.size():
			interior_wipers[i].rotation_degrees.z = (18.0 if i == 1 else -18.0) + sin(wiper_phase) * (24.0 if i == 1 else -24.0)
	else:
		for i in interior_wipers.size():
			interior_wipers[i].rotation_degrees.z = 18.0 if i == 1 else -18.0
	var cabin_brightness: Variant = clamp(1.2 - sin((game_hour - 6.0) / 12.0 * PI) * 1.2, 0.12, 1.0)
	for lamp in interior_lamps:
		var lamp_material: Variant = lamp.material_override as StandardMaterial3D
		lamp_material.emission_energy_multiplier = cabin_brightness * 1.6
	for badge_light in cargo_badge_lights:
		var badge_material: Variant = badge_light.material_override as StandardMaterial3D
		badge_material.emission_energy_multiplier = cabin_brightness * 1.4
	for reflector in safety_reflectors:
		var reflector_material: Variant = reflector.material_override as StandardMaterial3D
		var reflector_damage: Variant = clamp((damage - 45.0) / 55.0, 0.0, 1.0)
		reflector_material.emission_enabled = reflector_damage > 0.01
		reflector_material.emission = CORAL
		reflector_material.emission_energy_multiplier = cabin_brightness * (1.8 + reflector_damage * 2.4)

func _complete_delivery() -> void:
	var grade: String = _task_grade(task_score)
	var combo_bonus: float = min(0.15, task_combo / 60.0 * 0.05)
	var multiplier: float = min(1.40, _task_payout_multiplier(grade) + combo_bonus)
	var payout: int = maxi(1, int(round(float(task_reward) * multiplier)))
	last_delivery_grade = grade
	last_delivery_payout = payout
	money += payout
	toast = "任务完成   %s级   Combo %dx   +€%d" % [grade, int(task_combo / 3.0), payout]
	toast_time = 4.0
	_show_grade_flash(grade, payout, multiplier)
	_play_sfx("delivery_complete", -5.0)
	delivery_camera_boost = 1.0
	if delivery_flash:
		delivery_flash.global_position = truck.global_position + Vector3(0, 3.0, -4.0)
		delivery_flash.light_energy = 6.0
		var delivery_tween: Variant = create_tween()
		delivery_tween.tween_property(delivery_flash, "light_energy", 0.0, 0.45)
	_haptic(220, 0.9)
	delivery_count += 1

	distance = 0.0
	cargo_index = (cargo_index + 1) % 3
	route_goal = 10.0 + float(cargo_index * 2)
	destination = ["INNSBRUCK", "MILAN", "LYON"][cargo_index]
	_apply_livery(livery_index)
	_unlock_achievement("FIRST_DELIVERY", "完成第一单货物运输")
	if grade == "S":
		_unlock_achievement("PERFECT_HAUL", "以 S 级完成运输任务")
	if task_incidents == 0:
		_unlock_achievement("CLEAN_HAUL", "零碰撞完成运输任务")
	task_index = (task_index + 1) % 4
	_generate_freight_offers()
	toast = "合同完成：返回货运市场选择下一单"
	toast_time = 4.0
	_save_game()

func _show_grade_flash(grade: String, payout: int, multiplier: float) -> void:
	if not ui_grade_flash:
		return
	var grade_color: Color = {"S": Color("#ffd166"), "A": Color("#74d0ad"), "B": Color("#86d6e8"), "C": Color("#ef6f61")}.get(grade, CREAM)
	ui_grade_flash.text = "%s 级运输完成\n奖励 ×%.2f   +€%d" % [grade, multiplier, payout]
	ui_grade_flash.add_theme_color_override("font_color", grade_color)
	ui_grade_flash.modulate = Color.WHITE
	ui_grade_flash.scale = Vector2(0.72, 0.72)
	ui_grade_flash.pivot_offset = ui_grade_flash.size * 0.5
	ui_grade_flash.visible = true
	var flash_tween: Tween = create_tween().set_parallel(true)
	flash_tween.tween_property(ui_grade_flash, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(ui_grade_flash, "modulate", Color.WHITE, 0.12)
	flash_tween.chain().tween_interval(2.0)
	flash_tween.chain().tween_property(ui_grade_flash, "modulate:a", 0.0, 0.5)
	flash_tween.chain().tween_callback(func(): ui_grade_flash.visible = false)

func _setup_task(index: int) -> void:
	var tasks: Array = [
		{"title": "限时货运", "condition": "delivery", "distance": 12.0, "time": 184.0, "reward": 640},
		{"title": "夜行急件", "condition": "night", "distance": 6.0, "time": 150.0, "reward": 820},
		{"title": "暴雨护送", "condition": "rain", "distance": 6.0, "time": 165.0, "reward": 900},
		{"title": "无损运输", "condition": "clean", "distance": 10.0, "time": 210.0, "reward": 760}
	]
	var task: Dictionary = tasks[clampi(index, 0, tasks.size() - 1)]
	task_title = str(task["title"])
	task_condition = str(task["condition"])
	task_distance_goal = float(task["distance"])
	task_time_limit = float(task["time"])
	task_time_remaining = task_time_limit
	task_reward = int(task["reward"])
	toast = "新任务：" + task_title
	toast_time = 3.0

func _task_grade(score: float) -> String:
	if score >= 90.0:
		return "S"
	if score >= 80.0:
		return "A"
	if score >= 65.0:
		return "B"
	return "C"

func _task_payout_multiplier(grade: String) -> float:
	return {"S": 1.25, "A": 1.10, "B": 0.95, "C": 0.75}.get(grade, 0.75)

func _update_task_score(delta: float, throttle: float, braking: float) -> void:
	if not task_active:
		return
	task_score_cooldown = max(0.0, task_score_cooldown - delta)
	task_peak_speed = max(task_peak_speed, abs(speed) * 4.4)
	if task_score_cooldown > 0.0:
		task_combo = max(0.0, task_combo - delta * 0.5)
		return
	# Reward controlled inputs without making the score grindy or mandatory.
	if speed > 2.0 and abs(steer) < 0.16 and braking < 0.12 and throttle > 0.12 and throttle < 0.82:
		task_score = min(100.0, task_score + delta * 0.12)
		task_combo = min(180.0, task_combo + delta)
		best_task_combo = max(best_task_combo, task_combo)
	else:
		task_combo = max(0.0, task_combo - delta * 0.25)
	if speed > 16.0 and abs(steer) > 0.72:
		task_score = max(0.0, task_score - delta * 1.2)
	if braking > 0.82 and speed > 16.0:
		task_score = max(0.0, task_score - delta * 0.35)

func _task_condition_met() -> bool:
	if task_condition == "night":
		return game_hour < 6.0 or game_hour >= 19.0
	if task_condition == "rain":
		return current_weather == "rain" and weather_intensity > 0.45
	if task_condition == "clean":
		return damage <= 20.0
	return true

func _update_task(delta: float) -> void:
	if not task_active:
		return
	task_time_remaining = max(0.0, task_time_remaining - delta)
		if task_time_remaining <= 0.0:
			task_active = false
			distance = 0.0
			toast = "合同失败：时间耗尽，返回货运市场"
			toast_time = 3.0
			_generate_freight_offers()
			_save_game()
			return
	if distance >= task_distance_goal and _task_condition_met():
		task_active = false
		_complete_delivery()

func _accept_task() -> void:
	_toggle_freight_market()

func _unlock_achievement(key: String, description: String) -> void:
	if achievements.has(key):
		return
	achievements[key] = {"description": description, "time": Time.get_datetime_string_from_system()}
	toast = "成就解锁：" + description
	toast_time = 3.2

func _toggle_pause() -> void:
	paused = not paused
	toast = "PAUSED" if paused else "BACK ON THE ROAD"
	toast_time = 2.0

func _toggle_camera_mode() -> void:
	if camera_toggle_cooldown > 0.0:
		return
	camera_toggle_cooldown = 0.45
	cockpit_mode = not cockpit_mode
	_play_sfx("ui_click", -10.0)
	toast = "驾驶舱视角" if cockpit_mode else "第三人称视角"
	toast_time = 2.0

func _toggle_high_beam() -> void:
	high_beam = not high_beam
	_play_sfx("ui_click", -10.0)
	toast = "远光灯开启" if high_beam else "近光灯开启"
	toast_time = 1.8

func _update_ui() -> void:
	if not ui_speed:
		return
	var cargo: Variant = task_cargo if task_active else ["山地茶叶", "草莓果酱", "阿尔卑斯零件"][cargo_index]
	var branch_hint: Variant = _get_branch_hint()
	ui_route.text = "%s：%s\n↗ %s\n%s  →  %s" % ["合同运输中" if task_active else "货运市场", task_title, branch_hint if branch_hint != "" else "ROUTE AHEAD", cargo, destination]
	ui_speed.text = "%02d km/h" % int(speed * 4.4)
	ui_speed.modulate = CORAL if speed > 18.0 else (Color("#ffd166") if speed > 12.0 else CREAM)
	var weather_name: Variant = {"clear": "晴", "rain": "雨", "snow": "雪", "sakura": "樱花"}.get(current_weather, "多云")
	ui_stats.modulate = Color("#b8d8ff") if current_weather == "rain" else (Color("#f0f4ff") if current_weather == "snow" else (Color("#ffb7cf") if current_weather == "sakura" else Color("#c0cde4")))
	var active_grade: String = _task_grade(task_score) if task_active else last_delivery_grade
	ui_stats.text = "目标 %.1f/%0.1f km   剩余 %ds\n档位 %s   TIME %s   %s   FUEL %d%%\nDAMAGE %d%%   评分 %03d  %s\nCOMBO ×%02d   €%d 奖励   €%d 余额\n碰撞 %d" % [distance, task_distance_goal, int(task_time_remaining), drive_mode, _format_clock(), weather_name, int(fuel), int(damage), int(task_score), active_grade, int(task_combo / 3.0), task_reward, money, task_incidents]
	ui_stats.text += "\nBEST %.1f km   DELIVERIES %d" % [best_distance, delivery_count]
	if task_button:
		task_button.text = "运输中" if task_active else "货运市场"
		task_button.modulate = MINT if task_active else Color("#ffd166")
	if headlight_mode_button:
		headlight_mode_button.text = "远光 ON" if high_beam else "近光灯"
		headlight_mode_button.modulate = Color("#fff0a7") if high_beam else CREAM
	ui_toast.text = toast if toast_time > 0.0 else ""
	ui_toast.modulate = Color("#ffd166") if toast.find("完成") >= 0 or toast.find("DELIVERY") >= 0 else CREAM
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
	var traveled: Variant = max(0.0, -truck.position.z - 120.0)
	var next_chunk: Variant = max(0, int(floor(traveled / CHUNK_LENGTH)))
	if next_chunk == active_chunk and stream_chunks.size() >= 6:
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
	# Keep one safety chunk behind and six chunks ahead; this hard cap prevents
	# long-haul sessions from accumulating streamed scenery in memory.
	while stream_chunks.size() > 7:
		var farthest_index: Variant = -1
		var farthest_distance: Variant = -1
		for loaded_index in stream_chunks.keys():
			var chunk_distance: Variant = abs(int(loaded_index) - active_chunk)
			if chunk_distance > farthest_distance:
				farthest_distance = chunk_distance
				farthest_index = int(loaded_index)
		if farthest_index < 0:
			break
		var farthest_root: Node3D = stream_chunks[farthest_index]
		farthest_root.queue_free()
		stream_chunks.erase(farthest_index)

func _update_pedestrians(delta: float) -> void:
	var now: Variant = Time.get_ticks_msec() * 0.001
	var animate_skeletons: Variant = quality_mode >= 2 or traffic_ai_frame % 3 == 0
	var alive: Array[Node3D] = []
	for person in pedestrian_nodes:
		if not is_instance_valid(person):
			continue
		alive.append(person)
		var phase: Variant = float(person.get_meta("walk_phase", 0.0))
		var side: Variant = float(person.get_meta("walk_side", 1.0))
		person.position.z += side * delta * 0.55
		person.position.x += sin(now * 0.8 + phase) * delta * 0.18
		person.rotation.y = side * PI * 0.5
		if animate_skeletons:
			for arm in person.find_children("PedestrianArm", "MeshInstance3D", true, false):
				arm.rotation.z = sin(now * 5.0 + phase) * 0.22
			var body: Variant = person.get_node_or_null("PedestrianBody")
			if body:
				body.position.y = 0.55 + sin(now * 5.0 + phase) * 0.025
		if abs(person.position.z) > 36.0:
			person.position.z = -sign(person.position.z) * 34.0
	pedestrian_nodes = alive

func _ensure_stream_chunk(chunk_index: int) -> void:
	if stream_chunks.has(chunk_index):
		return
	var root: Variant = Node3D.new()
	root.name = "RouteChunk_%03d" % chunk_index
	root.position = Vector3(0, 0, -120.0 - float(chunk_index) * CHUNK_LENGTH)
	add_child(root)
	var rng: Variant = RandomNumberGenerator.new()
	rng.seed = stream_seed + chunk_index * 7919
	var biome: Variant = int(floor(float(chunk_index) / 50.0)) % 5 # 50 km macro-regions.
	for local_z in range(-480, 481, 80):
		_add_chunk_road_segment(root, local_z, biome, rng)
		if biome == 0 and abs(local_z) % 160 == 0:
			_add_chunk_city_road_detail(root, local_z, rng, chunk_index % 4)
			_add_chunk_city_signal(root, local_z)
	_add_chunk_road_network(root, biome, rng, chunk_index)
	for prop_index in range(8):
		var local_z: Variant = -500.0 + float(prop_index) * 125.0 + rng.randf_range(-28.0, 28.0)
		var side: Variant = -1.0 if prop_index % 2 == 0 else 1.0
		var lateral: Variant = rng.randf_range(9.0, 18.0) * side
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
	var primary_path: Variant = ""
	var primary_pos: Variant = Vector3.ZERO
	var primary_scale: Variant = 1.0
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
	var instance: Variant = FreeAssetCatalog.instantiate(root, primary_path, primary_pos, primary_scale, rng.randf_range(-0.18, 0.18))
	FreeAssetCatalog.add_lod_visibility(instance, 50.0, 135.0)

func _add_chunk_road_network(root: Node3D, biome: int, rng: RandomNumberGenerator, chunk_index: int) -> void:
	# Every streamed kilometer gets at least one visible secondary road.
	# The road type changes by biome so the world reads as a network, not a single ribbon.
	var secondary_offset: Variant = 15.0 if biome == 0 or biome == 4 else 12.0
	var road_width: Variant = 6.0 if biome == 0 or biome == 4 else 4.2
	var road_name: Variant = ["CityRingRoad", "FarmSideRoad", "ForestServiceRoad", "MountainViewRoad", "PlainsFrontageRoad"][biome]
	for segment_index in range(5):
		var local_z: Variant = -400.0 + float(segment_index) * 200.0
		var world_z: Variant = root.position.z + local_z
		var base_center: Variant = _road_center_at(world_z)
		var bend: Variant = sin(world_z * 0.0017 + float(chunk_index) * 0.7) * 1.4
		var branch: Variant = Node3D.new()
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
			var connector: Variant = Node3D.new()
			connector.name = road_name + "Connector"
			connector.position = Vector3(_road_center_at(root.position.z + connector_z), _road_height_at(root.position.z + connector_z) + 0.08, connector_z)
			connector.rotation.z = deg_to_rad(90.0)
			root.add_child(connector)
			_box(connector, Vector3(0.9, 0.12, secondary_offset), Vector3(secondary_offset * 0.5, 0, 0), ASPHALT, road_name + "ConnectorSurface")
			_box(connector, Vector3(0.12, 0.18, secondary_offset), Vector3(secondary_offset * 0.5, 0.12, -road_width * 0.5), CREAM, road_name + "ConnectorMark")
	# Route signage makes each road leg legible instead of decorative geometry only.
	var sign: Variant = Node3D.new()
	sign.name = road_name + "RouteSign"
	sign.position = Vector3(secondary_offset * (-1.0 if chunk_index % 2 == 0 else 1.0), 0.0, -455.0)
	root.add_child(sign)
	_box(sign, Vector3(0.16, 2.4, 0.16), Vector3.ZERO + Vector3(0, 1.2, 0), INK, road_name + "SignPost")
	_box(sign, Vector3(2.8, 0.9, 0.14), Vector3(0, 2.45, 0), Color("#3478a8"), road_name + "RoutePanel")
	_box(sign, Vector3(1.55, 0.10, 0.08), Vector3(0.3, 2.45, -0.1), CREAM, road_name + "RouteArrow")

func _road_center_at(world_z: float) -> float:
	var macro: Variant = sin(world_z * 0.0027 + 0.8) * 3.0
	var long_curve: Variant = sin(world_z * 0.00072 + 2.1) * 2.4
	return clamp(macro + long_curve, -5.0, 5.0)

func _road_height_at(world_z: float) -> float:
	var macro_region: Variant = int(floor(max(0.0, -world_z - 120.0) / 50000.0)) % 5
	var rolling: Variant = sin((world_z - 95.0) * 0.0018) * 2.2 + sin((world_z - 95.0) * 0.00043) * 1.5
	if macro_region == 3:
		return rolling + sin((world_z - 95.0) * 0.0008) * 8.0
	if macro_region == 1 or macro_region == 4:
		return rolling * 0.45
	return rolling

func _add_chunk_road_segment(root: Node3D, local_z: float, biome: int, rng: RandomNumberGenerator) -> void:
	var world_z: Variant = root.position.z + local_z
	var center: Variant = _road_center_at(world_z)
	var ahead: Variant = _road_center_at(world_z + 8.0)
	var height: Variant = _road_height_at(world_z)
	var ahead_height: Variant = _road_height_at(world_z + 8.0)
	var segment: Variant = Node3D.new()
	segment.name = "CurvedRoadSegment"
	segment.position = Vector3(center, height, local_z)
	segment.rotation.y = atan2(ahead - center, 8.0)
	segment.rotation.x = -atan2(ahead_height - height, 8.0)
	root.add_child(segment)
	var road_width: Variant = 12.0
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
			var edge_marker: Variant = _box(segment, Vector3(0.12, 0.18, 0.16), Vector3(side * (road_width * 0.5 + 0.12), 0.38, marker_z), Color("#ffd166"), "ChunkEdgeReflector")
			var edge_material: Variant = edge_marker.material_override as StandardMaterial3D
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
	var world_z: Variant = root.position.z + local_z
	var center: Variant = _road_center_at(world_z)
	var height: Variant = _road_height_at(world_z)
	var detail: Variant = Node3D.new()
	detail.position = Vector3(center, height, local_z)
	detail.rotation.y = atan2(_road_center_at(world_z + 8.0) - center, 8.0)
	root.add_child(detail)
	for side in [-1.0, 1.0]:
		_box(detail, Vector3(2.0, 0.16, 82.0), Vector3(side * 8.0, 0.12, 0), Color("#858b9d"), "CitySidewalk")
		for lamp_z in [-30.0, 0.0, 30.0]:
			if district == 3 and abs(lamp_z) < 1.0:
				continue
			_box(detail, Vector3(0.16, 4.8, 0.16), Vector3(side * 8.8, 2.45, lamp_z), INK, "ChunkStreetLamp")
			var lamp: Variant = _box(detail, Vector3(0.42, 0.18, 0.32), Vector3(side * 8.45, 4.55, lamp_z), Color("#ffd166"), "ChunkLampGlow")
			var lamp_material: Variant = lamp.material_override as StandardMaterial3D
			lamp_material.emission_enabled = true
			lamp_material.emission = Color("#ffb35c")
			lamp_material.emission_energy_multiplier = 2.2
			for building_index in range(2):
				var building_z: Variant = -24.0 + float(building_index) * 48.0
				var facade_color: Variant = [Color("#6d79b8"), Color("#d47783"), Color("#5a9fb0")][(district + building_index) % 3]
				_box(detail, Vector3(4.2, 5.5 + rng.randf_range(0.0, 3.0), 10.0), Vector3(side * 12.2, 3.0, building_z), facade_color, "AnimeCityFacade")
				var sign_panel: Variant = _box(detail, Vector3(3.0, 0.62, 0.12), Vector3(side * 9.9, 4.0, building_z - 4.2), Color("#ffd166" if building_index == 0 else "#8fa8ff"), "NeonShopSign")
				var sign_material: Variant = sign_panel.material_override as StandardMaterial3D
				sign_material.emission_enabled = true
				sign_material.emission = sign_material.albedo_color
				sign_material.emission_energy_multiplier = 2.8
				for window_index in range(3):
					_box(detail, Vector3(0.9, 0.72, 0.08), Vector3(side * 9.95, 2.1, building_z - 2.6 + window_index * 2.5), Color("#bfe6ff"), "AnimeWindow")
	if district == 2:
		_box(detail, Vector3(1.2, 0.12, 70.0), Vector3(0, 0.22, 0), Color("#66728b"), "IndustrialMedian")
		if rng.randf() > (0.15 + district * 0.12):
			for stripe in range(-4, 5):
				_box(detail, Vector3(0.42, 0.025, 7.0), Vector3(float(stripe) * 0.62, 0.22, 0), CREAM, "CityCrosswalk")
	_add_city_pedestrians(detail, district, rng)

func _add_city_pedestrians(parent: Node3D, district: int, rng: RandomNumberGenerator) -> void:
	var palette: Variant = [Color("#ef6f61"), Color("#74d0ad"), Color("#ffd166"), Color("#8fa8ff")]
	for i in 4:
		var person: Variant = Node3D.new()
		person.name = "CityPedestrian_%d_%d" % [district, i]
		var side: Variant = -1.0 if i % 2 == 0 else 1.0
		person.position = Vector3(side * rng.randf_range(6.8, 8.4), 0.0, rng.randf_range(-32.0, 32.0))
		person.set_meta("walk_phase", rng.randf_range(0.0, TAU))
		person.set_meta("walk_side", side)
		parent.add_child(person)
		_box(person, Vector3(0.34, 0.9, 0.28), Vector3(0, 0.55, 0), palette[(district + i) % palette.size()], "PedestrianBody")
		_box(person, Vector3(0.10, 0.58, 0.12), Vector3(-0.25, 0.62, 0), INK, "PedestrianArm")
		_box(person, Vector3(0.10, 0.58, 0.12), Vector3(0.25, 0.62, 0), INK, "PedestrianArm")
		var head: Variant = SphereMesh.new()
		head.radius = 0.18
		head.height = 0.36
		var head_node: Variant = MeshInstance3D.new()
		head_node.name = "PedestrianHead"
		head_node.mesh = head
		head_node.material_override = _mat(Color("#ffd8b0"))
		head_node.position = Vector3(0, 1.15, 0)
		person.add_child(head_node)
		pedestrian_nodes.append(person)

func _add_chunk_city_signal(root: Node3D, local_z: float) -> void:
	var signal_root: Variant = Node3D.new()
	signal_root.name = "ChunkSignalIntersection"
	signal_root.position = Vector3(_road_center_at(root.position.z + local_z), _road_height_at(root.position.z + local_z), local_z)
	root.add_child(signal_root)
	for side in [-1.0, 1.0]:
		_box(signal_root, Vector3(0.18, 4.0, 0.18), Vector3(side * 7.0, 2.0, 0), INK, "ChunkSignalPole")
		var red: Variant = _box(signal_root, Vector3(0.42, 0.42, 0.25), Vector3(side * 7.0, 4.25, 0), CORAL, "ChunkSignalRed")
		var green: Variant = _box(signal_root, Vector3(0.42, 0.42, 0.25), Vector3(side * 7.0, 3.65, 0), MINT, "ChunkSignalGreen")
		traffic_signal_lamps.append(red)
		traffic_signal_lamps.append(green)

func _near_signal_intersection(world_z: float) -> bool:
	return abs(fmod(abs(world_z), 160.0) - 0.0) < 12.0 or abs(fmod(abs(world_z), 160.0) - 160.0) < 12.0

func _signal_is_red(world_z: float) -> bool:
	return fmod(Time.get_ticks_msec() / 1000.0 + abs(world_z) * 0.001, 12.0) < 5.0

func _update_signal_visuals() -> void:
	var red_on: Variant = _signal_is_red(truck.position.z)
	for i in traffic_signal_lamps.size():
		if is_instance_valid(traffic_signal_lamps[i]):
			traffic_signal_lamps[i].visible = (i % 2 == 0) == red_on

func _add_chunk_prop(root: Node3D, biome: int, pos: Vector3, rng: RandomNumberGenerator, index: int, district: int = 0) -> void:
	if biome == 0:
		var building_size: Variant = Vector3(rng.randf_range(3.5, 7.5), rng.randf_range(3.0, 10.0), rng.randf_range(3.5, 7.5))
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
			var canyon_rock: Variant = _cylinder(root, rng.randf_range(1.4, 2.8), rng.randf_range(3.0, 7.0), pos + Vector3(0, 1.6, 0), Color("#59627b"), "CanyonRock")
			canyon_rock.rotation_degrees.z = rng.randf_range(-20.0, 20.0)
	elif biome == 3:
		if district == 0:
			var glacier: Variant = _cylinder(root, rng.randf_range(1.0, 2.2), rng.randf_range(3.0, 7.0), pos + Vector3(0, 1.5, 0), Color("#9fe3ff"), "GlacierIce")
			glacier.rotation_degrees.z = rng.randf_range(-18.0, 18.0)
		elif district == 1:
			_add_chunk_tree(root, pos, rng.randf_range(1.0, 1.7), index + 1)
		else:
			var rock: Variant = _cylinder(root, rng.randf_range(1.0, 2.2), rng.randf_range(2.0, 5.0), pos + Vector3(0, 1.0, 0), [Color("#59627b"), Color("#7b7890"), Color("#8d9caf")][index % 3], "ChunkMountainRock")
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
				var blade: Variant = _box(root, Vector3(0.12, 2.5, 0.1), pos + Vector3(0, 8.0, 0), CREAM, "WindTurbineBlade")
				blade.rotation_degrees.z = rad_to_deg(angle)
		elif district == 3:
			_box(root, Vector3(6.0, 0.08, 7.0), pos, Color("#31517c"), "PlainSolarPanel")
			_box(root, Vector3(0.12, 1.2, 0.12), pos + Vector3(0, 0.6, 0), Color("#d5dded"), "PlainSolarPost")
		else:
			_box(root, Vector3(rng.randf_range(3.0, 7.0), 0.2, rng.randf_range(4.0, 10.0)), pos, [Color("#d3a35f"), Color("#a8c46f"), Color("#e7c97b")][index % 3], "ChunkPlainField")

func _add_chunk_tree(root: Node3D, pos: Vector3, scale_value: float, index: int) -> void:
	_box(root, Vector3(0.55 * scale_value, 2.7 * scale_value, 0.55 * scale_value), pos + Vector3(0, 1.35 * scale_value, 0), Color("#76513d"), "ChunkTreeTrunk")
	var crown: Variant = _cylinder(root, 1.8 * scale_value, 3.8 * scale_value, pos + Vector3(0, 3.4 * scale_value, 0), [Color("#4c9c79"), Color("#397a68"), Color("#6da66b")][index % 3], "ChunkTreeCrown")
	crown.rotation_degrees.z = float(index * 17 % 25)

func _add_chunk_city_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	_box(root, Vector3(18.0, 0.35, 0.55), Vector3(0, 7.2, -52), Color("#66728b"), "ChunkCityArch")
	_box(root, Vector3(0.45, 7.0, 0.55), Vector3(-8.7, 3.5, -52), CORAL, "ChunkCityPillar")
	_box(root, Vector3(0.45, 7.0, 0.55), Vector3(8.7, 3.5, -52), CORAL, "ChunkCityPillar")
	_add_landmark_sign(root, LANDMARK_CITY_TEXTURE, Vector3(0, 4.7, -51.6))

func _add_chunk_village_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	_box(root, Vector3(0.3, 5.0, 0.3), Vector3(-8.7, 2.5, -52), INK, "ChunkFarmPole")
	_box(root, Vector3(0.3, 5.0, 0.3), Vector3(8.7, 2.5, -52), INK, "ChunkFarmPole")
	_box(root, Vector3(17.8, 0.28, 0.3), Vector3(0, 5.0, -52), Color("#f4b86b"), "ChunkFarmBeam")
	_add_landmark_sign(root, LANDMARK_RURAL_TEXTURE, Vector3(0, 3.25, -51.6))

func _add_chunk_forest_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	for side in [-1.0, 1.0]:
		_add_chunk_tree(root, Vector3(side * 8.5, 0, -52), rng.randf_range(1.4, 1.9), int(rng.randi()))
	_add_landmark_sign(root, LANDMARK_FOREST_TEXTURE, Vector3(0, 4.0, -51.6))

func _add_chunk_mountain_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	_box(root, Vector3(16.0, 0.5, 0.8), Vector3(0, 5.8, -52), Color("#38405b"), "ChunkPassBeam")
	_box(root, Vector3(0.7, 5.8, 0.8), Vector3(-7.6, 2.9, -52), Color("#59627b"), "ChunkPassPillar")
	_box(root, Vector3(0.7, 5.8, 0.8), Vector3(7.6, 2.9, -52), Color("#59627b"), "ChunkPassPillar")
	_add_landmark_sign(root, LANDMARK_MOUNTAIN_TEXTURE, Vector3(0, 3.65, -51.6))

func _add_chunk_plain_gate(root: Node3D, rng: RandomNumberGenerator) -> void:
	for side in [-1.0, 1.0]:
		_box(root, Vector3(0.22, 8.0, 0.22), Vector3(side * 12.0, 4.0, -52), Color("#d5dded"), "ChunkWindPole")
		_box(root, Vector3(0.14, 3.5, 0.14), Vector3(side * 12.0, 8.0, -52), CREAM, "ChunkWindBlade")
	_add_landmark_sign(root, LANDMARK_PLAINS_TEXTURE, Vector3(0, 4.7, -51.6))

func _add_landmark_sign(root: Node3D, texture: Texture2D, pos: Vector3) -> void:
	var sign: Variant = MeshInstance3D.new()
	sign.name = "BiomeLandmarkSign"
	var mesh: Variant = QuadMesh.new()
	mesh.size = Vector2(8.0, 2.25)
	var material: Variant = StandardMaterial3D.new()
	material.albedo_texture = texture
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = material
	sign.mesh = mesh
	sign.position = pos
	root.add_child(sign)

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
				var x: Variant = 10.0 + float(col) * 2.1
				var z: Variant = -4.0 + float(row) * 3.2
				_box(root, Vector3(1.6, 0.08, 2.0), Vector3(x, 1.3, z), Color("#31517c"), "SolarPanel")
				_box(root, Vector3(0.12, 1.2, 0.12), Vector3(x, 0.65, z), Color("#d5dded"), "SolarPost")

func _add_chunk_mileage_marker(root: Node3D, chunk_index: int, rng: RandomNumberGenerator) -> void:
	var marker_z: Variant = rng.randf_range(-410.0, -300.0)
	var side: Variant = -1.0 if chunk_index % 2 == 0 else 1.0
	var x: Variant = side * 7.2
	_box(root, Vector3(0.16, 2.2, 0.16), Vector3(x, 1.1, marker_z), INK, "KilometerPost")
	_box(root, Vector3(1.8, 0.8, 0.12), Vector3(x, 2.25, marker_z), [CORAL, MINT, Color("#66728b")][chunk_index % 3], "KilometerPlate")
	_box(root, Vector3(1.1, 0.12, 0.06), Vector3(x, 2.25, marker_z - 0.08), CREAM, "KilometerTextStripe")

func _add_chunk_rest_area(root: Node3D, rng: RandomNumberGenerator) -> void:
	var rest_z: Variant = rng.randf_range(80.0, 260.0)
	var side: Variant = -1.0 if rng.randf() > 0.5 else 1.0
	var rest_x: Variant = side * 15.0
	_box(root, Vector3(10.0, 0.08, 28.0), Vector3(rest_x, 0.03, rest_z), Color("#5b6d73"), "RestAreaLot")
	_box(root, Vector3(7.0, 2.8, 3.8), Vector3(rest_x, 1.4, rest_z - 8.0), Color("#8e9bd1"), "RestAreaBuilding")
	_box(root, Vector3(7.5, 0.25, 4.3), Vector3(rest_x, 2.95, rest_z - 8.0), Color("#ffd166"), "RestAreaRoof")
	for parking in [-5.0, 0.0, 5.0]:
		_box(root, Vector3(3.6, 0.04, 7.0), Vector3(rest_x + side * 3.0, 0.08, rest_z + parking), CREAM, "RestParkingBay")
	_add_landmark_sign(root, FACILITY_FUEL_TEXTURE, Vector3(rest_x - side * 2.8, 3.4, rest_z - 8.0))
	_add_landmark_sign(root, FACILITY_REPAIR_TEXTURE, Vector3(rest_x + side * 2.8, 3.4, rest_z - 8.0))

func _add_chunk_branch(root: Node3D, local_z: float, side: float, angle: float, branch_name: String) -> void:
	var world_z: Variant = root.position.z + local_z
	var center: Variant = _road_center_at(world_z)
	var height: Variant = _road_height_at(world_z)
	var branch: Variant = Node3D.new()
	branch.name = branch_name
	branch.position = Vector3(center + side * 5.0, height + 0.04, local_z)
	branch.rotation.y = side * angle
	root.add_child(branch)
	_box(branch, Vector3(5.0, 0.16, 82.0), Vector3.ZERO, ASPHALT, branch_name + "Surface")
	_box(branch, Vector3(0.16, 0.3, 82.0), Vector3(-2.35, 0.16, 0), INK, branch_name + "Edge")
	_box(branch, Vector3(0.16, 0.3, 82.0), Vector3(2.35, 0.16, 0), INK, branch_name + "Edge")
	_box(branch, Vector3(0.18, 2.0, 0.18), Vector3(side * 2.8, 1.0, -34.0), INK, branch_name + "SignPost")
	_box(branch, Vector3(1.8, 0.7, 0.12), Vector3(side * 2.8, 2.05, -34.0), Color("#3478a8"), branch_name + "Sign")
