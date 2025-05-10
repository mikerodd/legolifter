class_name CosmicCruiser extends Actor

@warning_ignore("unused_signal")
signal destroy 

@export var shell1_scene : PackedScene
@export_node_path("Node3D") var plane_model_np : NodePath
@onready var plane_model : Node3D = get_node(plane_model_np)
@export_node_path("LegoDestroyer") var destroyer_np : NodePath
@onready var destroyer : LegoDestroyer = get_node(destroyer_np)
@export_node_path("Node") var smp_ia_np : NodePath
@onready var smp_ia = get_node(smp_ia_np)
@export_node_path("Marker3D") var missile_l_orig_np : NodePath
@onready var missile_l_orig = get_node(missile_l_orig_np)
@export_node_path("Marker3D") var missile_r_orig_np : NodePath
@onready var missile_r_orig = get_node(missile_r_orig_np)

var is_dead : bool = false
var pf : PathFollow3D
var approach_tw : Tween
var escape_route : Vector3
var from_left : bool

	


func _init_me(spawn_p: Dictionary) -> void:
	super._init_me(spawn_p)   # initialize standard parms & put in the tree
	rotate_y(-PI/2)
	pf = get_parent()
	smp_ia.start()


func _physics_process(delta: float) -> void:
	if is_dead: return
	match smp_ia.get_current():
		"Destroyed":
			velocity += Vector3.DOWN * 0.2

		"Escape":
			velocity += (Vector3.UP * 1.5 + escape_route) * 0.2
			self.rotate_z(PI/3 * delta)
			if position.y > 18 : # i'm out of scope
				get_parent().get_parent().queue_free()
					
	
	manage_collisions(delta)

func _on_smp_ia_transited(from: Variant, to: Variant) -> void:
	Logger.debug("Cosmic cruiser transiting from %s to %s" % [from, to])
	if to == "Approaching":
		if pf:
			approach_tw = create_tween()
			approach_tw.tween_property(pf, "progress_ratio", 1, 3)\
				 .set_trans(Tween.TRANS_LINEAR)
			approach_tw.finished.connect(_on_path_finished)
	if to == "Firing":
		velocity = escape_route * 15
		fire_rocket()
	
func manage_collisions(delta : float) -> void:
	var c_obj = move_and_collide(velocity * delta)
	if c_obj:
		var c = c_obj.get_collider() 
		if not c is Missile1:
			plane_model.visible = false
			destroyer.destroy()	
			smp_ia.set_trigger("to_ground")
			for s in c.get_signal_list():
				if s.name == "destroy":
					c.destroy.emit()
					break

func _on_path_finished() -> void: 
	Logger.debug("If finished my path")
	smp_ia.set_trigger("to_fire")
	
func fire_rocket():
	var my_collision_layer = GlobalUtils.get_my_layer(self)
	Missile1.spawn(shell1_scene, missile_l_orig, GameVariables.ENEMY_SHELLS_LAYER,my_collision_layer)
	Missile1.spawn(shell1_scene, missile_r_orig, GameVariables.ENEMY_SHELLS_LAYER,my_collision_layer)
		
func _on_lego_destroyer_destroy_begin() -> void:
	plane_model.visible = false
	
func _on_lego_destroyer_destroy_end() -> void:
	get_parent().get_parent().queue_free()
	
func _on_destroy() -> void:
	smp_ia.set_trigger("to_destroyed")
	if smp_ia.get_current() == "Approaching":
		approach_tw.kill()
		var p : Path3D = pf.get_parent()
		var p1:Vector3 = p.curve.sample_baked(pf.progress)
		var p2:Vector3 = p.curve.sample_baked(pf.progress + 0.1)
		 
		velocity = (p2 - p1).normalized() * 10
		Logger.debug("Initial velocity : ")
		GlobalUtils.logger_debug_vector3(velocity)
