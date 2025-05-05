extends Node


const ENEMY_SHELLS_LAYER : int = 5
const PLAYER_MISSILES_LAYER : int = 8

var game_parameters : Dictionary



var saved_count : int = 0 :
	set(value):
		saved_count = value
		Messenger.update_scores.emit()

var out_count  : int = 0 :
	set(value):
		out_count = value
		Messenger.update_scores.emit()

var dead_count : int = 0 : 
	set(value):
		dead_count = value
		Messenger.update_scores.emit()

var detained_count : int = 0 : 
	set(value):
		detained_count = value
		Messenger.update_scores.emit()

var heli_count : int = 0 :
	set(value):
		heli_count = value
		Messenger.update_scores.emit()
	
var heli_lives : int = 0 :
	set(value):
		heli_lives = value
		Messenger.update_scores.emit()

var start_heli_lives : int = 0
var max_hostage_onboard : int = 0
var hostages_per_house : int = 0
var start_level : int = 0
var level : Array

var current_level : int = 0 :
	set(value):
		if value >= level.size():
			push_warning("Attempting to reach a level with no data, setting level to max")
			current_level = level.size() - 1
		else:
			current_level = value

func _ready() -> void:
	Messenger.begin_game.connect(_on_begin_game)


func _on_begin_game() -> void:
	current_level = self.start_level
	heli_lives = self.start_heli_lives

func init_scores() -> void:
	saved_count = 0
	out_count = 0
	dead_count = 0
	detained_count = 0
	heli_count = 0

func check_end_level() -> bool :
	return (out_count  == 0 and 
			detained_count == 0 and
			heli_count == 0 and 
			(dead_count != 0 or 
			saved_count != 0))



func get_my_parms(id : String) -> Dictionary:
	if GameVariables.level[GameVariables.current_level].has(id):
		return GameVariables.level[GameVariables.current_level][id]
	else:
		push_warning("parm : %s does not exist in level %d" % [id, GameVariables.current_level])
		return {}


func load_parameters(json_file) -> void:
	
	var json_as_text = FileAccess.get_file_as_string(json_file)
	var json = JSON.new()
	var error = json.parse(json_as_text)
	if error == OK:
		for parm in json.data.keys():
			self.set(parm, json.data[parm])
		Logger.debug("start level is : %d" % self.start_level)
	else:
		Logger.fatal("Error in parameters file %s : %s" % [json_file, json.get_error_message()])
		get_tree().quit()

func get_level_array() -> Array :
	if game_parameters:
		return game_parameters.level
	else:
		return []

func get_heli_lives() -> int:
	if game_parameters:
		return game_parameters.heli_lives
	else: return 0
		
