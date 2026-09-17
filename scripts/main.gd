extends Node2D

# Anime Haul: Alpine Run — a compact Android-friendly driving prototype.
# Visual language: thick ink outlines, warm cel shading, readable silhouettes.
# Audio language: engine, tire, and air-brake loops are intentionally realistic.

var speed := 0.0
var target_speed := 0.0
var distance := 0.0
var fuel := 78.0
var money := 1250
var damage := 0.0
var steer := 0.0
var road_scroll := 0.0
var traffic := [Vector2(0.0, -0.45), Vector2(-0.22, -0.78), Vector2(0.25, -1.15)]
var cargo_names := ["MOUNTAIN TEA", "STRAWBERRY JAM", "ALPINE PARTS"]
var cargo_index := 0
var destination := "LUCERNE"
var delivery_goal := 12.0
var delivered := false
var time_left := 184.0
var is_paused := false
var toast := "READY TO HAUL"
var toast_time := 2.4
var engine_player: AudioStreamPlayer
var brake_player: AudioStreamPlayer
var ui_speed: Label
var ui_distance: Label
var ui_fuel: Label
var ui_money: Label
var ui_mission: Label
var ui_toast: Label

const SKY := Color("#86d6e8")
const MOUNTAIN_DARK := Color("#38405b")
const MOUNTAIN_LIGHT := Color("#7486a4")
const ASPHALT := Color("#3a3850")
const LANE := Color("#f9dda0")
const INK := Color("#211c37")
const CREAM := Color("#fff1cf")
const CORAL := Color("#ef6f61")
const MINT := Color("#74d0ad")

func _ready() -> void:
	_build_ui()
	_build_audio()
	queue_redraw()

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	var top := ColorRect.new()
	top.color = Color(INK, 0.94)
	top.position = Vector2(0, 0)
	top.size = Vector2(1280, 92)
	layer.add_child(top)
	ui_mission = Label.new()
	ui_mission.position = Vector2(36, 16)
	ui_mission.add_theme_font_size_override("font_size", 24)
	ui_mission.add_theme_color_override("font_color", CREAM)
	layer.add_child(ui_mission)
	ui_distance = Label.new()
	ui_distance.position = Vector2(36, 51)
	ui_distance.add_theme_font_size_override("font_size", 16)
	ui_distance.add_theme_color_override("font_color", Color("#b5c5de"))
	layer.add_child(ui_distance)
	ui_speed = _hud_label(layer, Vector2(930, 16), 34, CREAM)
	ui_fuel = _hud_label(layer, Vector2(1090, 18), 17, MINT)
	ui_money = _hud_label(layer, Vector2(1090, 52), 17, Color("#ffd166"))
	ui_toast = _hud_label(layer, Vector2(470, 112), 20, CREAM)
	ui_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_toast.size = Vector2(340, 40)
	
	var hint := _hud_label(layer, Vector2(38, 640), 15, Color("#d5dded"))
	hint.text = "WASD / 触摸按钮驾驶   •   避开车辆   •   送货到达终点"
	var pause := Button.new()
	pause.text = "Ⅱ"
	pause.process_mode = Node.PROCESS_MODE_ALWAYS
	pause.position = Vector2(1195, 18)
	pause.size = Vector2(54, 54)
	pause.add_theme_font_size_override("font_size", 24)
	pause.pressed.connect(_toggle_pause)
	layer.add_child(pause)
	_make_drive_button(layer, "◀", Vector2(46, 525), "steer_left")
	_make_drive_button(layer, "▶", Vector2(152, 525), "steer_right")
	_make_drive_button(layer, "＋", Vector2(1110, 525), "accelerate")
	_make_drive_button(layer, "—", Vector2(1210, 525), "brake")
	_update_hud()

func _hud_label(layer: CanvasLayer, pos: Vector2, size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	layer.add_child(label)
	return label

func _make_drive_button(layer: CanvasLayer, text: String, pos: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(88, 76)
	button.modulate = Color(1, 1, 1, 0.92)
	button.add_theme_font_size_override("font_size", 30)
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))
	layer.add_child(button)

func _build_audio() -> void:
	engine_player = AudioStreamPlayer.new()
	engine_player.stream = load("res://audio/engine_loop.wav")
	engine_player.volume_db = -9.0
	add_child(engine_player)
	engine_player.play()
	brake_player = AudioStreamPlayer.new()
	brake_player.stream = load("res://audio/air_brake.wav")
	brake_player.volume_db = -4.0
	add_child(brake_player)

