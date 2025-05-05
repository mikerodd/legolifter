class_name CameraAccessorV1
extends LokStorageAccessorVersion


func _retrieve_data(deps: Dictionary) -> Dictionary:
	var game_camera: Node = deps.get("game_camera")
	var ret : Dictionary = {}
	ret["position"] = var_to_str(game_camera.position)
	ret["@test"] = 42
	return ret
	
	
func _consume_data(res: Dictionary, deps: Dictionary) -> void:
	var game_camera: Node = deps.get("game_camera")
	var parms = res.data
	game_camera.position = 	str_to_var(parms["position"])
		
