extends UILifterElement



func _ready() -> void:
	super._ready()
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
