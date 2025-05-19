extends Node

@export var tank_scene : PackedScene
@export var lego_tank_scene : PackedScene
@export_node_path var tank_limit_np : NodePath
@onready var tank_limit: Marker3D = get_node(tank_limit_np)
@export_node_path var tank_spawn_location_np : NodePath
@onready var tank_spawn_location : Marker3D = get_node(tank_spawn_location_np)
@export_node_path var spawn_timer_np : NodePath
@onready var spawn_timer : Timer = get_node(spawn_timer_np)


var my_parms : Dictionary

func _ready() -> void:
	Messenger.level_started.connect(_on_level_started)
	Messenger.return_to_start.connect(_on_return_to_start)

func _on_return_to_start() -> void :
	Logger.debug("stopping spawn timer")
	spawn_timer.stop()	
	cleanup_tanks()

func _on_level_started(_level : int) -> void:
	cleanup_tanks()
	my_parms = GameVariables.get_my_parms(self.name)
	Logger.debug("spawn variables:  rate:%f, rate_range: %f  " % [my_parms["rate"],my_parms["rate_range"]] )
	spawn_timer.wait_time = my_parms["rate"] + \
		LiveDemo.randf_range(self, 0, my_parms["rate_range"])
	Logger.debug("starting spawn timer")
	spawn_timer.paused = false
	spawn_timer.start()
	
	

func cleanup_tanks() -> void:
	Logger.debug("cleanup_tanks - Cleaning up tanks")
	for t in get_children():
		if t is LegoTank or t is Tank: 
			t.queue_free()


func safe_position_for_tank(pos_x : float) -> bool :
	var safe : bool = true
	for t in get_tree().get_nodes_in_group("enemy_tanks"):
		if (pos_x > t.position.x - 4 
				and pos_x < t.position.x + 4):
			safe = false
	return safe


func spawn_tank_in_game() -> void:
	var attempt : int = 0
	var safe_position: float
	
	while attempt < 20:  # Find a spot for this tank
		safe_position = min(GlobalUtils.game_camera.position.x - 18,tank_spawn_location.position.x) -  attempt * 5
		if safe_position_for_tank(safe_position): 
			break
		attempt += 1
	if attempt > 20: 
		Logger.debug("failed to create a new  tank...")
		return
		
	var spawn_p : Dictionary = {"parms" : {}, "parent": self}
	spawn_p["parms"]["name"] = LiveDemo.build_unique_name("Tank")
	spawn_p["parms"]["position"] = Vector3(safe_position, tank_spawn_location.position.y,tank_spawn_location.position.z)
	spawn_p["parms"]["rotation"] = Vector3(0, PI/2, 0)
	spawn_p["parms"]["right_limit"] = tank_limit.position.x
	spawn_p["parms"]["intel"] = my_parms["tank_intel"]
	
	var new_tank : LegoTank
	new_tank = lego_tank_scene.instantiate()
	new_tank._init_me(spawn_p)

func _on_spawn_timer_timeout() -> void:
	if  (get_tree().get_node_count_in_group("enemy_tanks") 
			< my_parms["limit"]):
		spawn_timer.wait_time = my_parms["rate"] + \
			LiveDemo.randf_range(self, 0, my_parms["rate_range"])
		spawn_tank_in_game()
	else:
		# we keep the timer running to check if some tanks have been destroyed 
		# so we can create new ones
		#spawn_timer.stop()
		pass
