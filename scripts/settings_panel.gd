extends Panel

signal quality_selected(mode: int)
signal sensitivity_changed(value: float)
signal volume_changed(value: float)
signal music_volume_changed(value: float)
signal sfx_volume_changed(value: float)
signal control_layout_changed(scale_value: float, opacity_value: float)
signal closed

var quality_mode := 1
var sensitivity := 1.0
var volume := 0.8
var music_volume := 0.8
var sfx_volume := 0.8
var control_scale := 1.0
var control_opacity := 0.84
var status_label: Label

func _ready() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#211c37", 0.96)
	panel_style.border_color = Color("#52617e", 0.9)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 18
	panel_style.corner_radius_top_right = 18
	panel_style.corner_radius_bottom_left = 18
	panel_style.corner_radius_bottom_right = 18
	add_theme_stylebox_override("panel", panel_style)
	var title := Label.new()
	title.text = "设置 / SETTINGS"
	title.position = Vector2(18, 14)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("#fff1cf"))
	add_child(title)
	status_label = Label.new()
	status_label.position = Vector2(18, 50)
	status_label.size = Vector2(330, 92)
	status_label.add_theme_color_override("font_color", Color("#c0cde4"))
	add_child(status_label)
	var low := _button("低画质", Vector2(18, 154), func(): _select_quality(0))
	var medium := _button("中画质", Vector2(120, 154), func(): _select_quality(1))
	var high := _button("高画质", Vector2(222, 154), func(): _select_quality(2))
	var less := _button("方向盘 −", Vector2(18, 208), func(): _change_sensitivity(-0.1))
	var more := _button("方向盘 +", Vector2(120, 208), func(): _change_sensitivity(0.1))
	var quieter := _button("总音量 −", Vector2(222, 208), func(): _change_volume(-0.1))
	var louder := _button("总音量 +", Vector2(18, 262), func(): _change_volume(0.1))
	var music_quieter := _button("音乐 −", Vector2(120, 262), func(): _change_music_volume(-0.1))
	var music_louder := _button("音乐 +", Vector2(18, 316), func(): _change_music_volume(0.1))
	var sfx_quieter := _button("音效 −", Vector2(120, 316), func(): _change_sfx_volume(-0.1))
	var sfx_louder := _button("音效 +", Vector2(222, 316), func(): _change_sfx_volume(0.1))
	var control_smaller := _button("按钮 −", Vector2(18, 370), func(): _change_control_scale(-0.1))
	var control_larger := _button("按钮 +", Vector2(120, 370), func(): _change_control_scale(0.1))
	var opacity_less := _button("透明 −", Vector2(18, 424), func(): _change_control_opacity(-0.1))
	var opacity_more := _button("透明 +", Vector2(120, 424), func(): _change_control_opacity(0.1))
	var close := _button("关闭", Vector2(222, 424), func(): closed.emit())
	_update_status()

func _button(text: String, pos: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = Vector2(90, 40)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color("#fff1cf"))
	button.add_theme_color_override("font_hover_color", Color("#211c37"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#3d4764", 0.96)
	normal.border_color = Color("#66789d", 0.9)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(12)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color("#ffd166", 0.96)
	button.add_theme_stylebox_override("hover", hover)
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

func _change_music_volume(amount: float) -> void:
	music_volume = clampf(music_volume + amount, 0.0, 1.0)
	music_volume_changed.emit(music_volume)
	_update_status()

func _change_sfx_volume(amount: float) -> void:
	sfx_volume = clampf(sfx_volume + amount, 0.0, 1.0)
	sfx_volume_changed.emit(sfx_volume)
	_update_status()

func _change_control_scale(amount: float) -> void:
	control_scale = clampf(control_scale + amount, 0.75, 1.35)
	control_layout_changed.emit(control_scale, control_opacity)
	_update_status()

func _change_control_opacity(amount: float) -> void:
	control_opacity = clampf(control_opacity + amount, 0.35, 1.0)
	control_layout_changed.emit(control_scale, control_opacity)
	_update_status()

func _update_status() -> void:
	var quality_name: String = ["低", "中", "高"][quality_mode]
	status_label.text = "画质：%s\n方向盘：%.1f  总音量：%d%%\n音乐：%d%%  音效：%d%%\n按钮：%.1fx 透明：%d%%" % [quality_name, sensitivity, int(volume * 100.0), int(music_volume * 100.0), int(sfx_volume * 100.0), control_scale, int(control_opacity * 100.0)]
