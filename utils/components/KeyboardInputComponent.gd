
extends BaseComponent


func update (state):

	state.move_left =  0
	state.move_right = 0 
	state.just_move_left =  0
	state.just_move_right = 0 
	state.move_up = 0
	state.move_down = 0
	state.action = 0
	state.just_action = 0
	

	if Input.is_action_pressed("move_left"):
		state.move_left = 1
	elif Input.is_action_pressed("move_right"):
		state.move_right = 1
		
	if Input.is_action_pressed("move_up"):
		state.move_up = 1
	elif Input.is_action_pressed("move_down"):
		state.move_down = 1
 
	if Input.is_action_pressed("fire"):
		state.action = 1

	if Input.is_action_just_pressed("fire"):
		state.just_action = 1
		
	if Input.is_action_just_pressed("move_left"):
		state.just_move_left = 1
	elif Input.is_action_just_pressed("move_right"):
		state.just_move_right = 1
		
