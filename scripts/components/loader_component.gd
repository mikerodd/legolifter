class_name LoaderComponent extends Node

static var global_parms 

@export var parameter_id : String
var parms : Dictionary


func _ready() -> void:
	Messenger.level_started.connect(_on_level_started)
	
func _on_level_started(_level : int) -> void :
	if parameter_id:
		if _level >= GameVariables.levels.size():
			_level = GameVariables.levels.size() - 1
		parms = GameVariables.levels[_level][parameter_id]

	else:
		Logger.fatal("LoaderComponent(%s) parameter_id is not initialized " % [get_path()] )

func get_parms_level() -> Dictionary : 
	var lev = GameVariables.current_level
	if lev >= GameVariables.levels.size(): 
			lev = global_parms.levels.size() - 1
	if global_parms.levels[lev]:
		return global_parms.levels[lev][parameter_id]
	else:
		return {}
	

static func load_parameters(json_file) -> bool:
	
	var json_as_text = FileAccess.get_file_as_string(json_file)
	var json = JSON.new()
	var error = json.parse(json_as_text)
	if error == OK:
		global_parms  = json.data
		return true
	else:
		Logger.fatal("Error in parms file %s : %s" % [json_file, json.get_error_message()])
		return false
