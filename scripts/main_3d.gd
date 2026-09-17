extends Node3D

# Anime Haul 3D — Android-friendly third-person truck driving prototype.
# Art: stylized low-poly 3D with warm cel-like colors and ink-dark outlines simulated by silhouettes.
# Audio: realistic-style local diesel and air-brake WAV loops.

var truck: Node3D
var camera: Camera3D
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
var toast := "READY TO HAUL"
var toast_time := 3.0
var ui_speed: Label
var ui_route: Label
var ui_stats: Label
var ui_toast: Label
var engine_player: AudioStreamPlayer
var brake_player: AudioStreamPlayer

const ROAD_WIDTH := 12.0
const ROAD_LENGTH := 240.0
const INK := Color("#211c37")
const ASPHALT := Color("#40455b")
const CREAM := Color("#fff1cf")
const CORAL := Color("#ef6f61")
const MINT := Color("#74d0ad")
const SKY := Color("#86d6e8")

func _ready() -> void:
	_build_environment()
	_build_world()
	_build_truck()
	_build_traffic()
	_build_camera()
	_build_ui()
	_build_audio()

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
	var world_env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d8edff")
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = environment
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_color = Color("#fff1ca")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func _build_world() -> void:
	var ground := _box(self, Vector3(180, 0.4, ROAD_LENGTH), Vector3(0, -0.35, -ROAD_LENGTH * 0.25), Color("#9bb07f"), "Grass")
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var road := _box(self, Vector3(ROAD_WIDTH, 0.18, ROAD_LENGTH), Vector3(0, -0.12, -ROAD_LENGTH * 0.25), ASPHALT, "Road")
	road.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for z in range(-120, 110, 12):
		_box(self, Vector3(0.22, 0.04, 5.5), Vector3(0, 0.01, z), CREAM, "LaneMarker")
		_box(self, Vector3(0.18, 0.35, 12.0), Vector3(-6.35, 0.1, z), INK, "RoadEdge")
		_box(self, Vector3(0.18, 0.35, 12.0), Vector3(6.35, 0.1, z), INK, "RoadEdge")
	for z in range(-115, 100, 18):
		_add_mountain_cluster(Vector3(-19, 0, z), 1.0 + float(abs(z % 4)) * 0.08)
		_add_mountain_cluster(Vector3(19, 0, z - 8), 0.8 + float(abs(z % 3)) * 0.09)
		_add_tree(Vector3(-9.0, 0, z + 4), 1.0)
		_add_tree(Vector3(9.0, 0, z - 3), 0.9)

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
	truck.position = Vector3(0, 0.65, 8)
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
	for x in [-2.1, 2.1]:
		var front_wheel := _cylinder(truck, 0.62, 0.42, Vector3(x, 0.62, -2.8), INK, "FrontWheel")
		front_wheel.rotation_degrees.z = 90.0
		var rear_wheel := _cylinder(truck, 0.62, 0.42, Vector3(x, 0.62, 2.5), INK, "RearWheel")
		rear_wheel.rotation_degrees.z = 90.0
	for x in [-2.1, 2.1]:
		var front_hub := _cylinder(truck, 0.25, 0.44, Vector3(x, 0.62, -2.8), Color("#ffce68"), "Hub")
		front_hub.rotation_degrees.z = 90.0
		var rear_hub := _cylinder(truck, 0.25, 0.44, Vector3(x, 0.62, 2.5), Color("#ffce68"), "Hub")
		rear_hub.rotation_degrees.z = 90.0
	_box(truck, Vector3(0.3, 0.3, 0.2), Vector3(-1.6, 1.8, -4.65), Color("#fff0a7"), "Lamp")
	_box(truck, Vector3(0.3, 0.3, 0.2), Vector3(1.6, 1.8, -4.65), Color("#fff0a7"), "Lamp")

