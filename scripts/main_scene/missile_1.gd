class_name Missile1 extends CharacterBody3D

@warning_ignore("unused_signal")
signal destroy

@export var speed: float = 10

@onready var explode:GPUParticles3D = $Explode
@onready var shell = $missile2
@onready var collision_shape : CollisionShape3D = $CollisionShape3D

var missile_direction: Vector3 
var target_group: Array



func _ready() -> void:
	var t: Vector3 = self.global_basis.z
	missile_direction = t
	create_tween().tween_property(self,"speed",speed * 3, 0.5)

func _physics_process(delta: float) -> void:
	var c: KinematicCollision3D
	if shell.visible == false:
		return
		
	velocity = missile_direction * speed
	c = move_and_collide(velocity * delta)

	if c:
		var c_obj = c.get_collider()
		if c_obj is Player or c_obj is CosmicCruiser or c_obj is LegoTank or c_obj is House:
			Logger.debug("Missile collided with the player/cruiser/tank...")
			destroy_me(false)
			for s in c_obj.get_signal_list():
				if s.name == "destroy": 
					c_obj.destroy.emit()
					break
		else:
			Logger.debug("Missile collided with something else : " + c_obj.name + " ... parent : " + c_obj.get_parent().name)
			destroy_me()

func destroy_me(_show_explode: bool = true) -> void:
	if _show_explode:
		explode.emitting = true
	shell.visible = false
	queue_free()




static func spawn(missile_scene:PackedScene, orig: Node3D, my_layer:int, mask_to_remove: int ) -> void:
	var missile: CharacterBody3D = missile_scene.instantiate()
	Logger.debug(" Fire missile !")
	missile.set_as_top_level(true)
	var mytr:Transform3D  = Transform3D(orig.global_basis,orig.global_position)
	missile.transform = mytr
	orig.add_child(missile)	
	Logger.debug("missile is on layer %d" % my_layer)
	missile.set_collision_layer_value(my_layer,true)
	missile.set_collision_mask_value(mask_to_remove,false)
	pass
	
		
