class_name LiveDemoDemo extends LiveDemoLive


signal demo_finished

var signal_sent : bool = false 
var recorded_session: Dictionary = {}
var demo_actions_map: Dictionary={}
var begin_play_tick : float = -1
var record_end_tick : float

var current_pressed : int = 0
var current_just_pressed : int = 0 
var treated_low: int = 0
var demo_filename : String = "res://conf/demos/demo_record_v3.json"

var currently_pressed_keys : Dictionary = {}
var currently_just_pressed_keys : Dictionary = {}


func _is_active_changed(value)-> void : 
#	print("RecordPlayComponent is %s" % ["activated" if value else "deactivated"])
	if value:
		signal_sent = false
		load_recorded()
		setup_demo_action_map()
		begin_play_tick = Engine.get_physics_frames()
	else:
		begin_play_tick = -1

		


func setup_demo_action_map():
	if recorded_session.size() == 0:
		load_recorded()

	if recorded_session.has("action_list"):
		for a in recorded_session.action_list:
			currently_pressed_keys.set(a,"R")
			currently_just_pressed_keys.set(a,"R")

		for my_key in recorded_session["action_list"]:
			demo_actions_map.set(my_key,{"last_action": {"type":false,"tick":0},"ticks":[], "just_pressed":false})
		
		for evt in recorded_session["pressed"]:
			var cur = demo_actions_map[evt.name]
			for idx in range(cur["last_action"]["tick"],evt.tick):
				cur["ticks"].append(cur["last_action"]["type"])
			cur["ticks"].append(evt.type == "P")
			cur["last_action"] = {"type":(evt.type == "P"), "tick":evt.tick}
						
		for nlk in demo_actions_map.keys():
			for idx in range(demo_actions_map[nlk]["ticks"].size(), int(recorded_session["max_tick"] + 1)):
				demo_actions_map[nlk]["ticks"].append(false)
		pass
		

func get_and_check_tick() -> int:
	var tick = int(Engine.get_physics_frames()  - begin_play_tick)
	if not is_active or tick > record_end_tick: 
		if not signal_sent:
			demo_finished.emit()
			signal_sent = true
		return -1
	else:
		return tick

	
func is_action_just_pressed(_name: String, _exact_match: bool = false) -> bool:
	var tick = get_and_check_tick()
	if tick == -1:
		return false

	if demo_actions_map[_name]["ticks"][tick]: 
		if demo_actions_map[_name]["just_pressed"]:
			return false
		else:
			demo_actions_map[_name]["just_pressed"] = true
			return true
	else: 
		demo_actions_map[_name]["just_pressed"] = false
		return false
	

func is_action_pressed(_name: String, _exact_match: bool = false) -> bool:
	var tick = get_and_check_tick()
	if tick == -1:
		return false

	return demo_actions_map[_name]["ticks"][tick]

		
	
	
func get_input_handler() -> Object:
	return self


func randf(caller : Node) -> float:
	var tick = get_and_check_tick()
	if tick == -1:
		return 0.5

	var key = build_key(caller)
	var current_randf = recorded_session[key].get_or_add("current_randf",0)
	var next = recorded_session[key]["randf"][current_randf]
	var offset = tick - next.tick
	if offset > 20: 
		push_warning("(tick:%d) Random desynchronized for %s, was excpecting:%d" % [tick, get_parent().get_path().get_concatenated_names(), next.tick])
	#print("random value float : %f" % next.value)
	current_randf += 1 
	recorded_session[key].set("current_randf",current_randf)
	return next.value

func randi(caller : Node) -> int:
	var tick = get_and_check_tick()
	if tick == -1:
		return 42

	var key = build_key(caller)
	var current_randi = recorded_session[key].get_or_add("current_randi",0)
	var next = recorded_session[build_key(caller)]["randi"][current_randi]
	var offset = tick - next.tick
	if offset > 20: 
		push_warning("Random record desynchronized object: %s,tick:%d" % [get_parent()])
	current_randi += 1 
	recorded_session[key].set("current_randi",current_randi)
	return next.value

func randf_range(caller, from:float, _to: float) -> float:
	if get_and_check_tick() == -1:
		return (_to - from ) / 2
	else:
		return self.randf(caller)

func randi_range(caller, from:int, _to:int) -> int:
	if get_and_check_tick() == -1:
		return round(float(_to - from ) / 2)
	else:
		return self.randi(caller)


func load_recorded() -> void:
	var json_string: String = FileAccess.get_file_as_string(demo_filename)
	if FileAccess.get_open_error() != OK:
		push_error("could not open file !")
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		recorded_session = json.data
	
	record_end_tick = recorded_session.max_tick
	pass