func _build_traffic() -> void:
	for i in 3:
		var car := Node3D.new()
		car.name = "Traffic_%d" % i
		car.position = Vector3(traffic_lanes[i], 0.55, -24.0 - float(i) * 28.0)
		add_child(car)
		_box(car, Vector3(2.5, 1.15, 4.2), Vector3.ZERO, [MINT, Color("#f4b86b"), Color("#bb86fc")][i], "Body")
		_box(car, Vector3(1.8, 0.65, 1.2), Vector3(0, 0.7, -0.65), Color("#9fe3ff"), "Glass")
		_cylinder(car, 0.36, 2.65, Vector3(-1.0, 0, -1.2), INK, "Wheel")
		_cylinder(car, 0.36, 2.65, Vector3(1.0, 0, -1.2), INK, "Wheel")
		traffic.append(car)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 7.6, 15.0)
	camera.rotation_degrees = Vector3(-17, 180, 0)
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
	var hint := _label(layer, Vector2(32, 650), 15, Color("#d5dded"))
	hint.text = "触摸按钮驾驶  •  左右变道  •  避开车辆  •  到达目的地交付货物"
	_add_button(layer, "◀", Vector2(42, 520), "steer_left")
	_add_button(layer, "▶", Vector2(148, 520), "steer_right")
	_add_button(layer, "＋", Vector2(1110, 520), "accelerate")
	_add_button(layer, "—", Vector2(1210, 520), "brake")
	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.position = Vector2(1197, 18)
	pause_button.size = Vector2(52, 52)
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.add_theme_font_size_override("font_size", 23)
	pause_button.pressed.connect(_toggle_pause)
	layer.add_child(pause_button)
	_update_ui()

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

func _process(delta: float) -> void:
	if paused:
		return
	var throttle := Input.get_action_strength("accelerate")
	var braking := Input.get_action_strength("brake")
	var left := Input.get_action_strength("steer_left")
	var right := Input.get_action_strength("steer_right")
	var steer_input := right - left
	steer = lerp(steer, steer_input, delta * 7.0)
	var target_speed := throttle * 21.0 - braking * 12.0
	speed = lerp(speed, max(target_speed, 0.0), delta * 3.8)
	truck.position.x = clamp(truck.position.x + steer * delta * 6.4, -4.0, 4.0)
	truck.rotation.z = lerp(truck.rotation.z, -steer * 0.075, delta * 8.0)
	distance += speed * delta * 0.016
	fuel = max(0.0, fuel - speed * delta * 0.0014)
	time_left = max(0.0, time_left - delta)
	if braking > 0.2 and speed > 2.0 and not brake_player.playing:
		brake_player.play()
	for i in traffic.size():
		var car := traffic[i]
		car.position.z += speed * delta * 0.7
		if car.position.z > truck.position.z + 22.0:
			car.position.z = truck.position.z - 100.0 - float(i) * 20.0
			car.position.x = traffic_lanes[i]
		if abs(car.position.x - truck.position.x) < 2.5 and abs(car.position.z - truck.position.z) < 4.0 and speed > 11.0:
			damage = min(100.0, damage + 16.0)
			speed *= 0.45
			toast = "轻微碰撞！请注意车距"
			toast_time = 2.2
	if distance >= route_goal:
		_complete_delivery()
	toast_time = max(0.0, toast_time - delta)
	_update_camera(delta)
	_update_ui()

func _update_camera(delta: float) -> void:
	var target := truck.global_position + Vector3(0, 5.2, 11.5)
	camera.global_position = camera.global_position.lerp(target, delta * 3.5)
	camera.look_at(truck.global_position + Vector3(0, 1.2, -5.0), Vector3.UP)

func _complete_delivery() -> void:
	money += 640
	toast = "DELIVERY COMPLETE   +€640"
	toast_time = 4.0
	distance = 0.0
	cargo_index = (cargo_index + 1) % 3
	route_goal = 10.0 + float(cargo_index * 2)
	destination = ["INNSBRUCK", "MILAN", "LYON"][cargo_index]

func _toggle_pause() -> void:
	paused = not paused
	toast = "PAUSED" if paused else "BACK ON THE ROAD"
	toast_time = 2.0

func _update_ui() -> void:
	if not ui_speed:
		return
	var cargo := ["MOUNTAIN TEA", "STRAWBERRY JAM", "ALPINE PARTS"][cargo_index]
	ui_route.text = "CONTRACT  /  %s  →  %s" % [cargo, destination]
	ui_speed.text = "%02d km/h" % int(speed * 4.4)
	ui_stats.text = "ROUTE %.1f / %.1f km   •   FUEL %d%%   •   DAMAGE %d%%   •   € %d" % [distance, route_goal, int(fuel), int(damage), money]
	ui_toast.text = toast if toast_time > 0.0 else ""
