extends Node


const ENEMY_SHELLS_LAYER : int = 5
const PLAYER_MISSILES_LAYER : int = 8

const AUDIO_MUSIC_BUS : int = 2
const AUDIO_EFFECTS_BUS : int = 1

var game_parameters : Dictionary
var game_parameters_filename : String
var user_parameters_filename : String


var saved_count : int = 0 :
	set(value):
		score += (value - saved_count) * 1000
		saved_count = value
		Messenger.update_scores.emit()

var out_count  : int = 0 :
	set(value):
		out_count = value
		Messenger.update_scores.emit()

var dead_count : int = 0 : 
	set(value):
		score = max(0,score - (value - dead_count) * 500)
		dead_count = value
		Messenger.update_scores.emit()

var detained_count : int = 0 : 
	set(value):
		detained_count = value
		Messenger.update_scores.emit()

var heli_count : int = 0 :
	set(value):
		score += max(0,(value - heli_count)) * 100
		heli_count = value
		Messenger.update_scores.emit()
	
var heli_lives : int = 0 :
	set(value):
		heli_lives = value
		Messenger.update_scores.emit()

var music_volume: float = 1.14:
	get():
		return music_volume
	set(value):
		AudioServer.set_bus_volume_db(AUDIO_MUSIC_BUS, linear_to_db(value))
		music_volume = value
		
var effects_volume: float = 1.39:
	get():
		return effects_volume
	set(value):
		AudioServer.set_bus_volume_db(AUDIO_EFFECTS_BUS, linear_to_db(value))
		effects_volume = value

var start_fullscreen : bool = false:
	get():
		return start_fullscreen
	set(value):
		if value:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		start_fullscreen = value


var high_graphics : bool = true:
		get():
			return high_graphics
		set(value):
			if value:
				switch_to_dynamic_lights()
			else: 
				switch_to_lightmaps()
			high_graphics = value
var version: String = "":
	get():
		return version
	set(value):
		version = value
		pass # nope !
		
		


var start_heli_lives : int = 0
var max_hostage_onboard : int = 0
var hostages_per_house : int = 0
var start_level : int = 0
var keyboard_use_wsad : bool = false
var levels : Array
var hall_of_fame: Array 
var score: int = 0 

var user_parameters_list: Array = [
	"start_level",
	"start_fullscreen",
	"keyboard_use_wsad",
	"high_graphics",
	"music_volume",
	"effects_volume",
	"hall_of_fame",
]
var game_parameters_list: Array = [
	"hostages_per_house",
	"max_hostage_onboard",
	"start_heli_lives",
	"levels",
	"version",
]

var fake_level: int 

var current_level : int = 0 :
	set(value):
		if value >= levels.size():
			push_warning("Attempting to reach a level with no data, setting level to max")
			current_level = levels.size() - 1
			fake_level = value
		else:
			current_level = value
			fake_level = value

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
	score = 0

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
	if high_graphics:
		switch_to_dynamic_lights()
	else: 
		switch_to_lightmaps()
	


func save_json_file(filename: String, parm_list:Array) -> void:
	var to_save: Dictionary = {}
	for parm in parm_list:
		to_save.set(parm,self.get(parm))
	var save = FileAccess.open(filename, FileAccess.WRITE)
	save.store_string(JSON.stringify(to_save , "    "))
	save.close()


func save_parameters(all_parms: bool = false) -> void:
	if all_parms:
		save_json_file(game_parameters_filename,game_parameters_list)
	save_json_file(user_parameters_filename, user_parameters_list)
	apply_user_parameters()


func load_json_file(filename: String) -> Dictionary:
	var json_as_text = FileAccess.get_file_as_string(filename)
	var json = JSON.new()
	var error = json.parse(json_as_text)
	if error == OK:
		return json.data
	else:
		Logger.fatal("Error in loading file %s : %s" % [game_parameters_filename, json.get_error_message()])
		return {}


func store_parameters(data: Dictionary,  parm_list:Array) -> void:
	for parm in parm_list:
		self.set(parm, data[parm])


func load_parameters() -> void:
	var dic1 = load_json_file(game_parameters_filename)
	store_parameters(dic1, game_parameters_list)
	var dic2 = load_json_file(user_parameters_filename)
	if dic2.size() == 0: # first use of the game 
		save_json_file(user_parameters_filename, user_parameters_list)
	else:
		store_parameters(dic2, user_parameters_list)


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


func rank_score_in_hall_of_fame() -> int:
	var idx: int = 1
	if hall_of_fame.size() == 0:
		return idx
	for sc in hall_of_fame:
		if score > sc.score:
			return idx
		idx += 1
	return 0

func save_new_high_score(rank: int, callsign : String) -> void:
	assert(rank > 0, "Problem in rank : should be > 0 !")
	hall_of_fame.insert(rank - 1, {"name": callsign, "score": score})
	if hall_of_fame.size() > 10:
		hall_of_fame.pop_back()
	save_parameters()
