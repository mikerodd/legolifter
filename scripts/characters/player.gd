class_name Player extends Actor

@warning_ignore("unused_signal")
signal destroy



@export_node_path("Node") var lego_destroyer_np
@onready var lego_destroyer : LegoDestroyer = get_node(lego_destroyer_np)

@onready var flying_smp = %FlyingSMP
@onready var rotating_smp = %RotatingSMP
@onready var model_rotator = %ModelRotator
@onready var model = %HelicopterModel
@onready var model_anim: AnimationPlayer = %HelicopterModel/AnimationPlayer
@onready var shell_orig = %MissileOrig
@onready var fire_rate_timer: Timer = %FireRateTimer
@onready var coli_shape:CollisionShape3D = %NewHeliColisionShape
@onready var rotor_sound = %RotorSound
@onready var onboard_hostage_sound = %OnbardHostageSound
@onready var falling_sound =%FallingSound
@onready var lightmap_gi = %LightmapGI

## Delay time between to rotation requests
@export var time_to_rotate:float 

## Top speed of the helicopter
@export var speed: float

## duration of the helicopter rotation
@export var rotation_duration: float

## path for the shell scene
@export var shell1_scene:PackedScene

## x position for the missile when helicopter is in side position 
@export var x_shell_position_side: float  = -2.562

## x position for the missile when helicopter is in front position
@export var x_shell_position_front: float = 0



var elapsed_rotate: float = 0 
var land_altitude: float # altitude where the helicopter should touch ground
var can_fire: bool = true
var can_play: bool = false 
var passenger_count: int  = 0;
var my_collision_layer :int 
var limit_right : Vector3
var limit_left : Vector3 
var limit_up : Vector3 

var physics_frame_begin : int =0
var drawn_frame_begin : int = 0
var process_frame_begin: int = 0 
var fly_rotate_z_tween: Tween
var velo_damper: float  = 0
var velo_tween: Tween
var before_velo: Vector3


func _ready() -> void:
	flying_smp.transited.connect(self._debug_fly)
	rotating_smp.transited.connect(self._debug_rotate)
	physics_frame_begin = Engine.get_physics_frames()
	drawn_frame_begin  = Engine.get_frames_drawn()
	process_frame_begin = Engine.get_process_frames()



	
func _init_me(spawn_p: Dictionary) -> void:
	super._init_me(spawn_p)
	model_anim.set_speed_scale(spawn_p["parms"]["@speed_scale"])
	model_anim.play("rotor")
	my_collision_layer = GlobalUtils.get_my_layer(self)
	if can_play: 
		rotor_sound.pitch_scale = 0.7
		rotor_sound.play() 
	if GameVariables.use_lightmap:
		lightmap_gi.visible = true
	else:
		lightmap_gi.visible = false


var tw_dict : Dictionary = {
	"move_up": null,
	"move_down": null,
	"move_left": null,
	"move_right": null,
}
var tw_up : Tween = null

func compute_move_value(act : String, no_damp: bool = false):
	if no_damp or self.position.y < 0.3: 
		if LiveDemo.is_action_pressed(act):
			self.set(act, 1)
		else:
			self.set(act, 0)
	else:
		var dampening = 0.25
		var trans = Tween.TRANS_EXPO
		if LiveDemo.is_action_just_pressed(act):
			tw_dict[act] = create_tween()
			tw_dict[act].tween_property(self, act, 1,dampening)\
					.set_trans(trans)\
					.set_ease(Tween.EASE_OUT)
		if LiveDemo.is_action_pressed(act):
			pass # let the tween
		else:
			if  tw_dict[act] == null:
				tw_dict[act] = create_tween()
				tw_dict[act].tween_property(self, act, 0, dampening)\
						.set_trans(trans)\
						.set_ease(Tween.EASE_OUT)
			else:
				if not tw_dict[act].is_running():
					tw_dict[act] = null
		


