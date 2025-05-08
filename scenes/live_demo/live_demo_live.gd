class_name LiveDemoLive extends Node


var random: RandomNumberGenerator = RandomNumberGenerator.new()

var is_active : bool = false:
	set(value):
		is_active = value
		_is_active_changed(value)

	
func _is_active_changed(_value)-> void : 
	pass
		
func build_key(caller : Node):
		return "/" + caller.get_path().get_concatenated_names()	

func get_input_handler() -> Object:
	return Input


func randf(_caller : Node) -> float:
	return random.randf()
	
func randi(_caller : Node) -> int:
	return random.randi()
	
func randf_range(_caller : Node, from:float, to: float) -> float:
	return random.randf_range(from, to)
	
func randi_range(_caller : Node, from:int, to:int) -> int:
	return random.randi_range(from, to)
