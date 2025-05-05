class_name GameAccessorV1
extends LokStorageAccessorVersion


func _retrieve_data(_deps: Dictionary) -> Dictionary:
	
	var ret : Dictionary = {}
	ret["saved_count"] = GameVariables.saved_count
	ret["out_count"] = GameVariables.out_count 
	ret["dead_count"]=  GameVariables.dead_count
	ret["detained_count"] = GameVariables.detained_count
	ret["heli_count"] = GameVariables.heli_count
	ret["current_level"] = GameVariables.current_level
	ret["heli_lives"] = GameVariables.heli_lives
	
	return ret
	
	
func _consume_data(res: Dictionary, _deps: Dictionary) -> void:
	var parms = res.data
	GameVariables.saved_count = parms["saved_count"] 
	GameVariables.out_count  = parms["out_count"]
	GameVariables.dead_count = parms["dead_count"]
	GameVariables.detained_count = parms["detained_count"]
	GameVariables.heli_count = parms["heli_count"]
	GameVariables.current_level = parms["current_level"]
	GameVariables.heli_lives = parms["heli_lives"]
		
