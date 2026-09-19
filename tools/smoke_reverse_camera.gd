extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await create_timer(0.8).timeout
	var mirror_setup_ok: bool = scene.interior_mirrors.size() >= 2 and scene.mirror_viewports.size() >= 2 and scene.mirror_cameras.size() >= 2
	var mirror_texture_ok := true
	for mirror in scene.interior_mirrors:
		var material := mirror.material_override as StandardMaterial3D
		if material == null or material.albedo_texture == null:
			mirror_texture_ok = false
	var start_z: float = scene.truck.position.z
	scene.drive_mode = "R"
	scene.cockpit_mode = true
	Input.action_press("accelerate")
	await create_timer(1.0).timeout
	Input.action_release("accelerate")
	await create_timer(0.15).timeout
	var reverse_speed: float = scene.speed
	var reverse_motion_ok: bool = reverse_speed < -0.2 and scene.truck.position.z > start_z
	var mirror_follow_ok: bool = true
	for camera in scene.mirror_cameras:
		if camera.global_position.z >= scene.truck.global_position.z:
			mirror_follow_ok = false
	print("REVERSE_CAMERA mirrors=", scene.interior_mirrors.size(), " viewports=", scene.mirror_viewports.size(), " cameras=", scene.mirror_cameras.size(), " textured=", mirror_texture_ok, " reverse_speed=", reverse_speed, " z_moved_back=", scene.truck.position.z > start_z, " cockpit=", scene.cockpit_mode)
	if not mirror_setup_ok or not mirror_texture_ok or not reverse_motion_ok or not mirror_follow_ok:
		push_error("reverse camera or mirror view setup failed")
		quit(1)
	else:
		print("REVERSE_CAMERA PASSED: R gear moved backward with functional mirror render targets")
		quit(0)
