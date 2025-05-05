extends UILifterElement

var ui_hide_position: float = -430.0
var ui_show_position: float = 0


func _ready() -> void:
	Messenger.ui_show_confirm.connect(_show_me)

func _on_yes_pressed() -> void:
	cancel_return_to_previous()
	_hide_me()
	get_tree().paused = false	
	Messenger.ui_englight_display.emit()
	Messenger.return_to_start.emit()


func _on_no_pressed() -> void:
	cancel_return_to_previous()
	Messenger.ui_englight_display.emit()
	_hide_me()
	get_tree().paused = false	
