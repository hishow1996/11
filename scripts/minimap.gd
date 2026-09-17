extends Control

var route_progress := 0.0
var vehicle_offset := 0.0
var scene_name := "开阔平原"
var destination := "LUCERNE"
var distance_text := "12.0 km"
var scene_color := Color("#74d0ad")
var branch_hint := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func update_state(offset: float, progress: float, goal: float, current_scene: String, target: String, branch: String = "") -> void:
	vehicle_offset = clamp(offset / 4.0, -1.0, 1.0)
	route_progress = clamp(progress / max(goal, 0.1), 0.0, 1.0)
	scene_name = current_scene
	destination = target
	branch_hint = branch
	distance_text = "%.1f km" % max(goal - progress, 0.0)
	scene_color = {
		"动漫城市": Color("#ef6f61"),
		"乡村田园": Color("#ffd166"),
		"深山老林": Color("#74d0ad"),
		"山区雪岭": Color("#9fe3ff"),
		"开阔平原": Color("#f4b86b")
	}.get(current_scene, Color("#74d0ad"))
	queue_redraw()

func _draw() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("#211c37", 0.90)
	panel.corner_radius_top_left = 18
	panel.corner_radius_top_right = 18
	panel.corner_radius_bottom_left = 18
	panel.corner_radius_bottom_right = 18
	panel.draw(get_canvas_item(), Rect2(Vector2.ZERO, size))
	# Route line with gentle bends.
	var points := PackedVector2Array([
		Vector2(28, size.y - 22), Vector2(42, size.y - 48), Vector2(26, size.y - 74),
		Vector2(54, size.y - 101), Vector2(40, size.y - 130), Vector2(size.x - 22, 24)
	])
	draw_polyline(points, Color("#6ba8ff"), 6.0, true)
	if branch_hint != "":
		draw_polyline(PackedVector2Array([Vector2(112, size.y - 76), Vector2(178, size.y - 92), Vector2(232, size.y - 58)]), Color("#ffd166"), 3.0, true)
	for i in points.size():
		if i % 2 == 0:
			draw_circle(points[i], 4.0, scene_color)
	var car_position := Vector2(lerp(40.0, size.x - 25.0, route_progress), size.y - 28.0 - vehicle_offset * 12.0)
	draw_circle(car_position, 9.0, Color("#fff1cf"))
	draw_circle(car_position, 5.0, Color("#ef6f61"))
	draw_string(ThemeDB.fallback_font, Vector2(14, 20), scene_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#fff1cf"))
	draw_string(ThemeDB.fallback_font, Vector2(14, 42), "→ " + destination + "  " + distance_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#c5d4ea"))
	if branch_hint != "":
		draw_string(ThemeDB.fallback_font, Vector2(14, 62), "分支：" + branch_hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#ffd166"))
	draw_rect(Rect2(Vector2(14, size.y - 12), Vector2(size.x - 28, 4)), Color("#4d5872"))
	draw_rect(Rect2(Vector2(14, size.y - 12), Vector2((size.x - 28) * route_progress, 4)), scene_color)
