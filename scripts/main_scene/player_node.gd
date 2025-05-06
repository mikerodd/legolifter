extends Node

@export_node_path("Marker3D") var start_position_np
@onready var start_position = get_node(start_position_np)

@export var player_scene: PackedScene
@export var land_altitude : float


func _ready() -> void:
	Messenger.return_to_start.connect(func() : init_player(false))
	Messenger.begin_play.connect(_on_begin_play)
	Messenger.return_to_start.connect(_on_return_to_start)

func _on_return_to_start() -> void :
	init_player(false)

func _on_begin_play(_playmode: String) -> void:
	init_player(true)



func init_player(_can_play : bool ) -> void: 
	for p in get_children():
		if p is Player:
			p.queue_free()
			await p.tree_exited
			
			

	var spawn_p : Dictionary = {"parms" : {}, "parent": self}
	spawn_p["parms"]["name"] = GlobalUtils.build_unique_name("Player")
	spawn_p["parms"]["land_altitude"] = land_altitude
	spawn_p["parms"]["position"] = start_position.position
	spawn_p["parms"]["can_play"] = _can_play
	spawn_p["parms"]["@speed_scale"] = 0.5
	spawn_p["parms"]["#do_initiate"] = var_to_str(["NewFlyingSMP", "NewRotatingSMP"])
	
	GlobalUtils.player = player_scene.instantiate()
	GlobalUtils.player._init_me(spawn_p)

	

func old_init_player(_can_play: bool) -> void:
	for p in get_children():
		if p is Player:
			if p.is_dead:
				p.queue_free()
				GlobalUtils.player = player_scene.instantiate()
				GlobalUtils.player.name = GlobalUtils.build_unique_name("Player")
				add_child(GlobalUtils.player)
				GlobalUtils.player.land_altitude = land_altitude
			else:
				GlobalUtils.player = p
			
	GlobalUtils.player.position = start_position.position
	GlobalUtils.player.can_play = _can_play
