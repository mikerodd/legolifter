class_name PostOffice extends Node3D


@onready var timer: Timer = $Timer
@onready var base_path = %PathTemplate
@onready var way_in = %WayIn
@onready var saved_sound: AudioStreamPlayer3D = %SavedSound

@export var hostage_scene : PackedScene

func _ready() -> void:
	Messenger.release_hostages.connect(release_hostages)
	Messenger.return_to_start.connect(cleanup_hostages)
	Messenger.hostage_is_saved.connect(_on_hostage_is_saved)

func _on_hostage_is_saved() -> void:
	saved_sound.play()
	
	
func release_hostages() -> void:
	timer.start()

func cleanup_hostages() -> void:
	timer.stop()
	for p in way_in.get_children():
		if p != base_path:
		#if p.name != "PathTemplate":
			p.queue_free()

func _on_timer_timeout() -> void:
	if GlobalUtils.player.is_landed():
		var pf: PathFollow3D  = base_path.duplicate()
		pf.name = LiveDemo.build_unique_name("HostagePath")
		way_in.add_child(pf)
		var h : Hostage = hostage_scene.instantiate()
		h._init_me(
				{ "parms": {
						"@where_from" : "heli",
						"#do_initiate" : var_to_str(["NewSPMIA"])
					}, 
				"parent" : pf
				})
		GameVariables.heli_count -= 1
		GameVariables.out_count += 1
		if GameVariables.heli_count == 0:
			timer.stop()
	else:
		timer.stop()
