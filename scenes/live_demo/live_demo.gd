extends Node

signal demo_finished

enum Behaviours {LIVE, RECORD, DEMO} 
## Default behaviour of the entity[br]
## [b]live[/b] : will return Input keys and random values[br]
## [b]record[/b] : will record a play[br]
## [b]play[/b] : will play a recorded play[br]
@export_enum ("live","record","demo") var default_behaviour: String = "live"


@onready var available_components = {
	"live" : $Live,
	"record" : $Record,
	"demo" : $Demo
}

## current active component
var current_active: String:
	set(comp_name):
		if comp_name == current_active :
			return
		if available_components.has(current_active): 
			available_components[current_active].is_active = false 
		if available_components.has(comp_name):
			available_components[comp_name].is_active = true
			current_active = comp_name
		else:
			push_error("Wrong value for LiveDemo, expecting live demo or record, recieved %s" % comp_name)
	get():
		return current_active
		
		


var demo_filename : String:
	set(value):
		available_components["record"].demo_filename = value
		available_components["demo"].demo_filename = value
		
		demo_filename = value

func _ready() -> void:

	assert(default_behaviour, "default_behaviour is undefined")
	current_active = default_behaviour

		
func is_action_just_pressed(_name: String, exact_match: bool = false) -> bool:
	var handler: Object = available_components[current_active].get_input_handler()
	return handler.is_action_just_pressed(_name, exact_match)
	
func is_action_pressed(_name: String, exact_match: bool = false) -> bool:
	var handler: Object = available_components[current_active].get_input_handler()
	return handler.is_action_pressed(_name, exact_match)


#func set_active(comp_name: String) -> bool:
	#if comp_name == current_active :
		#return true
	#if available_components.has(current_active): 
		#available_components[current_active].is_active = false 
	#if available_components.has(comp_name):
		#available_components[comp_name].is_active = true
		#current_active = comp_name
		#return true
	#return false
#
#func get_active() -> String:
	#return current_active

func record_demo() -> void:
	available_components["record"]._record_internal()
	print("----------------- Record finished")
		


func randf(caller : Node) -> float:
	return available_components[current_active].randf(caller)
	
func randi(caller : Node) -> int:
	return available_components[current_active].randi(caller)
	
func randf_range(caller : Node, from:float, to: float) -> float:
	return available_components[current_active].randf_range(caller, from, to)
	
func randi_range(caller : Node, from:int, to:int) -> int:
	return available_components[current_active].randi_range(caller, from, to)


func _on_demo_demo_finished() -> void:
	demo_finished.emit()


	

var node_counter = 0
func build_unique_name(_name: String) -> String:
	node_counter +=1
	return _name + str(node_counter)
	
func reinit_unique_name() -> void:
	node_counter = 0
