class_name Hostage extends Actor

@onready var smp_ia = $NewSPMIA
@onready var anim: AnimationPlayer = $hostage/AnimationPlayer
@onready var live_demo : LiveDemoEntity = $LiveDemoEntity

var wait_delay: float = 0 
var wait_finished: float = 0
var speed: float = 2
var is_house_path_finished = false


func _physics_process(delta: float) -> void:
	wait_delay += delta
	match smp_ia.get_current():
			"Exiting":
				pass
				
			"Lost":
				if (GlobalUtils.player.is_landed() and 
						GlobalUtils.player.has_room_for_hostage()):
					smp_ia.set_trigger("found_helicopter")
				if wait_delay > wait_finished:
					if LiveDemo.randf(self) < 0.5:
						smp_ia.set_trigger("go_idle")
					else:
						wait_delay = 0
				else:
					if GlobalUtils.player.global_position.x > self.global_position.x:
						rotation.y = -PI/2
						self.global_position.x -= speed * delta
						velocity = speed * Vector3.LEFT 
					elif GlobalUtils.player.global_position.x < self.global_position.x:
						rotation.y = PI/2
						self.global_position.x += speed * delta
						velocity = speed * Vector3.RIGHT 			
				
			"ReachHelicopter":
				if wait_delay > wait_finished:
					if LiveDemo.randf(self) < 0.5 and not GlobalUtils.player.is_landed():
						smp_ia.set_trigger("lost_helicopter")
					else:
						wait_delay = 0
				else:
					if GlobalUtils.player.global_position.x < self.global_position.x:
						rotation.y = -PI/2
						self.global_position.x -= speed * delta
						velocity = speed * Vector3.LEFT 
					elif GlobalUtils.player.global_position.x > self.global_position.x:
						rotation.y = PI/2
						self.global_position.x += speed * delta
						velocity = speed * Vector3.RIGHT 
					if (abs(GlobalUtils.player.global_position.x - self.global_position.x) < 0.1
						 	and GlobalUtils.player.is_landed()
							and GlobalUtils.player.has_room_for_hostage()):
						GlobalUtils.player.add_passenger()
						get_parent().queue_free()
			"Idle":
				if wait_delay > wait_finished:
					if LiveDemo.randf(self) < 0.5:
						smp_ia.set_trigger("found_helicopter")
					else:
						smp_ia.set_trigger("really_lost")
			
			"Unload":
				if self.global_position.x >= get_parent().global_position.x:
					smp_ia.set_trigger("exit_reached")
				else:
					self.global_position.x += speed * delta
					velocity = speed * Vector3.LEFT
				


func _on_path_house_finished():
	Logger.debug("I finished the path")
	top_level = true
	rotation = Vector3(0, PI/2, 0)
	Logger.debug("end of path for hostage, status of player. Lander %s, room for hostage : %s " % [GlobalUtils.player.is_landed(), GlobalUtils.player.has_room_for_hostage()])
	if GlobalUtils.player.is_landed() and GlobalUtils.player.has_room_for_hostage():
		smp_ia.set_trigger("exit_reached")
	else: 
		smp_ia.set_trigger("really_lost")


func _on_path_post_office_finished():
	GameVariables.saved_count += 1
	GameVariables.out_count -= 1
	if GameVariables.check_end_level():
		Messenger.level_complete.emit()
	Logger.debug("I finished the path to the post office")
	get_parent().queue_free()


func _on_smp_ia_transited(_from: Variant, to: Variant) -> void:
	if to == "Exiting": 
		rotation.y = -PI/2
		anim.play("G_run",-1,3)
		
	if to == "Unload":

		anim.play("G_run",-1,3)
		
	if to == "ReachHelicopter":
		anim.play("G_run",-1,3)
		wait_delay = 0
		wait_finished = LiveDemo.randf_range(self, 1, 3)
		Logger.debug("Hostage is looking for the Helicopter...")

	if to == "Lost":
		anim.play("G_run",-1,3)
		wait_delay = 0
		wait_finished = LiveDemo.randf_range(self, 1, 3)
		Logger.debug("Hostage is completely lost...")

	if to == "ReachPostOffice":
		var tw:Tween = create_tween()
		tw.tween_property(get_parent(),"progress_ratio", 1, 2)
		tw.finished.connect(_on_path_post_office_finished)
		
	if to == "Idle":
		rotation.y = 0
		#anim.play("G_stand-idle")
		wait_delay = 0
		wait_finished = LiveDemo.randf_range(self, 1, 3)
		Logger.debug("Hostage is idling")


func _init_me(spawn_p: Dictionary) -> void:
	super._init_me(spawn_p)
	if not spawn_p["parms"].has("@where_from"):
		push_error("no @where_from parm in hostage")
	if spawn_p["parms"]["@where_from"] == "house":
		var tw:Tween = create_tween()
		smp_ia.set_trigger("exit_from_house")
		tw.tween_property(get_parent(),"progress_ratio", 1, 2)
		tw.finished.connect(_on_path_house_finished)
	elif spawn_p["parms"]["@where_from"] == "heli":
		smp_ia.set_trigger("exit_from_heli")
		global_position.x = GlobalUtils.player.global_position.x
		rotation.y = PI
	else:
		push_warning("non existent location for hostage, expecting house or heli found : %s " % spawn_p["@where_from"])
