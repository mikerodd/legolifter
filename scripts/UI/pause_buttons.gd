extends UILifterElement

var ui_hide_position: float = -144.0
var ui_show_position: float = 142.0



func _ready() -> void:
	#_show_me(true)
	Messenger.ui_show_pause_buttons.connect(_show_me)

func _on_continue_pressed() -> void:
	Messenger.ui_englight_display.emit()
	_hide_me()
	get_tree().paused = false	

func _on_menu_pressed() -> void:
	_hide_me()
	show_modal(self,Messenger.ui_show_confirm)

func _show_me(_darken: bool = false) -> void:
	super._show_me(true)
	get_tree().paused = true
