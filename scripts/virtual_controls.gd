extends Control

## Android driving controls: analog wheel + pressure-like pedals.
signal steering_changed(value: float)
signal throttle_changed(value: float)
signal brake_changed(value: float)

var wheel_center := Vector2.ZERO
var wheel_radius := 116.0
var wheel_touch_id := -1
var throttle_touch_id := -1
var brake_touch_id := -1
var steering_value := 0.0
var throttle_value := 0.0
var brake_value := 0.0
var wheel_return_speed := 5.5

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		wheel_center = Vector2(150, size.y - 150)
		queue_redraw()

func _process(delta: float) -> void:
	if wheel_touch_id == -1:
		steering_value = move_toward(steering_value, 0.0, delta * wheel_return_speed)
		steering_changed.emit(steering_value)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)
	elif event is InputEventMouseButton:
		# Desktop fallback for testing the Android layout with a mouse.
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_handle_mouse_drag(event.position)

func _handle_touch(event: InputEventScreenTouch) -> void:
	var p := event.position
	if event.pressed:
		if wheel_touch_id == -1 and p.distance_to(wheel_center) <= wheel_radius * 1.25:
			wheel_touch_id = event.index
			_update_wheel(p)
		elif throttle_touch_id == -1 and _throttle_rect().has_point(p):
			throttle_touch_id = event.index
			_set_throttle(1.0)
		elif brake_touch_id == -1 and _brake_rect().has_point(p):
			brake_touch_id = event.index
			_set_brake(1.0)
	else:
		if event.index == wheel_touch_id:
			wheel_touch_id = -1
		elif event.index == throttle_touch_id:
			throttle_touch_id = -1
			_set_throttle(0.0)
		elif event.index == brake_touch_id:
			brake_touch_id = -1
			_set_brake(0.0)

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == wheel_touch_id:
		_update_wheel(event.position)
	elif event.index == throttle_touch_id:
		_set_throttle(clamp(1.0 - (event.position.y - _throttle_rect().position.y) / _throttle_rect().size.y, 0.0, 1.0))
	elif event.index == brake_touch_id:
		_set_brake(clamp(1.0 - (event.position.y - _brake_rect().position.y) / _brake_rect().size.y, 0.0, 1.0))

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		if event.position.distance_to(wheel_center) <= wheel_radius * 1.25:
			wheel_touch_id = 999
			_update_wheel(event.position)
		elif _throttle_rect().has_point(event.position):
			throttle_touch_id = 999
			_set_throttle(1.0)
		elif _brake_rect().has_point(event.position):
			brake_touch_id = 999
			_set_brake(1.0)
	else:
		wheel_touch_id = -1
		throttle_touch_id = -1
		brake_touch_id = -1
		_set_throttle(0.0)
		_set_brake(0.0)

func _handle_mouse_drag(position: Vector2) -> void:
	if wheel_touch_id == 999:
		_update_wheel(position)

func _update_wheel(position: Vector2) -> void:
	var offset := position - wheel_center
	var normalized := clamp(offset.x / (wheel_radius * 0.78), -1.0, 1.0)
	# Deadzone removes tiny finger tremors; cubic response gives precision near center.
	if abs(normalized) < 0.08:
		normalized = 0.0
	steering_value = sign(normalized) * pow(abs(normalized), 0.82)
	steering_changed.emit(steering_value)
	queue_redraw()

func _set_throttle(value: float) -> void:
	throttle_value = value
	throttle_changed.emit(value)
	queue_redraw()

func _set_brake(value: float) -> void:
	brake_value = value
	brake_changed.emit(value)
	queue_redraw()

func _throttle_rect() -> Rect2:
	return Rect2(size.x - 176, size.y - 260, 78, 188)

func _brake_rect() -> Rect2:
	return Rect2(size.x - 82, size.y - 260, 78, 188)

func _draw() -> void:
	if wheel_center == Vector2.ZERO:
		wheel_center = Vector2(150, size.y - 150)
	# Steering wheel shadow, rim and center hub.
	draw_circle(wheel_center + Vector2(5, 8), wheel_radius + 8, Color(0.04, 0.04, 0.1, 0.35))
	draw_arc(wheel_center, wheel_radius, 0, TAU, 64, Color("#211c37"), 26, true)
	draw_arc(wheel_center, wheel_radius - 12, 0, TAU, 64, Color("#ffcf5c"), 10, true)
	var spoke_angle := steering_value * 0.75
	for angle in [spoke_angle, spoke_angle + PI * 0.5, spoke_angle + PI]:
		draw_line(wheel_center, wheel_center + Vector2(cos(angle), sin(angle)) * (wheel_radius - 18), Color("#211c37"), 10, true)
	draw_circle(wheel_center, 28, Color("#ef6f61"))
	draw_circle(wheel_center, 10, Color("#fff1cf"))
	_draw_pedal(_throttle_rect(), "油门", throttle_value, Color("#74d0ad"))
	_draw_pedal(_brake_rect(), "刹车", brake_value, Color("#ef6f61"))

func _draw_pedal(rect: Rect2, text: String, value: float, color: Color) -> void:
	draw_style_box(_panel(color, 0.22), rect)
	var fill_rect := Rect2(rect.position + Vector2(8, rect.size.y * (1.0 - value) + 8), Vector2(rect.size.x - 16, rect.size.y * value - 16))
	if fill_rect.size.y > 0:
		draw_style_box(_panel(color, 0.86), fill_rect)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 28), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 24, 17, Color("#fff1cf"))

func _panel(color: Color, alpha: float) -> StyleBoxFlat:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(color, alpha)
	panel.border_color = Color("#211c37")
	panel.set_border_width_all(4)
	panel.corner_radius_top_left = 16
	panel.corner_radius_top_right = 16
	panel.corner_radius_bottom_left = 16
	panel.corner_radius_bottom_right = 16
	return panel
