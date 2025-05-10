class_name CosmicCruiserNodeAccessorV1
extends LokStorageAccessorVersion


func _retrieve_data(deps: Dictionary) -> Dictionary:
	var live_cruisers_parent = deps.get("live_cruisers_parent")
	var ret : Dictionary = {"cosmic_cruisers" : []}
	var smp_loader = LoadSaveSMP.new()
	
	
	for p in live_cruisers_parent.get_children():	
		if p is Path3D:
			var cparms : Dictionary = {}
			cparms["@path_position"] = var_to_str(p.position)
			for pf in p.get_children():
				if pf is PathFollow3D:
					cparms["@progress_ratio"] = pf.progress_ratio
					for cruiser in pf.get_children():
						if cruiser is CosmicCruiser:
							cparms["name"] = cruiser.name
							cparms["esccape_route"] = var_to_str(cruiser.escape_route)
							cparms["rotation"] = var_to_str(cruiser.rotation)
							cparms["position"] = var_to_str(cruiser.position)
							cparms["from_left"] = cruiser.from_left
							cparms["is_dead"] = cruiser.is_dead
							cparms["@smp_ia"] = \
								smp_loader._retrieve_data(cruiser.smp_ia)							

							ret["cosmic_cruisers"].append(cparms)
							
	return ret
		
	
func _consume_data(res: Dictionary, deps: Dictionary) -> void:
	var parms = res.data
	var cosmic_node: CosmicNode = deps.get("cosmic_cruisers")

	for cparms in parms["cosmic_cruisers"]:
		var cruiser : CosmicCruiser = cosmic_node.plane_scene.instantiate()
		var ret = cosmic_node.create_path_for_plane(cparms["from_left"], str_to_var(cparms["@path_position"]))
		var pf : PathFollow3D = ret.parent
		pf.progress_ratio = cparms["@progress_ratio"]
		cruiser._init_me({"parms": cparms, "parent": pf})
		var smp_loader : LoadSaveSMP  = LoadSaveSMP.new()
		smp_loader._put_data(cruiser.smp_ia, cparms["@smp_ia"])
