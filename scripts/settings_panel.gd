extends Panel

signal quality_selected(mode: int)
signal sensitivity_changed(value: float)
signal volume_changed(value: float)
signal closed

var quality_mode := 1
var sensitivity := 1.0
var volume := 0.8
var status_label: Label

func _ready() -> void:
	var title := Label.new()
	title.text = "设置 / SETTINGS"
	title.position = Vector2(18, 14)
	title.add_theme_font_size_override("font_size", 20)
	add_child(title)
	status_label = Label.new()
	status_label.position = Vector2(18, 50)
	status_label.size = Vector2(310, 60)
	add_child(status_label)
	var low := _button("低画质", Vector2(18, 116), func(): _select_quality(0))
	var medium := _button("中画质", Vector2(120, 116), func(): _select_quality(1))
	var high := _button("高画质", Vector2(222, 116), func(): _select_quality(2))
	var less := _button("方向盘 −", Vector2(18, 170), func(): _change_sensitivity(-0.1))
	var more := _button("方向盘 +", Vector2(120, 170), func(): _change_sensitivity(0.1))
	var quieter := _button("音量 −", Vector2(222, 170), func(): _change_volume(-0.1))
	var louder := _button("音量 +", Vector2(18, 224), func(): _change_volume(0.1))
	var close := _button("关闭", Vector2(222, 224), func(): closed.emit())
	_update_status()

func _button(text: String, pos: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(90, 40)
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(callback)
	add_child(button)
	return button

func _select_quality(mode: int) -> void:
	quality_mode = mode
	quality_selected.emit(mode)
	_update_status()

func _change_sensitivity(amount: float) -> void:
	sensitivity = clamp(sensitivity + amount, 0.6, 1.5)
	sensitivity_changed.emit(sensitivity)
	_update_status()

func _change_volume(amount: float) -> void:
	volume = clamp(volume + amount, 0.0, 1.0)
	volume_changed.emit(volume)
	_update_status()

func _update_status() -> void:
	var quality_name := ["低", "中", "高"][quality_mode]
	status_label.text = "画质：%s\n方向盘灵敏度：%.1f   音量：%d%%" % [quality_name, sensitivity, int(volume * 100.0)]
