extends UILifterElement

var ui_hide_position: float = -400.0
var ui_show_position: float = 5

@onready var template: VBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer/LineTemplate

func _ready() -> void:
	Messenger.ui_show_hall_of_fame.connect(_show_me)
	template.visible = false


func _on_ok_pressed() -> void:
	_hide_me()


func _show_me(darken : bool = false ) -> void :
	for score in GameVariables.hall_of_fame:
		var line : VBoxContainer = template.duplicate()
		line.visible = true
		template.get_parent().add_child(line)
		line._init_me(score)
	super._show_me(darken)
	
