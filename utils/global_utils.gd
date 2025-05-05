extends Node

const MOUSE_SENSITIVITY = 0.003
const MAX_VERTICAL_LOOK = 1.25
const  GRAVITY = 9.8

var give_intro_speech = true
var mouse_sensitivity:float = MOUSE_SENSITIVITY
var max_vertical_look: float = MAX_VERTICAL_LOOK
var random: RandomNumberGenerator = RandomNumberGenerator.new()

	

var player:Actor:
	get:
		return player
	set(p):
		Logger.debug("Player Set")
		player = p

var game_camera:Camera3D:
	get:
		return game_camera
	set(c):
		Logger.debug("Game carmera set")
		game_camera = c

func check_var_for_error(myvar, err_msg):
	if not myvar:
		push_error(err_msg)
		Logger.fatal(err_msg)
		#get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit(1)

func get_my_layer(obj : CollisionObject3D) -> int :
	for idx in range(32):
		if obj.get_collision_layer_value(idx + 1):
			return  idx + 1
	return 0	

func logger_debug_vector3(v: Vector3,n: String = "") -> void:
	Logger.debug("Vector " + n + ": (" + str(v.x) + ", " + str(v.y) + ", " + str(v.z) + ")")


var exluded_signals = [
	"child_order_changed",
	"item_rect_changed",
	"size_flags_changed",
	"minimum_size_changed",
	"visibility_changed",
	
	
]


func display_signal(n : Node, s: Dictionary, p_displayed: bool) -> bool:
	var ret_value = false
	var s_displayed = false 
	for d in n.get_signal_connection_list(s.name):
		var c:Callable = d.callable
		if not p_displayed: print("Signals for node %s" % n.name)
		if not s_displayed: 
			print("    Signal %s" % s.name)
			s_displayed = true
		var dis 
		if c.get_object() is Node:
			var n2: Node = c.get_object()
			dis = n2.get_path().get_concatenated_names()
		else:
			dis = c.get_object()
		print("   Connected to %s.%s" % [dis, c.get_method()])
		p_displayed = true 
		ret_value = p_displayed
	return ret_value
	



func display_signal_list(n: Node) -> void :
	var p_displayed : bool = false 
	for s in n.get_signal_list():
		p_displayed = display_signal(n, s, p_displayed)
	for children in n.get_children():
		display_signal_list(children)
	

func all_signals(root : Node) -> void:
	display_signal_list(root)
	
	

static var node_counter = 0
func build_unique_name(_name: String) -> String:
	node_counter +=1
	return _name + str(node_counter)
	
func reinit_unique_name() -> void:
	node_counter = 0
