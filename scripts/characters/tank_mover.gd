extends Node3D

@onready var tp_left = $track_path_left
@onready var tp_right = $track_path_right


func move_forward() -> void:
	tp_left.move_forward()
	tp_right.move_forward()

func move_backward() -> void:
	tp_left.move_backward()
	tp_right.move_backward()

func turn_clockwise() -> void:
	tp_left.move_forward()
	tp_right.move_backward()

func turn_c_clockwise() -> void:
	tp_left.move_backward()
	tp_right.move_forward()

func move_stop():
	tp_left.move_stop()
	tp_right.move_stop()
