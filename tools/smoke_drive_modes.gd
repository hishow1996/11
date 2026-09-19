extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await create_timer(0.6).timeout
	var controls: Control = scene.virtual_controls
	var gear_pos: Vector2 = controls._gear_rect().get_center()
	var first := InputEventScreenTouch.new()
	first.index = 1
	first.position = gear_pos
	first.pressed = true
	controls._handle_touch(first)
	var neutral_ok: bool = scene.drive_mode == "N"
	controls._handle_touch(first)
	var reverse_ok: bool = scene.drive_mode == "R"
	Input.action_press("accelerate")
	await create_timer(0.9).timeout
	Input.action_release("accelerate")
	var reverse_speed: float = scene.speed
	var reverse_motion_ok: bool = reverse_speed < -0.2
	controls._handle_touch(first)
	var drive_ok: bool = scene.drive_mode == "D"
	Input.action_press("accelerate")
	await create_timer(0.9).timeout
	Input.action_release("accelerate")
	var drive_speed: float = scene.speed
	var drive_motion_ok: bool = drive_speed > 0.2
	print("GEAR_TEST neutral=", neutral_ok, " reverse=", reverse_ok, " reverse_speed=", reverse_speed, " drive=", drive_ok, " drive_speed=", drive_speed)
	if not neutral_ok or not reverse_ok or not reverse_motion_ok or not drive_ok or not drive_motion_ok:
		push_error("D/N/R gear mode behavior failed")
		quit(1)
	else:
		print("GEAR_TEST PASSED: D/N/R switching and direction behavior are functional")
		quit(0)