func _process(delta: float) -> void:
	if is_paused:
		return
	var throttle := Input.get_action_strength("accelerate")
	var braking := Input.get_action_strength("brake")
	var left := Input.get_action_strength("steer_left")
	var right := Input.get_action_strength("steer_right")
	target_speed = lerp(target_speed, throttle * 92.0 - braking * 52.0, delta * 5.0)
	speed = lerp(speed, max(target_speed, 0.0), delta * 3.6)
	steer = lerp(steer, right - left, delta * 7.0)
	road_scroll = fmod(road_scroll + speed * delta * 0.012, 1.0)
	distance += speed * delta * 0.00033
	fuel = max(0.0, fuel - speed * delta * 0.000055)
	time_left = max(0.0, time_left - delta)
	if braking > 0.2 and speed > 12.0 and not brake_player.playing:
		brake_player.play()
	if abs(steer) > 0.1:
		for i in traffic.size():
			traffic[i].x += steer * delta * 0.13
	_check_collisions()
	if distance >= delivery_goal and not delivered:
		_deliver_cargo()
	toast_time = max(0.0, toast_time - delta)
	_update_hud()
	queue_redraw()

func _check_collisions() -> void:
	for i in traffic.size():
		traffic[i].y += speed * 0.0008
		if traffic[i].y > 1.25:
			traffic[i].y = -1.05 - float(i) * 0.19
			traffic[i].x = [-0.28, 0.0, 0.26][i]
		if abs(traffic[i].x - steer * 0.42) < 0.12 and traffic[i].y > 0.52 and traffic[i].y < 0.86 and speed > 45.0:
			damage = min(100.0, damage + 18.0)
			speed *= 0.54
			toast = "轻微碰撞！小心驾驶"
			toast_time = 2.2

func _deliver_cargo() -> void:
	delivered = true
	money += 640
	toast = "DELIVERY COMPLETE  +€640"
	toast_time = 5.0
	cargo_index = (cargo_index + 1) % cargo_names.size()
	# Keep the loop playable: a new route begins after a successful delivery.
	await get_tree().create_timer(4.0).timeout
	distance = 0.0
	delivery_goal = 10.0 + float((cargo_index + 1) * 2)
	destination = ["INNSBRUCK", "MILAN", "LYON"][cargo_index]
	delivered = false
	toast = "NEW CONTRACT: " + cargo_names[cargo_index]
	toast_time = 4.0

func _toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	toast = "PAUSED" if is_paused else "BACK ON THE ROAD"
	toast_time = 2.0

func _update_hud() -> void:
	if not ui_speed:
		return
	ui_mission.text = "CONTRACT  /  " + cargo_names[cargo_index] + "  →  " + destination
	ui_distance.text = "ROUTE  " + str(snapped(distance, 0.1)) + " / " + str(delivery_goal) + " km    •    DAMAGE " + str(int(damage)) + "%"
	ui_speed.text = str(int(speed)) + " km/h"
	ui_fuel.text = "FUEL  " + str(int(fuel)) + "%"
	ui_money.text = "€ " + str(money)
	ui_toast.text = toast if toast_time > 0.0 else ""

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), SKY)
	_draw_clouds()
	_draw_mountains(size)
	_draw_road(size)
	_draw_traffic(size)
	_draw_player_truck(size)
	_draw_route_marker(size)

func _draw_clouds() -> void:
	for c in [Vector2(130, 155), Vector2(940, 175), Vector2(570, 210)]:
		draw_circle(c, 24, Color(1, 1, 1, 0.48))
		draw_circle(c + Vector2(28, 7), 18, Color(1, 1, 1, 0.48))
		draw_circle(c - Vector2(24, 1), 16, Color(1, 1, 1, 0.48))

func _draw_mountains(size: Vector2) -> void:
	var back := PackedVector2Array([Vector2(0, 315), Vector2(130, 205), Vector2(240, 292), Vector2(388, 172), Vector2(530, 288), Vector2(704, 186), Vector2(830, 287), Vector2(1010, 160), Vector2(1280, 290), Vector2(1280, 440), Vector2(0, 440)])
	draw_colored_polygon(back, MOUNTAIN_LIGHT)
	var front := PackedVector2Array([Vector2(0, 370), Vector2(145, 270), Vector2(260, 344), Vector2(414, 238), Vector2(560, 355), Vector2(745, 242), Vector2(900, 350), Vector2(1070, 235), Vector2(1280, 350), Vector2(1280, 470), Vector2(0, 470)])
	draw_colored_polygon(front, MOUNTAIN_DARK)
	draw_line(Vector2(0, 370), Vector2(1280, 350), Color(INK, 0.35), 5)

