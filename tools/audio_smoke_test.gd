extends SceneTree

const FILES := [
	"res://audio/air_brake.wav",
	"res://audio/collision_metal.wav",
	"res://audio/delivery_complete.wav",
	"res://audio/engine_loop.wav",
	"res://audio/gear_shift.wav",
	"res://audio/guardrail_scrape.wav",
	"res://audio/rain_ambient.wav",
	"res://audio/refuel_start.wav",
	"res://audio/repair_start.wav",
	"res://audio/reverse_beeper.wav",
	"res://audio/thunder_rumble.wav",
	"res://audio/tire_skid.wav",
	"res://audio/tire_snow.wav",
	"res://audio/tire_wet.wav",
	"res://audio/turn_signal.wav",
	"res://audio/ui_click.wav",
	"res://audio/upgrade_purchase.wav",
	"res://audio/warning_alert.wav",
	"res://audio/water_splash.wav",
	"res://audio/wind_ambient.wav",
	"res://audio/wiper_swipe.wav",
]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var failed := 0
	for path in FILES:
		var stream = load(path)
		if stream == null or not stream is AudioStream:
			push_error("LOAD FAILED: " + path)
			failed += 1
			continue
		var player := AudioStreamPlayer.new()
		player.stream = stream
		get_root().add_child(player)
		player.play()
		if not player.playing:
			push_error("PLAY FAILED: " + path)
			failed += 1
		else:
			print("PLAY OK: " + path)
		player.stop()
		player.queue_free()
	if failed > 0:
		push_error("Audio smoke test failed: %d" % failed)
		quit(1)
	else:
		print("AUDIO SMOKE TEST PASSED: %d files" % FILES.size())
		quit(0)
