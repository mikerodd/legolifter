extends UILifterElement

var ui_hide_position: float = -278.0
var ui_show_position: float = 0

@export_node_path("UILifterElement") var myself

func _ready() -> void:
	Messenger.return_to_start.connect(_show_me)	
	Messenger.begin_play.connect(_on_begin_play)
	LiveDemo.demo_finished.connect(_on_demo_finished)

func _on_exit_pressed() -> void:
	Messenger.exit_game.emit()

func _on_play_pressed() -> void:
	Messenger.begin_game.emit()

func _on_instructions_pressed() -> void:
	Messenger.demo_timer_forbidden.emit()
	_hide_me()
	show_modal(self,Messenger.ui_show_instructions)

func _on_begin_play():
		_hide_me()
		
func _on_demo_finished():
	_show_me()
		
func _show_me(darken : bool = false ) -> void:
	Messenger.demo_timer_authorized.emit()
	super._show_me(darken)
	

func _on_config_pressed() -> void:
	Messenger.demo_timer_forbidden.emit()
	_hide_me()
	show_modal(self,Messenger.ui_show_parameters)
