extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await create_timer(0.8).timeout
	var initial_speed: float = scene.speed
	var initial_rotation: Vector3 = scene.truck.rotation
	Input.action_press("accelerate")
	await create_timer(2.4).timeout
	var peak_speed: float = scene.speed
	var acceleration_rotation: Vector3 = scene.truck.rotation
	Input.action_release("accelerate")
	await create_timer(0.15).timeout
	var brake_start_speed: float = scene.speed
	Input.action_press("brake")
	await create_timer(0.75).timeout
	var emergency_brake_speed: float = scene.speed
	var braking_rotation: Vector3 = scene.truck.rotation
	var braking_z: float = scene.truck.position.z
	Input.action_release("brake")
	await create_timer(0.25).timeout
	var final_speed: float = scene.speed
	print("PHYSICS initial_speed=", initial_speed, " peak_speed=", peak_speed, " brake_start=", brake_start_speed, " emergency_speed=", emergency_brake_speed, " final_speed=", final_speed)
	print("PHYSICS rotation_initial=", initial_rotation, " acceleration=", acceleration_rotation, " braking=", braking_rotation, " z=", braking_z)
	var acceleration_ok: bool = peak_speed > initial_speed + 2.0
	var braking_ok: bool = emergency_brake_speed < brake_start_speed - 2.0 and emergency_brake_speed >= 0.0
	var pose_feedback_ok: bool = abs(acceleration_rotation.x) > 0.0001 or abs(braking_rotation.x) > 0.0001
	var stable_stop_ok: bool = final_speed >= 0.0 and final_speed < emergency_brake_speed + 2.0
	if not acceleration_ok or not braking_ok or not pose_feedback_ok or not stable_stop_ok:
		push_error("emergency physics feedback did not meet expected acceleration, braking or pose thresholds")
		quit(1)
	else:
		print("PHYSICS PASSED: acceleration, emergency braking and body pose feedback behaved normally")
		quit(0)
