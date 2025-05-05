class_name RecordLiveComponent extends LiveComponent

signal recorder_finished

static var begin_record_tick : float = -1
static var deleted_node_records: Dictionary = {}




@export var action_list : Array[String]


static var recorders : Array = []
static var max_tick: float = -1



var recorded_events: Dictionary = {
	"action_list" : [],
	"just_pressed": [],
	"pressed" : [],
	"randf" : [],
	"randi" : []
}

func _is_active_changed(active)-> void : 
#	print("RecordLiveComponent %s is %s" % [get_path().get_concatenated_names(), "activated" if active else "deactivated"])
	if active:
		if begin_record_tick == -1: begin_record_tick = Time.get_ticks_msec()
		recorders.append(self)
		$Timer.start()
	else:
		pass
	
	
func _ready() -> void:
	recorded_events.action_list = action_list
	if get_parent().get_parent().get_parent().get_path().get_concatenated_names() == "root/Game/3D/PlayerNode":
		pass
	
func get_input_handler() -> Object:
	return self



func is_action_just_pressed(_name: String, exact_match: bool = false) -> bool:
	var ret = Input.is_action_just_pressed(_name, exact_match)
	if ret and action_list.has(_name):
		var tick = int(Time.get_ticks_msec() - begin_record_tick)
		recorded_events.just_pressed.append({"tick": tick, "name": _name, "type":"P"})
		max_tick = max(max_tick, tick)
	return ret
	
func is_action_pressed(_name: String, exact_match: bool = false) -> bool:
	var ret =  Input.is_action_pressed(_name, exact_match)
	if ret and action_list.has(_name):
		var tick = int(Time.get_ticks_msec() - begin_record_tick)
		if Input.is_action_just_pressed(_name, exact_match):
			recorded_events.pressed.append({"tick": tick, "name": _name, "type":"P"})
			max_tick = max(max_tick, tick)
			
	return ret

func randf() -> float:
	var r = super.randf()
	var tick = int(Time.get_ticks_msec() - begin_record_tick)
	recorded_events.randf.append({"tick": tick, "value" : r})
	max_tick = max(max_tick, tick)
	return r
	
func randi() -> int:
	var r = super.randi()
	var tick = int(Time.get_ticks_msec() - begin_record_tick)
	recorded_events.randi.append({"tick": tick, "value" : r})
	max_tick = max(max_tick, tick)
	return r
	
func randf_range(from:float, to: float) -> float:
	var r = super.randf_range(from, to)
	var tick = int(Time.get_ticks_msec() - begin_record_tick)
	recorded_events.randf.append({"tick": tick, "value" : r})
	max_tick = max(max_tick, tick)
	return r
	
	
func randi_range(from:int, to:int) -> int:
	var r = super.randi_range(from, to)
	var tick = int(Time.get_ticks_msec() - begin_record_tick)
	recorded_events.randi.append({"tick": tick, "value" : r})
	max_tick = max(max_tick, tick)
	return r

func _unhandled_input(event: InputEvent):
	if event.is_released() and event is InputEventKey:
		for a in action_list:
			if event.is_action_released(a):
				var tick = int(Time.get_ticks_msec() - begin_record_tick)					
				recorded_events.pressed.append({"tick": tick, "name": a, "type":"R"})
				max_tick = max(max_tick, tick)
				

#func _unhandled_input(event: InputEvent):
#
	#if event.is_released() and event is InputEventKey:
		##for a in InputMap.get_actions():
		#for a in action_list:
			#for e in InputMap.action_get_events(a):
				#if e.is_match(event):
					#var tick = int(Time.get_ticks_msec() - begin_record_tick)					
					#recorded_events.pressed.append({"tick": tick, "name": a, "type":"R"})
					#max_tick = max(max_tick, tick)
					#break


func get_recorded_events() -> Dictionary:
	key = build_key()
	var ret: Dictionary = {}
	ret = {"max_tick": max_tick, key : recorded_events}
	return ret
	



	
static func record_the_play() -> void:
	if begin_record_tick == -1 : return 
	var to_record: Dictionary = {}
	print("# of active recorders : %d" % recorders.size() )
	var _tmp = recorders
	for r:RecordLiveComponent in recorders:
		print("recording %s..." % r.get_path().get_concatenated_names())
		to_record.merge(r.get_recorded_events())
	print("# of deleted recorders : %d" % deleted_node_records.size() )
	if deleted_node_records.size() != 0:
		to_record.merge(deleted_node_records)
	var json_string = JSON.stringify(to_record,"    ")
	var file = FileAccess.open("user://demo_record.json", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	begin_record_tick = -1



func _on_timer_timeout() -> void:
	if begin_record_tick != -1:
		record_the_play()
		print("----------------- Record finished")
		recorder_finished.emit()
		

func _on_tree_exiting() -> void:
	if not is_active: return 
	var r = get_recorded_events()
	var content = r[build_key()]
	if not (content.just_pressed.size() == 0 and \
		   content.pressed.size() == 0 and \
		   content.randi.size() == 0 and\
		   content.randf.size() == 0):
		deleted_node_records.merge(get_recorded_events())
		#print("Component %s leaving the tree and saved" % get_path().get_concatenated_names() )
	#else:
		#print("Component %s is empty, leaving the tree and is not saved" % get_path().get_concatenated_names() )
		
	var idx = recorders.find(self)
	recorders.remove_at(idx)
