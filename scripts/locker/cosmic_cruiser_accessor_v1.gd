class_name CosmicCruiserAccessorV1
extends LokStorageAccessorVersion


func _retrieve_data(deps: Dictionary) -> Dictionary:
	var game_camera: Node = deps.get("game_camera")
	var ret : Dictionary = {}
	return ret
	
	
func _consume_data(res: Dictionary, deps: Dictionary) -> void:
	var game_camera: Node = deps.get("game_camera")
	var parms = res.data
	game_camera.position = 	str_to_var(parms["position"])
		
