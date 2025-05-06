class_name Shell1 extends CharacterBody3D


@warning_ignore("unused_signal")
signal destroy

var speed: float = 12

var missile_direction: Vector3 
@onready var explode:GPUParticles3D = $Explode
@onready var shell = $shell1



func _ready() -> void:
		velocity = transform.basis.z.normalized() * speed
		Logger.debug("ready velocity (" + str(velocity.x) + ", " + str(velocity.y) + ", " + str(velocity.z) + ")")
		Logger.debug("I'm an enemy shell !")

func _physics_process(delta: float) -> void:
	var c: KinematicCollision3D
	if shell.visible == false:
		return

	velocity += Vector3.DOWN * 0.2  #+ missile_direction * speed.
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	c = move_and_collide(velocity * delta)

	if c:
		var c_obj = c.get_collider()
		if c_obj is Player or c_obj is House:
			Logger.debug("Missile collided with the player/house...")
			destroy_me()
			for s in c_obj.get_signal_list():
				if s.name == "destroy":
					c_obj.destroy.emit()
		else:
			Logger.debug("Missile collided with something else : " + c_obj.name + " ... parent : " + c_obj.get_parent().name)
			destroy_me()

func destroy_me(show_explode: bool = true) -> void:
	if show_explode:
		var p = get_tree().get_root()
		explode.get_parent().remove_child(explode)
		p.add_child(explode)
		explode.global_transform = self.global_transform
		explode.emitting = true
	shell.visible = false
	queue_free()
