class_name LegoTank extends Actor


signal destroy 

@export_file var explo_path:String 
@export_file var shell_path:String
@export var align_off: float = PI/10

@export var speed: float
@export var safe_distance: float
@onready var smp_ia = $StateMachinePlayer
@onready var turret_model: Node3D = $TankMover/tank_tiger_turret
@onready var cannon_model: Node3D = $TankMover/tank_tiger_turret/CanonRotator/tank_tiger_cannon
@onready var tank_model : Node3D = $TankMover/tank_tiger
@onready var player_pointer: Node3D = $PlayerPointer
@onready var cannon_rotator: Node3D = $TankMover/tank_tiger_turret/CanonRotator
@onready var cannon_muzzle = $TankMover/tank_tiger_turret/CanonRotator/CanonMuzzle
@onready var tank_mover = $TankMover
@onready var live_demo = $LiveDemoEntity



var is_dead : bool = false 

var wait_delay: float = 0    # current wait 
var wait_finished: float = 0    #wait limit when proba will be tested
var right_limit: float  # limit on the right the tank cannot pass
var intel: Dictionary   # my IA parameters


func _init_me(spawn_p: Dictionary) -> void:
	super._init_me(spawn_p)   # initialize standard parms & put in the tree
	turret_model.rotate_y(PI/2)


func _physics_process(delta: float) -> void:
	if is_dead: return
	wait_delay += delta
	if GlobalUtils.player:
		if GlobalUtils.player.is_dead:
			return
	if position.x > right_limit: position.x = right_limit
	
	#horrible hack...
	if position.y < 0 : destroy.emit()	
	match smp_ia.get_current():
		"GetClose":
			if GlobalUtils.player.position.x - self.position.x > 15:
				tank_mover.move_forward()
				velocity = Vector3.RIGHT * speed
				move_and_collide(velocity * delta)
			elif GlobalUtils.player.position.x - self.position.x < - 15:
				tank_mover.move_backward()
				velocity = Vector3.LEFT * speed
				move_and_collide(velocity * delta)
			else:
				Logger.debug("Tank is close enought now...")
				smp_ia.set_trigger("begin_scan")
		
		"Scanning":
			turret_model.rotation.y -= PI/5 * delta
			if wait_delay > wait_finished:
				if live_demo.randf() < intel.Scanning.proba:
					smp_ia.set_trigger("found_target")
				else: 
					Logger.debug("Didn't detect the target...")
					wait_delay = 0
					compute_wait("Scanning")

		"TargetFound":
			point_at_player(delta)
			if wait_delay > wait_finished:
				smp_ia.set_trigger("hunt_target")

		"HuntTarget":
			point_at_player(delta)
			if wait_delay > wait_finished:
				if live_demo.randf() < intel.HuntTarget.proba:
					Logger.debug("I lost my target...")
					smp_ia.set_trigger("lost_target")
				else:
					wait_delay = 0
					compute_wait("HuntTarget")
							
			if GlobalUtils.player.position.x + safe_distance < self.position.x :
				tank_mover.move_backward()
				velocity = Vector3.LEFT * speed
			elif GlobalUtils.player.position.x - safe_distance > self.position.x :
				tank_mover.move_forward() 
				velocity = Vector3.RIGHT * speed
			else:
				smp_ia.set_trigger("fire_target")
				
			var _col = move_and_collide(velocity * delta)
		
		"FireAtTarget":
			Logger.debug("Fire! Fire! Fire!")
			tank_mover.move_stop()
			velocity = Vector3.ZERO
			var shell: Shell1 = load(shell_path).instantiate()
			shell.transform = cannon_muzzle.global_transform
			shell.speed *= 1.1   # small correction
			owner.add_child(shell)
			wait_delay = 0

		"Reload":
			if wait_delay > wait_finished:
				smp_ia.set_trigger("resume_hunt")

func point_at_player(delta):
	var estimaged_position = GlobalUtils.player.global_position + Vector3(0,1,0)
	player_pointer.look_at(estimaged_position,Vector3.UP)
	if turret_model.rotation.y > player_pointer.rotation.y + PI + align_off:
		turret_model.rotation.y -= PI/5 * delta
	elif 	turret_model.rotation.y < player_pointer.rotation.y + PI - align_off:
		turret_model.rotation.y += PI/5 * delta
	else:
		smp_ia.set_trigger("turret_aligned")
	player_pointer.rotate_x(PI)
	if cannon_rotator.rotation.x > player_pointer.rotation.x :
		cannon_rotator.rotation.x -= PI/5 * delta
	elif cannon_rotator.rotation.x < player_pointer.rotation.x :
		cannon_rotator.rotation.x += PI/5 * delta

 
func compute_wait(cur_state) -> float:
	if intel.has(cur_state):
		var tmp_range = live_demo.randf_range(0, intel[cur_state].wait_range)
		return live_demo.randf_range(intel[cur_state].wait - tmp_range, intel[cur_state].wait + tmp_range)
	else: 
		return 0		

func _on_fsm_ia_transited(from: Variant, to: Variant) -> void:
	Logger.debug("IA Tank from: " + from + " to: " + to)
	wait_delay = 0  
	wait_finished = compute_wait(to)
	if to == "Scanning":
		tank_mover.move_stop()
	if to == "TargetFound":
		Logger.debug("Found my target!")

func activate():
	smp_ia.set_param("is_parked",false)  # Go !

func parking():
	smp_ia.set_param("is_parked",true)  # Go !
	
func _on_state_machine_player_entered(to: Variant) -> void:
	Logger.debug("Entered in :" + to )


func _on_lego_destroyer_destroy_begin() -> void:
	is_dead = true
	turret_model.visible = false 
	cannon_model.visible = false 
	tank_model.visible = false



func _on_lego_destroyer_destroy_end() -> void:
	await get_tree().create_timer(2).timeout
	queue_free()	
