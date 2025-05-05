class_name ProbaComputer extends Node

@warning_ignore("unused_signal")
signal proba_initialize(parameters: Dictionary)

func _ready() -> void:
	add_to_group("enemy_to_initialize")
	
	



func _on_proba_initialize(parameters: Dictionary) -> void:
	Logger.debug("ProbaComputer, i'm goind to initialize, size of parametrs : " + str(parameters.size()))
	remove_from_group("enemy_to_initialize")
