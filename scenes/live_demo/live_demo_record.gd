class_name LiveDemoRecord extends LiveDemoLive


var begin_record_tick : float = -1
var deleted_node_records: Dictionary = {}




@export var action_list : Array[String]


static var max_tick: float = -1

var demo_filename : String = "res://conf/demos/demo_record_v3.json"

var recorded_events: Dictionary = {
	"action_list" : [],
	"just_pressed": [],
	"pressed" : [],
}

func _is_active_changed(active)-> void : 
#	print("RecordLiveComponent %s is %s" % [get_path().get_concatenated_names(), "activated" if active else "deactivated"])
	if active:
		if begin_record_tick == -1: 
			begin_record_tick = Engine.get_physics_frames() #  Time.get_ticks_msec()
	else:
		pass
	
	
func _ready() -> void:
	recorded_events.action_list = action_list
	
func get_input_handler() -> Object:
	return self



func is_action_just_pressed(_name: String, exact_match: bool = false) -> bool:
	var ret = Input.is_action_just_pressed(_name, exact_match)
	if ret and action_list.has(_name):
		var tick = int(Engine.get_physics_frames() - begin_record_tick) # Time.get_ticks_msec()
		recorded_events.just_pressed.append({"tick": tick, "name": _name, "type":"P"})
		max_tick = max(max_tick, tick)
	return ret
	
func is_action_pressed(_name: String, exact_match: bool = false) -> bool:
	var ret =  Input.is_action_pressed(_name, exact_match)
	if ret and action_list.has(_name):
		var tick = int(Engine.get_physics_frames()  - begin_record_tick) # Time.get_ticks_msec()
		if Input.is_action_just_pressed(_name, exact_match):
			recorded_events.pressed.append({"tick": tick, "name": _name, "type":"P"})
			max_tick = max(max_tick, tick)
	return ret

func _store_randf(caller : Node, value : float ):
	var tick = int(Engine.get_physics_frames()  - begin_record_tick) # Time.get_ticks_msec()
	var caller_rec: Dictionary = recorded_events.get_or_add(build_key(caller), {})
	var a : Array = caller_rec.get_or_add("randf", [])
	a.append({"tick": tick, "value" : value})
	max_tick = max(max_tick, tick)
		

func randf(caller : Node) -> float:
	var r = super.randf(caller)
	_store_randf(caller, r)
	return r

func randf_range(caller: Node, from:float, to: float) -> float:
	var r = super.randf_range(caller, from, to)
	_store_randf(caller, r)
	return r

func _store_randi(caller : Node, value : int):
	var tick = int(Engine.get_physics_frames()  - begin_record_tick) # Time.get_ticks_msec()
	var caller_rec: Dictionary = recorded_events.get_or_add(build_key(caller), {})
	var a : Array = caller_rec.get_or_add("randi", [])
	a.append({"tick": tick, "value" : value})
	max_tick = max(max_tick, tick)
	
	
func randi(caller : Node ) -> int:
	var r = super.randi(caller)
	_store_randi(caller, r)
	return r
	
	
	
func randi_range(caller : Node, from:int, to:int) -> int:
	var r = super.randi_range(caller, from, to)
	_store_randi(caller, r)
	return r

func _unhandled_input(event: InputEvent):
	if event.is_released() and event is InputEventKey:
		for a in action_list:
			if event.is_action_released(a):
				var tick = int(Engine.get_physics_frames()  - begin_record_tick) # Time.get_ticks_msec()				
				recorded_events.pressed.append({"tick": tick, "name": a, "type":"R"})
				max_tick = max(max_tick, tick)


func get_recorded_events() -> Dictionary:
	recorded_events.get_or_add("max_tick", max_tick)
	return recorded_events
	

	
func _record_internal() -> void:
	if begin_record_tick == -1 : return 
	var json_string = JSON.stringify(get_recorded_events(),"    ")
	var file = FileAccess.open(demo_filename, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	begin_record_tick = -1
