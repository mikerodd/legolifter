extends Node

@export_node_path("Marker3D") var start_position_np
@onready var start_position = get_node(start_position_np)
@export_node_path("Marker3D") var player_limit_right_np
@export_node_path("Marker3D") var player_limit_left_np
@export_node_path("Marker3D") var player_limit_up_np
@onready var player_limit_right: Marker3D = get_node(player_limit_right_np)
@onready var player_limit_left: Marker3D = get_node(player_limit_left_np)
@onready var player_limit_up: Marker3D = get_node(player_limit_up_np)

@export var player_scene: PackedScene
@export var land_altitude : float


func _ready() -> void:
	Messenger.return_to_start.connect(func() : init_player(false))
	Messenger.begin_play.connect(_on_begin_play)
	Messenger.return_to_start.connect(_on_return_to_start)

func _on_return_to_start() -> void :
	init_player(false)

func _on_begin_play() -> void:
	init_player(true)



func init_player(_can_play : bool ) -> void: 
	for p in get_children():
		if p is Player:
			p.queue_free()
			await p.tree_exited
			
			

	var spawn_p : Dictionary = {"parms" : {}, "parent": self}
	spawn_p["parms"]["name"] = LiveDemo.build_unique_name("Player")
	spawn_p["parms"]["land_altitude"] = land_altitude
	spawn_p["parms"]["position"] = start_position.position
	spawn_p["parms"]["can_play"] = _can_play
	spawn_p["parms"]["limit_right"] = player_limit_right.position
	spawn_p["parms"]["limit_left"] = player_limit_left.position
	spawn_p["parms"]["limit_up"] = player_limit_up.position
	spawn_p["parms"]["@speed_scale"] = 0.5
	spawn_p["parms"]["#do_initiate"] = var_to_str(["NewFlyingSMP", "NewRotatingSMP"])
	
	GlobalUtils.player = player_scene.instantiate()
	GlobalUtils.player._init_me(spawn_p)

	
