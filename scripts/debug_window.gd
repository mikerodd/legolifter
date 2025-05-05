extends Window

var game: Game 


func _ready() -> void:
	self.title = "Debug"
	if get_parent() is Game:
		Logger.debug("My parent is game !")
		game = get_parent()

func _on_add_tank_pressed() -> void:
	game.tanks_node.spawn_tank_in_game()

func _on_killme_pressed() -> void:
	Logger.debug("Kill player !")
	GlobalUtils.player.destroy.emit()




func _on_destroy_houses_pressed() -> void:
	for h in get_tree().get_nodes_in_group("houses"):
		h.emit_signal("destroy")
	


func _on_add_plane_pressed() -> void:
	game.planes_node.spawn_plane()



func _on_map_messages_pressed() -> void:
	Messenger.display_signal_mapping()

	
