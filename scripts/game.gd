extends Node3D

class_name Game


@export_file("*.json") var game_parameters_filename : String
@export_file("*.json") var user_parameters_filename : String

@onready var smp = %StateMachinePlayer
@onready var tanks_node = %TanksNode
@onready var planes_node = %CosmicsNode
@onready var game_camera: Camera3D = %GameCamera
@onready var demo_timer : Timer = %DemoTimer
@onready var music : AudioStreamPlayer = %Music


var debug_win = preload("uid://d3h0l73sf5pm4")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# popup the debug window
	#if OS.is_debug_build(): manage_debug_window()	

	# load game parameters
	GameVariables.game_parameters_filename = game_parameters_filename
	GameVariables.user_parameters_filename = user_parameters_filename
	GameVariables.load_parameters()

	# Signal connection
	Messenger.exit_game.connect(_on_exit_game)
	Messenger.play_game.connect(_on_play_game)
	Messenger.begin_game.connect(_on_begin_game)
	Messenger.return_to_start.connect(_on_return_to_start)
	Messenger.return_to_base.connect(_on_return_to_base)
	Messenger.level_complete.connect(_on_level_complete)
	LiveDemo.demo_finished.connect(_on_demo_finished)
	Messenger.demo_timer_authorized.connect(_on_demo_timer_authorized)
	Messenger.demo_timer_forbidden.connect(_on_demo_timer_forbidden)

	GameVariables.apply_user_parameters()

	Messenger.return_to_start.emit()
	
	#GlobalUtils.all_signals(Messenger)

func _on_begin_game() -> void:
	smp.set_trigger("to_begin_game")

func _on_exit_game() -> void:
	get_tree().quit()

func _on_play_game() -> void:
	smp.set_trigger("to_play")

func _on_level_complete() -> void:
	GameVariables.current_level += 1
	Messenger.level_started.emit(GameVariables.current_level)	
	smp.set_trigger("to_start_level")

func _on_return_to_base() -> void:
	smp.set_trigger("return_to_base")
	# will jump to list live and straight to play after
	

func _on_demo_finished() -> void:
	print("==> Demo is finished")
	Logger.debug("Demo is finished...")
	LiveDemo.current_active = "live"
	Messenger.return_to_start.emit()

func _on_demo_timer_authorized() -> void:
	demo_timer.start()
	
	
func _on_demo_timer_forbidden() -> void:
	demo_timer.stop()


func _init() -> void:
	Logger.set_logger_level(Logger.LOG_LEVEL_DEBUG)
	Logger.set_logger_format(Logger.LOG_FORMAT_DEFAULT)

func _on_smp_transited(_from: Variant, to: Variant) -> void:
	match to:
		"StartScreen":
			music.stop()
			AudioServer.set_bus_mute(0,false)  
			
			Messenger.ui_englight_display.emit()
			Messenger.demo_timer_authorized.emit()
		"BeginGame":
			GameVariables.init_scores()	
			Messenger.level_started.emit(GameVariables.current_level)

		"StartLevel":
			Messenger.ui_show_level.emit()

		"Play":
			if not music.playing: music.play()
			Messenger.demo_timer_forbidden.emit()
			LiveDemo.reinit_unique_name()
			LiveDemo.current_active = "live"
			Messenger.begin_play.emit()
			Messenger.update_scores.emit()

		"Record":
			GameVariables.init_scores()	
			Messenger.demo_timer_forbidden.emit()
			LiveDemo.reinit_unique_name()
			LiveDemo.current_active = "record"
			GameVariables.current_level = GameVariables.start_level
			LiveDemo.custom_params = {"current_level": GameVariables.current_level}
			Messenger.level_started.emit(GameVariables.current_level)
			Messenger.begin_play.emit()
			
		"DemoMode":
			GameVariables.init_scores()	
			LiveDemo.reinit_unique_name()
			LiveDemo.current_active = "demo"
			if LiveDemo.custom_params.has("current_level"):
				GameVariables.current_level = LiveDemo.custom_params["current_level"]
			Messenger.level_started.emit(GameVariables.current_level)
			Messenger.begin_play.emit()
			Messenger.ui_total_dark_display.emit()
			AudioServer.set_bus_mute(0,true)  
			await get_tree().create_timer(1).timeout
			Messenger.ui_englight_display.emit()
	
			
func manage_debug_window():
	get_viewport().set_embedding_subwindows(false)
	var d = debug_win.instantiate()	
	add_child(d)
	d.visible = true

func _unhandled_key_input(_event):
	# first of all, interrupt demo if a key is pressed
	if LiveDemo.current_active == "demo":
			LiveDemo.current_active = "live"
			Messenger.return_to_start.emit()		
			return 
	
	if Input.is_action_just_pressed("escape") and smp.get_current() == "Play":
			Messenger.ui_show_pause_buttons.emit()
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if Input.is_action_just_pressed("record"):
		if LiveDemo.current_active == "live":
			smp.set_trigger("to_record")
		elif LiveDemo.current_active == "record":
			LiveDemo.record_demo()
			LiveDemo.current_active = "live"
			Logger.debug("Recording demo is finished...")
			Messenger.return_to_start.emit()
			
	if Input.is_action_just_pressed("play_record"):
		smp.set_trigger("to_demo")
		



func _on_return_to_start() -> void:
	smp.set_trigger("to_startscreen")


func _on_demo_timer_timeout() -> void:
	smp.set_trigger("to_demo")
	
