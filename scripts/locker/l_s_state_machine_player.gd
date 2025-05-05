@tool
class_name LSStateMachinePlayer
extends"res://addons/imjp94.yafsm/src/StateMachinePlayer.gd"

var do_initiate : bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	set_process(false)
	set_physics_process(false)
	_initiate()