var move_up : float
var move_down : float
var move_left : float
var move_right : float

	
func _physics_process(_delta: float) -> void:
	if not can_play:
		return
	elapsed_rotate += _delta      # manage elapsed rotation

	var p  = coli_shape.position
	coli_shape.transform = Transform3D(model.global_basis, model.global_position)
	coli_shape.position = p

	match flying_smp.get_current():
		"Landed":
			compute_move_value("move_up", true)
			if LiveDemo.is_action_pressed("move_up"): 
				flying_smp.set_trigger("move_up")
				var tw : Tween = create_tween().set_parallel()
				tw.tween_property(model_anim,"speed_scale",1.5,1)
				tw.tween_property(rotor_sound,"pitch_scale",1,1)
			
		"OnFly":
			compute_move_value("move_up") # 1 if LiveDemo.is_action_pressed("move_up") else 0
			compute_move_value("move_down") # move_down = 1 if LiveDemo.is_action_pressed("move_down") else 0
			compute_move_value("move_left") # move_left = 1 if LiveDemo.is_action_pressed("move_left") else 0
			compute_move_value("move_right")  #move_right = 1 if LiveDemo.is_action_pressed("move_right") else 0
			var action = 1 if LiveDemo.is_action_pressed("fire") else 0
			var rotate_left = 1 if LiveDemo.is_action_pressed("rotate_left") else 0
			var rotate_right = 1 if LiveDemo.is_action_pressed("rotate_right") else 0
			if position.x < limit_left.x: 
				move_left = 0
			if position.x > limit_right.x:
				move_right = 0
			if position.y > limit_up.y:
				move_up = 0
			velocity = move_up * Vector3.UP *  speed  + move_down * Vector3.DOWN * speed 
			velocity += move_left * Vector3.LEFT * speed  + move_right * Vector3.RIGHT * speed
			manage_collisions(move_and_collide(velocity * _delta,false,0.01, true))
			if action and can_fire:
				fire_rocket()

			if LiveDemo.is_action_just_pressed("move_left"):
				if fly_rotate_z_tween: fly_rotate_z_tween.kill()
				fly_rotate_z_tween = create_tween()
				fly_rotate_z_tween.tween_property(model_rotator, "rotation:z", PI/16, rotation_duration)
			elif LiveDemo.is_action_just_pressed("move_right"):
				if fly_rotate_z_tween: fly_rotate_z_tween.kill()
				fly_rotate_z_tween = create_tween()
				fly_rotate_z_tween.tween_property(model_rotator, "rotation:z", -PI/16, rotation_duration)
			elif move_right == 0 and move_left == 0:
				create_tween().tween_property(model_rotator, "rotation:z", 0, rotation_duration)

			if elapsed_rotate > time_to_rotate:
				elapsed_rotate = 0
				match rotating_smp.get_current():
					"FacingLeft":
						if  rotate_right == 1: #and action == 1 :
							rotating_smp.set_trigger("left_front")
							create_tween().tween_property(model, "rotation:y", PI/2, rotation_duration)

					"FacingFront":
						if  rotate_right == 1: # and action == 1:
							rotating_smp.set_trigger("front_right")
							create_tween().tween_property(model, "rotation:y", PI, rotation_duration)
						if rotate_left == 1: # and action == 1:
							rotating_smp.set_trigger("front_left")
							create_tween().tween_property(model, "rotation:y", 0, rotation_duration)

					"FacingRight":
						if rotate_left == 1: # and action == 1:
							rotating_smp.set_trigger("right_front")
							create_tween().tween_property(model, "rotation:y", PI/2, rotation_duration)

		"Landing":
			if fly_rotate_z_tween: fly_rotate_z_tween.kill()
			var tw : Tween = create_tween().set_parallel()
			tw.tween_property(model_anim,"speed_scale", 0.5, 1)
			tw.tween_property(rotor_sound,"pitch_scale",0.7,1)
			tw.tween_property(model_rotator, "rotation:z", 0, 0.2)
			tw.tween_property(self,"position:y",0.0,0.4)
			flying_smp.set_trigger("landed")

		"Destroyed":
			velocity += Vector3.DOWN * 0.2
			self.rotate(Vector3.UP, LiveDemo.randf_range(self, -2, 3) * _delta)
			self.rotate(Vector3.LEFT, LiveDemo.randf_range(self, -2, 3) * _delta)
			var c_obj = move_and_collide(velocity * _delta)
			if c_obj:
				if not c_obj.get_collider() is Missile1:
					model.visible = false
					lego_destroyer.destroy()


func manage_collisions(col: KinematicCollision3D) -> void:
	if col:
		var _t = col.get_collider()
		if _t.name == "floor":
			flying_smp.set_trigger("landing")
		elif _t.name == "landing_area":
			flying_smp.set_trigger("landing")
			if GameVariables.heli_count > 0:
				Logger.debug("release hostages to the post office")
				Messenger.release_hostages.emit()
		else:
			if _t is Actor:
				if _t.is_dead:
					return 
			for s in _t.get_signal_list():
				if s.name == "destroy": 
					_t.destroy.emit()
					self.destroy.emit()
					Logger.debug("Heli collisation detected : " + _t.name)


func _debug_fly(from, to):
	Logger.trace("Fly transited from : " + from + " to " + to)


func _debug_rotate(from, to):
	Logger.trace("Rotate transited from : " + from + " to " + to)


func fire_rocket():
	can_fire = false
	fire_rate_timer.start()
	Missile1.spawn(shell1_scene, shell_orig, GameVariables.PLAYER_MISSILES_LAYER, my_collision_layer)


func _on_rotating_smp_transited(from: Variant, to: Variant) -> void:
	if to == "FacingFront":
		shell_orig.rotate(Vector3.FORWARD,-PI/2)

	if from == "FacingFront" and (to == "FacingLeft" or to == "FacingRight"):
		shell_orig.rotate(Vector3.FORWARD,PI/2)
		
		
func add_passenger():
	onboard_hostage_sound.play()
	GameVariables.out_count -= 1
	GameVariables.heli_count += 1
	Logger.trace("We have another passenger !  total : " + str(passenger_count))
func is_landed() -> bool:
	if flying_smp.get_current() == "Landed": return true
	else:return false

func has_room_for_hostage() -> bool:
	return (GameVariables.heli_count < GameVariables.max_hostage_onboard )



func _on_fire_rate_timer_timeout() -> void:
	can_fire = true

func _on_destroy() -> void:
	if is_dead: return 
	is_dead = true
	rotor_sound.stop()
	falling_sound.play()
	create_tween().tween_property(model_anim,"speed_scale", 0, 2)
	Logger.debug("I'm destroyed !")
	flying_smp.set_trigger("is_destroyed")


func _on_lego_destroyer_destroy_begin() -> void:
		falling_sound.stop()


func _on_lego_destroyer_destroy_end() -> void:
	Logger.debug("score at destroyed : dead_count:%d  heli_count:%d " % [GameVariables.dead_count, GameVariables.heli_count])
	GameVariables.heli_lives -= 1
	GameVariables.dead_count += GameVariables.heli_count
	GameVariables.heli_count = 0

	if GameVariables.check_end_level() \
			and GameVariables.heli_lives > 0:
		Messenger.level_complete.emit()
	if GameVariables.heli_lives > 0:
		Messenger.return_to_base.emit()
	else:
		var rank : int = GameVariables.rank_score_in_hall_of_fame() 
		if rank != 0:
			var sc: Dictionary = {"rank"= rank, "score" = GameVariables.score}
			Messenger.ui_new_high_score.emit(sc)
		else:
			Messenger.return_to_start.emit()
