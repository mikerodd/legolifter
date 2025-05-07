class_name RecordPlayComponent extends LiveComponent


#signal end_of_record

static var recorded_session: Dictionary = {}
static var begin_play_tick : float = -1
static var record_end_tick : float

var local_recorded_session: Dictionary = {}
var current_pressed : int = 0
var current_just_pressed : int = 0 
var current_randi : int = 0
var current_randf : int = 0
var treated_low: int = 0


var currently_pressed_keys : Dictionary = {}
var currently_just_pressed_keys : Dictionary = {}


func _is_active_changed(value)-> void : 
#	print("RecordPlayComponent is %s" % ["activated" if value else "deactivated"])
	if value and begin_play_tick == -1: 
		if recorded_session.size() == 0:
			RecordPlayComponent.load_recorded()
		begin_play_tick = Engine.get_physics_frames() #  Time.get_ticks_msec()			

var new_local_session: Dictionary={}

func _ready():
	if recorded_session.size() == 0:
		RecordPlayComponent.load_recorded()

	var _test = recorded_session
	key = build_key()
	if recorded_session.has(key):
		local_recorded_session = recorded_session[key]
	else:
		# problem!
		push_warning("problem in saved recorded game, can't find my key : %s" % key)
		pass
	if local_recorded_session.has("action_list"):
		for a in local_recorded_session.action_list:
			currently_pressed_keys.set(a,"R")
			currently_just_pressed_keys.set(a,"R")

		for my_key in local_recorded_session["action_list"]:
			new_local_session.set(my_key,{"last_action": {"type":false,"tick":0},"ticks":[], "just_pressed":false})
		
		for evt in local_recorded_session["pressed"]:
			var cur = new_local_session[evt.name]
			for idx in range(cur["last_action"]["tick"],evt.tick):
				cur["ticks"].append(cur["last_action"]["type"])
			cur["ticks"].append(evt.type == "P")
			cur["last_action"] = {"type":(evt.type == "P"), "tick":evt.tick}
						
		for nlk in new_local_session.keys():
			for idx in range(new_local_session[nlk]["ticks"].size(), int(recorded_session["max_tick"])):
				new_local_session[nlk]["ticks"].append(false)
		pass
		
		
	
func is_action_just_pressed(_name: String, _exact_match: bool = false) -> bool:
#{"last_action": {"type":false,"tick":0},"ticks":[], "just_pressed":false})
	var tick = int(Engine.get_physics_frames()  - begin_play_tick) # Time.get_ticks_msec()
	if new_local_session[_name]["ticks"][tick]: 
		if new_local_session[_name]["just_pressed"]:
			return false
		else:
			new_local_session[_name]["just_pressed"] = true
			return true
	else: 
		new_local_session[_name]["just_pressed"] = false
		return false
	

func is_action_pressed(_name: String, _exact_match: bool = false) -> bool:
	var tick = int(Engine.get_physics_frames()  - begin_play_tick) # Time.get_ticks_msec()
	return new_local_session[_name]["ticks"][tick]

		
	
	
func get_input_handler() -> Object:
	return self


func randf() -> float:
	if not is_active: return 0

	var tick = int(Engine.get_physics_frames()  - begin_play_tick)
	var next = local_recorded_session.randf[current_randf]
	var offset = tick - next.tick
	if offset > 20: 
		push_warning("(tick:%d) Random desynchronized for %s, was excpecting:%d" % [tick, get_parent().get_path().get_concatenated_names(), next.tick])
	#print("random value float : %f" % next.value)
	current_randf += 1 
	return next.value

func randi() -> int:
	if not is_active: return 0

	var tick = int(Engine.get_physics_frames()  - begin_play_tick)
	var next = local_recorded_session.randi[current_randi]
	var offset = tick - next.tick
	if offset > 20: 
		push_warning("Random record desynchronized object: %s,tick:%d" % [get_parent()])
	current_randi += 1 
	return next.value

func randf_range(from:float, _to: float) -> float:
	if not is_active: return from
	return self.randf()

func randi_range(from:int, _to:int) -> int:
	if not is_active: return from
	return self.randi()


static func load_recorded() -> void:
	var json_string: String = FileAccess.get_file_as_string("user://demo_record.json")
	if FileAccess.get_open_error() != OK:
		push_error("could not open file !")
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		recorded_session = json.data
	
	record_end_tick = recorded_session.max_tick
