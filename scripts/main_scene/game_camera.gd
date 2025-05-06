extends Camera3D
@export_node_path("Marker3D") var start_position_np
@onready var start_position : Marker3D = get_node(start_position_np)

var  offset: float = 0.1

func _ready() -> void:
	init_camera()
	Messenger.return_to_start.connect(init_camera)
	GlobalUtils.game_camera = self

func init_camera() -> void:
	position.x = start_position.position.x

func _process(delta: float) -> void:
	if GlobalUtils.player:
		var px:float = GlobalUtils.player.position.x
		if position.x < px - offset:
			position.x += GlobalUtils.player.speed * abs(px - position.x) * delta / 10
		elif position.x > px + offset:
			position.x -= GlobalUtils.player.speed * abs(px - position.x ) * delta / 10
