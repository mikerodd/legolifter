class_name LiveComponent extends Node


var random: RandomNumberGenerator = RandomNumberGenerator.new()

var is_active : bool = false:
	set(value):
		is_active = value
		_is_active_changed(value)
var key : String
	
	
func _is_active_changed(_value)-> void : 
#	print("LiveComponent %s is %s" % [get_path().get_concatenated_names(), "activated" if value else "deactivated"])
	pass
		
func build_key():
		return "/" + get_parent().get_path().get_concatenated_names()	

func get_input_handler() -> Object:
	return Input


func randf() -> float:
	return random.randf()
	
func randi() -> int:
	return random.randi()
	
func randf_range(from:float, to: float) -> float:
	return random.randf_range(from, to)
	
func randi_range(from:int, to:int) -> int:
	return random.randi_range(from, to)
