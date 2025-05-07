class_name CosmicNode extends Node


@export var plane_scene : PackedScene
@export_node_path("Path3D") var approach_path_l_np : NodePath
@onready var approach_l_path : Path3D = get_node(approach_path_l_np)
@export_node_path("Path3D") var approach_path_r_np : NodePath
@onready var approach_r_path : Path3D = get_node(approach_path_r_np)
@export_node_path("Timer") var spawn_timer_np : NodePath
@onready var spawn_timer : Timer = get_node(spawn_timer_np)
@export_node_path("Marker3D") var player_pointer_np : NodePath
@onready var player_pointer : Marker3D = get_node(player_pointer_np)
@export_node_path("Marker3D") var plane_limit_np : NodePath
@onready var plane_limit : Marker3D = get_node(plane_limit_np)
@export_node_path("LiveDemoEntity") var live_demo_np : NodePath
@onready var live_demo = get_node(live_demo_np)

var spawn_limit : Marker3D
var my_parms : Dictionary = {}

func _ready() -> void:
	cleanup_planes()
	Messenger.return_to_start.connect(cleanup_planes)
	Messenger.level_started.connect(_on_level_started)
	Messenger.return_to_start.connect(_on_return_to_start)

func _on_return_to_start() -> void :
	spawn_timer.stop()	
	cleanup_planes()
	
	
	
func cleanup_planes() -> void:
	for t in get_children():
		if t is CosmicCruiser: 
			t.queue_free()
		
		
func _on_level_started(_level : int) -> void:
	my_parms = GameVariables.get_my_parms(self.name)

	spawn_timer.wait_time = my_parms["rate"] + \
		live_demo.randf_range(0, my_parms["rate_range"])
	spawn_timer.start()	

func spawn_plane_in_game() -> void :
	if GlobalUtils.player.position.x > plane_limit.position.x or \
	   GlobalUtils.player.position.y < plane_limit.position.y:
		return 

	var p_template
	var e_r
	if live_demo.randf() >= 0.5:
		p_template = approach_r_path
		e_r = Vector3.LEFT
	else:
		p_template = approach_l_path
		e_r = Vector3.RIGHT
	var path: Path3D  = p_template.duplicate()
	add_child(path)
	var spawn_p : Dictionary = {"parms" : {}, "parent": path.get_node("way_in")}
	path.position = GlobalUtils.player.position - player_pointer.position
	spawn_p["parms"]["name"] = GlobalUtils.build_unique_name("Plane")
	spawn_p["parms"]["escape_route"] = e_r

	var new_plane : CosmicCruiser = plane_scene.instantiate()
	new_plane._init_me(spawn_p)
	Logger.debug("Spawning a Cosmic Cruiser")





func _on_spawn_timer_timeout() -> void:
	var count = get_tree().get_node_count_in_group("enemy_planes")
	if  count < my_parms["limit"]:
		spawn_timer.wait_time = my_parms["rate"] + \
			live_demo.randf_range(0, my_parms["rate_range"])
		spawn_plane_in_game()
	else:
		# we keep the timer running to check if some tanks have been destroyed 
		# so we can create new ones
		#spawn_timer.stop()
		pass	
	
