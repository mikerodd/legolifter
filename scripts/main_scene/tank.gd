class_name Tank extends Actor

@warning_ignore("unused_signal")
signal destroy 


@export_file var explo_path:String 
@export_file var shell_path:String
@export var align_off: float = PI/10

@export var speed: float
@export var safe_distance: float
@export var shoot_delay: float = 1
@onready var smp_ia = $StateMachinePlayer
@onready var turret_model: Node3D = $tank_mover/tank1_turret
@onready var player_pointer: Node3D = $player_pointer
@onready var cannon_rotator: Node3D = $tank_mover/tank1_turret/cannon_rotator
@onready var tank_mover = $tank_mover
@onready var live_demo = $LiveDemoEntity



var wait_delay: float = 0    # current wait 
var wait_finished: float = 0    #wait limit when proba will be tested
var intel = {
	Scanning =    { wait = 3, wait_range = 2, proba = 1 },
	TargetFound = { wait = 2, wait_range = 1 },
	HuntTarget =  { wait = 5, wait_range = 1, proba = 1 },
	Reload =      { wait = 1, wait_range = 0.5 }
}


func _ready() -> void:
	turret_model.rotate_y(PI/2)
	owner = get_tree().get_root()  


func _physics_process(delta: float) -> void:
	wait_delay += delta
	if GlobalUtils.player:
		if GlobalUtils.player.is_dead:
			smp_ia.set_param("is_parked", true)
	
	match smp_ia.get_current():
		"Scanning":
			turret_model.rotation.y -= PI/5 * delta
			if wait_delay > wait_finished:
				if LiveDemo.randf(self) < intel.Scanning.proba:
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
				if LiveDemo.randf(self) < intel.HuntTarget.proba:
					Logger.debug("I lost my target...")
					smp_ia.set_trigger("lost_target")
				else:
					wait_delay = 0
					compute_wait("HuntTarget")
							
			if GlobalUtils.player.position.x + safe_distance < self.position.x :
				tank_mover.move_backward()
				velocity = Vector3.LEFT 
				 #position += velocity
			elif GlobalUtils.player.position.x - safe_distance > self.position.x :
				tank_mover.move_forward()
				velocity = Vector3.RIGHT 
				#position += velocity
			else:
				smp_ia.set_trigger("fire_target")
				
			var col = move_and_collide(velocity * delta)
			if col:
				pass
				#Logger.debug("Tank collided with " + col.get_collider().name)
		"FireAtTarget":
			Logger.debug("Fire! Fire! Fire!")
			tank_mover.move_stop()
			velocity = Vector3.ZERO
			var shell: Shell1 = load(shell_path).instantiate()
			shell.transform = $tank_mover/tank1_turret/cannon_rotator/cannon_muzzle.global_transform
			owner.add_child(shell)
			wait_delay = 0

		"Reload":
			if wait_delay > wait_finished:
				smp_ia.set_trigger("resume_scan")
			

func point_at_player(delta):
	player_pointer.look_at(GlobalUtils.player.global_position,Vector3.UP)
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
		var tmp_range = LiveDemo.randf_range(self, 0, intel[cur_state].wait_range)
		return LiveDemo.randf_range(self, intel[cur_state].wait - tmp_range, intel[cur_state].wait + tmp_range)
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


func parking():
	smp_ia.set_param("is_parked",true)  
	
