extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await create_timer(0.8).timeout
	scene.game_hour = 23.0
	scene.current_weather = "clear"
	scene.weather_intensity = 0.0
	scene.weather_event_type = ""
	scene.high_beam = false
	scene._update_day_night()
	var night_energy: float = scene.headlight_nodes[0].light_energy if scene.headlight_nodes.size() > 0 else 0.0
	var night_range: float = scene.headlight_nodes[0].omni_range if scene.headlight_nodes.size() > 0 else 0.0
	scene.high_beam = true
	scene._update_day_night()
	var high_beam_energy: float = scene.headlight_nodes[0].light_energy if scene.headlight_nodes.size() > 0 else 0.0
	var high_beam_range: float = scene.headlight_nodes[0].omni_range if scene.headlight_nodes.size() > 0 else 0.0
	var clear_fog: float = scene.environment.fog_density
	scene.current_weather = "rain"
	scene.weather_intensity = 0.92
	scene.weather_event_type = "暴雨"
	scene._update_weather_visuals()
	var rain_on: bool = scene.rain_particles.emitting and scene.rain_particles.amount_ratio > 0.8
	var wet_road: bool = (scene.road_surface.material_override as StandardMaterial3D).albedo_texture == scene.ROAD_WET_TEXTURE
	var rain_glass: float = (scene.windshield_glass.material_override as StandardMaterial3D).albedo_color.a
	scene.weather_event_type = "大雾"
	scene.weather_intensity = 0.48
	scene._update_weather_visuals()
	var fog_density: float = scene.environment.fog_density
	var fog_glass: float = (scene.windshield_glass.material_override as StandardMaterial3D).albedo_color.a
	print("NIGHT_WEATHER headlight=", night_energy, " range=", night_range, " high_beam=", high_beam_energy, " high_range=", high_beam_range, " rain=", rain_on, " wet_road=", wet_road, " fog=", fog_density, " clear_fog=", clear_fog, " glass_rain=", rain_glass, " glass_fog=", fog_glass)
	var night_ok: bool = night_energy > 1.0 and night_range == 18.0
	var high_ok: bool = high_beam_energy > night_energy and high_beam_range == 30.0
	var rain_ok: bool = rain_on and wet_road and rain_glass > 0.16
	var fog_ok: bool = fog_density > clear_fog and fog_glass >= 0.30
	if not night_ok or not high_ok or not rain_ok or not fog_ok:
		push_error("night or severe weather lighting/rendering behavior failed")
		quit(1)
	else:
		print("NIGHT_WEATHER PASSED: night lights, high beam, rain and fog rendering responded correctly")
		quit(0)
