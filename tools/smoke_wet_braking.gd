extends SceneTree

func _run_case(weather: String) -> Dictionary:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await create_timer(0.5).timeout
	scene.current_weather = weather
	scene.weather_intensity = 0.92 if weather == "rain" else 0.0
	scene.weather_event_cooldown = 999.0
	scene.weather_event_remaining = 999.0
	Input.action_press("accelerate")
	await create_timer(4.0).timeout
	Input.action_release("accelerate")
	var brake_start_z: float = scene.truck.position.z
	var brake_start_speed: float = scene.speed
	var brake_start_x: float = scene.truck.position.x
	scene.touch_steer = 0.65
	Input.action_press("brake")
	await create_timer(0.8).timeout
	var mid_speed: float = scene.speed
	var mid_slip: float = scene.wet_lateral_slip
	await create_timer(1.6).timeout
	Input.action_release("brake")
	scene.touch_steer = 0.0
	await create_timer(0.1).timeout
	var stop_z: float = scene.truck.position.z
	var stop_speed: float = scene.speed
	var lateral_delta: float = abs(scene.truck.position.x - brake_start_x)
	var braking_distance: float = abs(stop_z - brake_start_z)
	var result := {"weather": weather, "actual_weather": scene.current_weather, "intensity": scene.weather_intensity, "start_speed": brake_start_speed, "mid_speed": mid_speed, "stop_speed": stop_speed, "distance": braking_distance, "lateral": lateral_delta, "slip": mid_slip}
	scene.queue_free()
	await process_frame
	return result

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var clear: Dictionary = await _run_case("clear")
	var rain: Dictionary = await _run_case("rain")
	print("WET_BRAKE clear=", clear, " rain=", rain)
	var speed_ok: bool = float(clear.start_speed) > 4.0 and float(rain.start_speed) > 4.0
	var wet_distance_ok: bool = float(rain.distance) > float(clear.distance) * 1.03
	var slip_ok: bool = float(rain.lateral) > 0.05 and abs(float(rain.slip)) > 0.01
	var stop_ok: bool = float(rain.stop_speed) >= 0.0 and float(clear.stop_speed) >= 0.0
	if not speed_ok or not wet_distance_ok or not slip_ok or not stop_ok:
		push_error("wet braking did not produce longer stopping distance and lateral slip")
		quit(1)
	else:
		print("WET_BRAKE PASSED: rain reduced grip, extended braking distance and produced lateral slip")
		quit(0)