func _draw_road(size: Vector2) -> void:
	draw_rect(Rect2(0, 430, size.x, 290), Color("#9bb07f"))
	var road := PackedVector2Array([Vector2(340, 720), Vector2(485, 350), Vector2(795, 350), Vector2(940, 720)])
	draw_colored_polygon(road, ASPHALT)
	draw_polyline(PackedVector2Array([Vector2(340,720), Vector2(485,350)]), INK, 9)
	draw_polyline(PackedVector2Array([Vector2(940,720), Vector2(795,350)]), INK, 9)
	for y in range(-40, 780, 90):
		var yy := float(y) + road_scroll * 90.0
		var half := lerp(7.0, 31.0, clamp((yy - 350.0) / 370.0, 0.0, 1.0))
		draw_rect(Rect2(Vector2(640 - half / 2.0, yy), Vector2(half, half * 1.7)), LANE)
	for x in [388.0, 892.0]:
		draw_circle(Vector2(x, 478), 9, Color("#ffcf67"))

func _draw_traffic(size: Vector2) -> void:
	for i in traffic.size():
		var p := _road_point(traffic[i])
		var s := lerp(0.45, 1.12, clamp((traffic[i].y + 1.0) / 2.0, 0.0, 1.0))
		_draw_mini_car(p, s, [Color("#74d0ad"), Color("#f4b86b"), Color("#bb86fc")][i])

func _road_point(v: Vector2) -> Vector2:
	var t := clamp((v.y + 1.0) / 2.0, 0.0, 1.0)
	return Vector2(640 + v.x * lerp(120.0, 370.0, t), lerp(365.0, 690.0, t))

func _draw_mini_car(p: Vector2, s: float, color: Color) -> void:
	var body := Rect2(p - Vector2(23, 34) * s, Vector2(46, 68) * s)
	draw_rect(body, INK)
	draw_rect(Rect2(body.position + Vector2(5, 7) * s, Vector2(36, 49) * s), color)
	draw_rect(Rect2(body.position + Vector2(9, 11) * s, Vector2(28, 18) * s), Color("#8ed7e8"))
	draw_circle(body.position + Vector2(9, 59) * s, 5 * s, Color("#f7d78b"))
	draw_circle(body.position + Vector2(37, 59) * s, 5 * s, Color("#f7d78b"))

func _draw_player_truck(size: Vector2) -> void:
	var center := Vector2(640 + steer * 190.0, 579)
	var bob := sin(Time.get_ticks_msec() * 0.008) * min(speed * 0.018, 2.4)
	center.y += bob
	var shadow := PackedVector2Array([center + Vector2(-128, 82), center + Vector2(128, 82), center + Vector2(150, 99), center + Vector2(-150, 99)])
	draw_colored_polygon(shadow, Color(INK, 0.35))
	var trailer := Rect2(center + Vector2(-116, -42), Vector2(156, 106))
	draw_rect(trailer, INK)
	draw_rect(Rect2(trailer.position + Vector2(8, 8), trailer.size - Vector2(16, 16)), CREAM)
	draw_rect(Rect2(trailer.position + Vector2(16, 25), Vector2(140, 12)), CORAL)
	draw_rect(Rect2(trailer.position + Vector2(16, 55), Vector2(140, 8)), MINT)
	var cab := PackedVector2Array([center + Vector2(30, -60), center + Vector2(112, -60), center + Vector2(134, -24), center + Vector2(134, 65), center + Vector2(30, 65)])
	draw_colored_polygon(cab, Color("#ff9c65"))
	draw_polyline(PackedVector2Array([cab[0], cab[1], cab[2], cab[3], cab[4], cab[0]]), INK, 8)
	draw_rect(Rect2(center + Vector2(43, -45), Vector2(57, 32)), Color("#9fe3ff"))
	draw_line(center + Vector2(72, -45), center + Vector2(72, -13), INK, 5)
	for wx in [-72.0, 100.0]:
		draw_circle(center + Vector2(wx, 72), 22, INK)
		draw_circle(center + Vector2(wx, 72), 9, Color("#ffce68"))
	draw_circle(center + Vector2(133, 35), 7, Color("#fff0a7"))

func _draw_route_marker(size: Vector2) -> void:
	var x := 640 + steer * 190.0
	draw_line(Vector2(x, 405), Vector2(x, 358), Color("#f7d78b"), 4)
	draw_circle(Vector2(x, 352), 12, CORAL)
