extends Node

@export var house_scene : PackedScene
var house_count : int 


func _ready() -> void:
	Messenger.return_to_start.connect(init_houses)
	Messenger.level_started.connect(_on_level_started)

	
	
	
func _on_level_started(_level : int ) -> void:
	house_count = GameVariables.get_my_parms(name)["house_count"]
	init_houses()	
	
	
func cleanup_houses() -> void:
	Logger.debug("Initialize houses")
	for h in get_children():
		if h is House:
			h.name = "__" + h.name
			h.queue_free()
	
	
func spwan_house_in_game() -> void:		
	var tmp_count : int = 0
	for p in get_children():
		if p is Marker3D:
			var spawn_p : Dictionary = {"parms" : {}, "parent": self}
			spawn_p["parms"]["name"] = GlobalUtils.build_unique_name("House")
			spawn_p["parms"]["position"] = p.position
			spawn_p["parms"]["rotation"] = p.rotation
			spawn_p["parms"]["current_hostage_count"] =  GameVariables.hostages_per_house 
			spawn_p["parms"]["is_destroyed"] = false
			spawn_p["parms"]["timer_is_stopped"] = true
			GameVariables.detained_count += GameVariables.hostages_per_house
			
			var h : House = house_scene.instantiate()
			h._init_me(spawn_p)
			tmp_count += 1
			if tmp_count >= house_count : return

func init_houses() -> void :
	GameVariables.init_scores()	
	cleanup_houses()
	spwan_house_in_game()
