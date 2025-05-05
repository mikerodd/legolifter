class_name LiveDemoEntity extends Node


enum Behaviours {LIVE, RECORD, DEMO} 
## Default behaviour of the entity[br]
## [b]live[/b] : will return Input keys and random values[br]
## [b]record[/b] : will record a play[br]
## [b]play[/b] : will play a recorded play[br]
@export_enum ("live","record","demo") var default_behaviour: String = "live"

## define a signal to change the active input component rather than using set_active
@export_category("Set active signal")

## define if this entity will react to a active signal
@export var use_active_signal: bool

## Singleton emiting the signal
@export var message_bus: String

## Signal name, the signal should have one parameter : the component name to activate
@export var set_active_signal_name : String

## list of available components of this entity
var available_components : Dictionary

## current active component
var current_active: String

static var active_set_by_message: String

func _ready() -> void:
	for c in get_children():
		if c is LiveComponent:
			available_components[c.name] = c

	assert(default_behaviour, "default_behaviour is undefined")
	assert(available_components.has(default_behaviour), "default_behaviour (%s) is not a children of this entity" % default_behaviour )
	if active_set_by_message:
#		print("%s newly entered node activated : %s" % [get_path().get_concatenated_names(), active_set_by_message])
		set_active(active_set_by_message)
	else:
		set_active(default_behaviour)
	if use_active_signal:
		var msg = get_node("/root/" + message_bus)
		msg.connect(set_active_signal_name,_on_set_live_demo_mode)

		
func is_action_just_pressed(_name: String, exact_match: bool = false) -> bool:
	var handler: Object = available_components[current_active].get_input_handler()
	return handler.is_action_just_pressed(_name, exact_match)
	
func is_action_pressed(_name: String, exact_match: bool = false) -> bool:
	var handler: Object = available_components[current_active].get_input_handler()
	return handler.is_action_pressed(_name, exact_match)


func set_active(comp_name: String) -> bool:
	if comp_name == current_active :
		return true
	if available_components.has(current_active): 
		available_components[current_active].is_active = false 
	if available_components.has(comp_name):
		available_components[comp_name].is_active = true
		current_active = comp_name
		return true
	return false

func _on_set_live_demo_mode(n: String):
	active_set_by_message = n   # for LiveDemo nodes insterted after to catch-up
	#print("%s Activating component %s via message" % [get_path().get_concatenated_names(),n])
	set_active(n)

func randf() -> float:
	return available_components[current_active].randf()
	
func randi() -> int:
	return available_components[current_active].randi()
	
func randf_range(from:float, to: float) -> float:
	return available_components[current_active].randf_range(from, to)
	
func randi_range(from:int, to:int) -> int:
	return available_components[current_active].randi_range(from, to)


func _on_record_recorder_finished() -> void:
	pass # Replace with function body.
