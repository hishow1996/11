extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await create_timer(1.0).timeout
	var start_z: float = scene.truck.position.z
	var start_distance: float = scene.distance
	Input.action_press("accelerate")
	await create_timer(3.0).timeout
	Input.action_release("accelerate")
	await create_timer(0.2).timeout
	var end_z: float = scene.truck.position.z
	var end_distance: float = scene.distance
	print("SMOKE_DRIVE start_z=", start_z, " end_z=", end_z, " start_distance=", start_distance, " end_distance=", end_distance, " scene=", scene.current_scene)
	if end_z >= start_z or end_distance <= start_distance:
		push_error("vehicle did not advance during accelerate input")
		quit(1)
	else:
		print("SMOKE_DRIVE PASSED: vehicle advanced and scenery streaming path was exercised")
		quit(0)
