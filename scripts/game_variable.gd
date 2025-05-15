extends Node


const ENEMY_SHELLS_LAYER : int = 5
const PLAYER_MISSILES_LAYER : int = 8

const AUDIO_MUSIC_BUS : int = 2
const AUDIO_EFFECTS_BUS : int = 1

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

var music_volume: float:
	get():
		return music_volume
	set(value):
		AudioServer.set_bus_volume_db(AUDIO_MUSIC_BUS, linear_to_db(value))
		music_volume = value
		
var effects_volume: float:
	get():
		return effects_volume
	set(value):
		AudioServer.set_bus_volume_db(AUDIO_EFFECTS_BUS, linear_to_db(value))
		effects_volume = value

var start_fullscreen : bool:
	get():
		return start_fullscreen
	set(value):
		if value:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		start_fullscreen = value



var start_heli_lives : int = 0
var max_hostage_onboard : int = 0
var hostages_per_house : int = 0
var start_level : int = 0
var keyboard_use_wsad : bool
var high_graphics : bool
var levels : Array

var user_parameters_list: Array = [
	"start_level",
	"start_fullscreen",
	"keyboard_use_wsad",
	"high_graphics",
	"music_volume",
	"effects_volume",
]
var all_parameters_list: Array = [
	"start_level",
	"start_fullscreen",
	"keyboard_use_wsad",
	"high_graphics",
	"music_volume",
	"effects_volume",
	"hostages_per_house",
	"max_hostage_onboard",
	"start_heli_lives",
	"levels",
]


var current_level : int = 0 :
	set(value):
		if value >= levels.size():
			push_warning("Attempting to reach a level with no data, setting level to max")
			current_level = levels.size() - 1
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
	if GameVariables.levels[GameVariables.current_level].has(id):
		return GameVariables.levels[GameVariables.current_level][id]
	else:
		push_warning("parm : %s does not exist in level %d" % [id, GameVariables.current_level])
		return {}

func apply_user_parameters()-> void: 
	#if start_fullscreen:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#else:
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if high_graphics:
		switch_to_dynamic_lights()
	else: 
		switch_to_lightmaps()
	


func save_parameters(all_parms: bool = false) -> void:
	var json_as_text = FileAccess.get_file_as_string(game_parameters_filename)
	var json: JSON = JSON.new()
	var error = json.parse(json_as_text)
	if error == OK:
		var data = json.data
		var the_list = all_parameters_list if all_parms else user_parameters_list  
		for parm in the_list:
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
