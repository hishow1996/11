extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var controls := Control.new()
	controls.set_script(load("res://scripts/virtual_controls.gd"))
	controls.size = Vector2(1280, 720)
	root.add_child(controls)
	await process_frame
	await process_frame
	controls._update_layout_metrics()
	var wheel: Vector2 = controls.wheel_center
	var throttle: Vector2 = controls._throttle_rect().get_center()
	var left_signal: Vector2 = controls._left_signal_rect().get_center()
	var throttle_down := InputEventScreenTouch.new()
	throttle_down.index = 1
	throttle_down.position = throttle
	throttle_down.pressed = true
	controls._handle_touch(throttle_down)
	var wheel_down := InputEventScreenTouch.new()
	wheel_down.index = 2
	wheel_down.position = wheel + Vector2(80.0, 0.0)
	wheel_down.pressed = true
	controls._handle_touch(wheel_down)
	var signal_down := InputEventScreenTouch.new()
	signal_down.index = 3
	signal_down.position = left_signal
	signal_down.pressed = true
	controls._handle_touch(signal_down)
	var wheel_drag := InputEventScreenDrag.new()
	wheel_drag.index = 2
	wheel_drag.position = wheel + Vector2(128.0, 0.0)
	controls._handle_drag(wheel_drag)
	await create_timer(0.15).timeout
	var active_ok: bool = controls.throttle_value > 0.95 and abs(controls.steering_value) > 0.1 and controls.left_indicator_active and controls.throttle_touch_id == 1 and controls.wheel_touch_id == 2 and controls.left_indicator_active
	print("MULTITOUCH active throttle=", controls.throttle_value, " steering=", controls.steering_value, " left_signal=", controls.left_indicator_active, " ids=", controls.throttle_touch_id, "/", controls.wheel_touch_id)
	var signal_up := InputEventScreenTouch.new()
	signal_up.index = 3
	signal_up.position = left_signal
	signal_up.pressed = false
	controls._handle_touch(signal_up)
	var wheel_up := InputEventScreenTouch.new()
	wheel_up.index = 2
	wheel_up.position = wheel_drag.position
	wheel_up.pressed = false
	controls._handle_touch(wheel_up)
	var throttle_up := InputEventScreenTouch.new()
	throttle_up.index = 1
	throttle_up.position = throttle
	throttle_up.pressed = false
	controls._handle_touch(throttle_up)
	await create_timer(0.15).timeout
	var release_ok: bool = controls.throttle_value == 0.0 and controls.brake_value == 0.0 and controls.wheel_touch_id == -1 and controls.throttle_touch_id == -1 and abs(controls.steering_value) > 0.0
	print("MULTITOUCH release throttle=", controls.throttle_value, " steering=", controls.steering_value, " wheel_id=", controls.wheel_touch_id)
	if not active_ok or not release_ok:
		push_error("multi-touch controls lost an input channel or failed to release")
		quit(1)
	else:
		print("MULTITOUCH PASSED: throttle, steering and indicator remained independent")
		quit(0)
