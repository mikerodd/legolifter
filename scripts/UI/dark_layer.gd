extends ColorRect

const ALPHA_LIGHT :float = 0
const ALPHA_DARK : float = 0.5
const ALPHA_TOTAL_DARK : float = 1


func _ready() -> void:
	Messenger.ui_darken_display.connect(_on_ui_darken_display)
	Messenger.ui_englight_display.connect(_on_lighten_display)
	Messenger.ui_total_dark_display.connect(_on_total_dark_display)


func _on_ui_darken_display() -> void:
	create_tween().tween_property(self,"color",Color(0,0,0,ALPHA_DARK),0.5)


func _on_lighten_display() -> void:
	create_tween().tween_property(self,"color",Color(0,0,0,ALPHA_LIGHT),0.5)
	await get_tree().create_timer(0.5).timeout


func _on_total_dark_display() -> void:
	create_tween().tween_property(self,"color",Color(0,0,0,ALPHA_TOTAL_DARK),0.5)
