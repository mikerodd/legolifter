
#-757.0

extends UILifterElement

var ui_hide_position: float =  0 #- self.size.x  #-757
var ui_show_position: float = self.size.x # 235.0



func _ready() -> void:
	super._ready()
	Messenger.ui_show_instructions.connect(_show_me)


func _on_ok_pressed() -> void:
	_hide_me()
