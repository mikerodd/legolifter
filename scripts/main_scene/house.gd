class_name House extends Node3D 



@warning_ignore("unused_signal")
signal destroy


@onready var hostage_timer : Timer = $HostageTimer
@onready var base_path = $WayOut/BasePath
@onready var way_out = $WayOut
@onready var house_model = $house2
@onready var lightmap_gi = $LightmapGI

@export_node_path("LegoDestroyer") var destroyer_np
@onready var destroyer : LegoDestroyer = get_node(destroyer_np)


## The hostage scene to instantiate if i'm hit
@export var hostage_scene: PackedScene
@export var broken_model: PackedScene



## Number of hostage in a house
var current_hostage_count: int
const INTENSITY: float = 4
var is_destroyed: bool = false




func _init_me(spawn_p: Dictionary) -> void:
	for parm in spawn_p["parms"].keys():
		if spawn_p["parms"][parm] is String and str_to_var(spawn_p["parms"][parm]) != null:
			set(parm,str_to_var(spawn_p["parms"][parm]))
		else:
			set(parm,spawn_p["parms"][parm])
	spawn_p["parent"].add_child(self)
	owner = get_tree().get_root()  
	if spawn_p["parms"]["is_destroyed"]:
		destroy.emit(false)
	if spawn_p["parms"]["timer_is_stopped"]:
		hostage_timer.stop()
	else:
		hostage_timer.start()
	if GameVariables.use_lightmap:
		lightmap_gi.visible = true
	else:
		lightmap_gi.visible = false		

func create_path_for_hostage() -> PathFollow3D:
	var pf: PathFollow3D  = base_path.duplicate()
	pf.name = LiveDemo.build_unique_name("HostagePathFollow")
	way_out.add_child(pf)
	return pf	


func _on_timer_timeout() -> void:
	current_hostage_count -= 1
	Logger.debug("Release an hostage! ")
	var pf: PathFollow3D  = create_path_for_hostage()
	var h : Hostage = hostage_scene.instantiate()
	h._init_me({ 
				"parms": {
					"@where_from" : "house",
					"is_house_path_finished": false,
					"#do_initiate" : var_to_str(["NewSPMIA"])
				}, 
			"parent" : pf})
	GameVariables.detained_count -= 1
	GameVariables.out_count += 1
	if current_hostage_count == 0:
		hostage_timer.stop()


func _on_lego_destroyer_destroy_begin() -> void:
	is_destroyed = true
	house_model.queue_free()
	hostage_timer.start()
