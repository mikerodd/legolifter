class_name PostOfficeAccessorV1
extends LokStorageAccessorVersion


func _retrieve_data(deps: Dictionary) -> Dictionary:
	var way_in: Node = deps.get("post_office_way_in")
	var ret : Dictionary = {"hostages":[]}
	var smp_loader = LoadSaveSMP.new()
		
	for path : PathFollow3D in way_in.get_children():
		if path.name == "PathTemplate":
			continue
		if path.get_child_count() == 1:
			assert(path.get_child(0) is Hostage, "Error in PathFollow3D: %s child 0 is not a Hostage" % [path.name])

			var host_parms: Dictionary = {}
			var host : Hostage = path.get_child(0) 
			host_parms["@progress_ratio"] = path.progress_ratio
			host_parms["@where_from"] = "heli"
			host_parms["global_position"] = var_to_str(host.global_position)
			host_parms["global_rotation"] = var_to_str(host.global_rotation)
			host_parms["top_level"] = host.top_level
			host_parms["@smp_ia"] = smp_loader._retrieve_data(host.smp_ia)
			ret["hostages"].append(host_parms)
				
	return ret
	
	
func _consume_data(res: Dictionary, deps: Dictionary) -> void:
	pass
		
