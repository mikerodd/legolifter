
#-757.0

extends UILifterElement

var ui_hide_position: float = -757.0
var ui_show_position: float = 235.0



func _ready() -> void:
	Messenger.ui_show_instructions.connect(_show_me)


func _on_ok_pressed() -> void:
	_hide_me()
