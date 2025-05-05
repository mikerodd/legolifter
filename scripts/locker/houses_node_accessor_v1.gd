class_name HousesNodeAccessorV1
extends LokStorageAccessorVersion



func _retrieve_data(deps: Dictionary) -> Dictionary:
	var houses_node: Node = deps.get("houses_node")
	var ret : Dictionary = {"houses" : []}
	var smp_loader = LoadSaveSMP.new()
	ret["house_count"] = houses_node.house_count
	
	for house in houses_node.get_children():
		if house is House:
			var hparms = {"hostages": []}
			hparms["name"] = house.name
			hparms["position"] = var_to_str(house.position)
			hparms["current_hostage_count"] = house.current_hostage_count
			hparms["is_destroyed"] = house.is_destroyed
			hparms["timer_is_stopped"] = house.hostage_timer.is_stopped()
			for p : PathFollow3D in house.way_out.get_children():
				if p != house.base_path:
					var host_parms: Dictionary = {}
					host_parms["@progress_ratio"] = p.progress_ratio
					assert(p.get_child(0) is Hostage, "Error in PathFollow3D: %s child 0 is not a Hostage" % [p.name])
					var host : Hostage = p.get_child(0) 
					host_parms["@where_from"] = "house"
					host_parms["global_position"] = var_to_str(host.global_position)
					host_parms["global_rotation"] = var_to_str(host.global_rotation)
					host_parms["top_level"] = host.top_level
					host_parms["@smp_ia"] = \
							smp_loader._retrieve_data(host.smp_ia)
					hparms["hostages"].append(host_parms)
			ret["houses"].append(hparms)
	return ret
	
	
	
	
func _consume_data(res: Dictionary, deps: Dictionary) -> void:
	var parms = res.data
	var houses_node: Node = deps.get("houses_node")
	houses_node.house_count = 	parms["house_count"] 
	await houses_node.cleanup_houses()
	for hparms in parms["houses"]:
		var spawn_p : Dictionary = {"parms" : hparms, "parent": houses_node}
		var house : House = houses_node.house_scene.instantiate()
		house._init_me(spawn_p)
		for hos_parms in  hparms["hostages"]:
			var pf: PathFollow3D  = house.create_path_for_hostage()
			pf.progress_ratio = hos_parms["@progress_ratio"]
			var h : Hostage = house.hostage_scene.instantiate()
			h._init_me({"parms" : hos_parms, "parent" : pf})
			
			

		
		
