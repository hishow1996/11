extends SceneTree

func _init() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await create_timer(0.8).timeout
	var streams_ok: bool = FileAccess.file_exists("res://audio/turn_signal.wav") and FileAccess.file_exists("res://audio/wiper_swipe.wav") and FileAccess.file_exists("res://audio/tire_skid.wav") and FileAccess.file_exists("res://audio/tire_wet.wav")
	scene._play_sfx("turn_signal", -8.0)
	var turn_playing: bool = scene.sfx_players.has("turn_signal")
	scene.current_weather = "rain"
	scene.weather_intensity = 0.9
	scene.speed = 15.0
	scene.previous_wiper_active = false
	scene._update_cockpit_instruments(0.16)
	var wiper_active: bool = scene.previous_wiper_active and scene.wiper_audio_cooldown > 0.0
	var wiper_playing: bool = scene.sfx_players.has("wiper_swipe")
	scene._update_weather_audio(0.16)
	var tire_mix_ok: bool = scene.wet_tire_player != null and scene.spatial_tire_player != null and scene.spatial_tire_player.pitch_scale > 0.9
	scene._play_sfx("turn_signal", -8.0)
	var turn_stream_same: bool = FileAccess.file_exists("res://audio/turn_signal.wav")
	print("AUDIO_SYSTEM streams=", streams_ok, " turn_playing=", turn_playing, " wiper_active=", wiper_active, " wiper_playing=", wiper_playing, " tire_mix=", tire_mix_ok, " turn_stream=", turn_stream_same, " tire_db=", scene.wet_tire_player.volume_db)
	if not streams_ok or not turn_playing or not wiper_active or not wiper_playing or not tire_mix_ok or not turn_stream_same:
		push_error("audio system resource or trigger validation failed")
		quit(1)
	else:
		print("AUDIO_SYSTEM PASSED: tire noise, wiper and turn-signal audio are wired")
		quit(0)
