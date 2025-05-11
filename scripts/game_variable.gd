extends Node


const ENEMY_SHELLS_LAYER : int = 5
const PLAYER_MISSILES_LAYER : int = 8

var game_parameters : Dictionary
var game_parameters_filename : String


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
var start_fullscreen : bool
var keyboard_use_wsad : bool
var high_graphics : bool
var level : Array

var save_parameters_list: Array = [
	"start_level",
	"start_fullscreen",
	"keyboard_use_wsad",
	"high_graphics",
]

var current_level : int = 0 :
	set(value):
		if value >= level.size():
			push_warning("Attempting to reach a level with no data, setting level to max")
			current_level = level.size() - 1
		else:
			current_level = value

func _ready() -> void:
	Messenger.begin_game.connect(_on_begin_game)
	Messenger.begin_play.connect(_on_begin_play)

func _on_begin_play() -> void:
	if LiveDemo.current_active == "demo":
		current_level = self.start_level
		heli_lives = self.start_heli_lives
		

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

func apply_user_parameters()-> void: 
	if start_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
	switch_to_dynamic_lights() if high_graphics else switch_to_lightmaps()


func save_parameters() -> void:
	var json_as_text = FileAccess.get_file_as_string(game_parameters_filename)
	var json: JSON = JSON.new()
	var error = json.parse(json_as_text)
	if error == OK:
		var data = json.data
		for parm in save_parameters_list:
			data[parm] = self.get(parm)
			var save = FileAccess.open(game_parameters_filename,FileAccess.WRITE)
			save.store_string(JSON.stringify(json.data, "    "))
			save.close()
			apply_user_parameters()
			
	else:
		Logger.fatal("Error in parameters file %s : %s" % [game_parameters_filename, json.get_error_message()])
		get_tree().quit()
	pass

func load_parameters() -> void:
	
	var json_as_text = FileAccess.get_file_as_string(game_parameters_filename)
	var json = JSON.new()
	var error = json.parse(json_as_text)
	if error == OK:
		for parm in json.data.keys():
			self.set(parm, json.data[parm])
		Logger.debug("start level is : %d" % self.start_level)
	else:
		Logger.fatal("Error in parameters file %s : %s" % [game_parameters_filename, json.get_error_message()])
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
		


var use_lightmap: bool = false
func switch_to_lightmaps() -> void:
	use_lightmap = true
	for n : Node in get_tree().get_nodes_in_group("lightmaps"):
		n.visible = true
	for n : Node in get_tree().get_nodes_in_group("lights"):
		n.visible = false
	
func switch_to_dynamic_lights() -> void:
	use_lightmap = false
	for n : Node in get_tree().get_nodes_in_group("lightmaps"):
		n.visible = false
	for n : Node in get_tree().get_nodes_in_group("lights"):
		n.visible = true
