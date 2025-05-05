class_name PlayerNodeAccessorV1
extends LokStorageAccessorVersion



func _retrieve_data(deps: Dictionary) -> Dictionary:
	var player_node: Node = deps.get("player_node")
	var player : Player = GlobalUtils.player
	var ret : Dictionary = {"player":{}}
	var smp_loader : LoadSaveSMP  = LoadSaveSMP.new()
	ret["name"] = player_node
	ret["land_altitude"] = player_node.land_altitude
	ret["player"]["name"] = player.name
	ret["player"]["position"] = var_to_str(player.position)
	ret["player"]["rotation"] = var_to_str(player.rotation)
	ret["player"]["can_play"] = player.can_play
	ret["player"]["can_fire"] = player.can_fire
	ret["player"]["is_dead"] = player.is_dead
	ret["player"]["elapsed_rotate"] = player.elapsed_rotate
	ret["player"]["passenger_count"] = player.passenger_count

	ret["player"]["@speed_scale"] = player.model_anim.speed_scale
	ret["player"]["#do_initiate"] = var_to_str(["NewFlyingSMP", "NewRotatingSMP"])

	ret["player"]["@flying_smp"] = \
			smp_loader._retrieve_data(player.flying_smp)
	ret["player"]["@rotating_smp"] = \
			smp_loader._retrieve_data(player.rotating_smp)
	
	return ret


func _consume_data(res: Dictionary, deps: Dictionary) -> void:
	var player_node: Node = deps.get("player_node")
	var parms = res.data
	var p_parms = parms["player"]	
	for p in player_node.get_children():
		if p is Player:
			p.queue_free()
			await p.tree_exited
			
	player_node.land_altitude = parms["land_altitude"]
	var spawn_p : Dictionary = {"parms" : p_parms, "parent": player_node}
	
	var player: Player =  player_node.player_scene.instantiate()
	GlobalUtils.player = player
	player._init_me(spawn_p)
	Logger.debug("start status of the flying_smp : %s " % player.flying_smp._is_started)
	var smp_loader : LoadSaveSMP  = LoadSaveSMP.new()
	smp_loader._put_data(player.flying_smp, p_parms["@flying_smp"])
	smp_loader._put_data(player.rotating_smp, p_parms["@rotating_smp"])
	print("flying_smp current : %s" % player.flying_smp.get_current())
