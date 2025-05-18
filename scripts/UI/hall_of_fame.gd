extends UILifterElement

var created_lines: Array = []
@onready var template: VBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer/LineTemplate

func _ready() -> void:
	super._ready()
	Messenger.ui_show_hall_of_fame.connect(_show_me)
	template.visible = false


func _on_ok_pressed() -> void:
	for line:Node in created_lines:
		line.queue_free()
	created_lines.clear()
	_hide_me()


func _show_me(darken : bool = false ) -> void :
	var idx = 1
	for score in GameVariables.hall_of_fame:
		var line : VBoxContainer = template.duplicate()
		created_lines.push_back(line)
		line.visible = true
		template.get_parent().add_child(line)
		line._init_me(idx, score)
		idx += 1
	super._show_me(darken)
	
