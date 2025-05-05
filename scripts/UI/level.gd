extends UILifterElement

var ui_hide_position: float = 0.0
var ui_show_position: float = 187

@export var displayed_seconds : float
@export_node_path("Label") var level_label_np
@onready var level_label : Label = get_node(level_label_np)

func _ready() -> void:
	Messenger.ui_show_level.connect(_show_me)


func _show_me(_darken : bool = false ) -> void :
	level_label.text = str(int(GameVariables.current_level + 1))
	get_tree().create_timer(displayed_seconds).timeout.connect(func() : _hide_me())
	super._show_me()
