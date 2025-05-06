extends CharacterBody3D

class_name Actor


func _init_me(spawn_p: Dictionary) -> void:
	if spawn_p.has("parent"):
		spawn_p["parent"].add_child(self)	
		owner = get_tree().get_root()  
	else:
		push_error("Actor %s has no parent in parms " % self.name)

	if spawn_p.has("parms"): 
		for parm in spawn_p["parms"].keys():
			if parm == "#do_initiate":
				for smp in str_to_var(spawn_p["parms"]["#do_initiate"]):
					get_node(smp)._initiate()
					
			elif parm.begins_with("@"): 
				continue
			if spawn_p["parms"][parm] is String and str_to_var(spawn_p["parms"][parm]) != null:
				set(parm,str_to_var(spawn_p["parms"][parm]))
			else:
				set(parm,spawn_p["parms"][parm])


func init_smp_if_needed(parms:Dictionary, smps: Array = []) -> void:
	if parms.has("@do_initiate"):
		for smp in smps:
			smp._initiate()

func _ready() ->void:
	pass
	
	
func _process(_delta) -> void:
	pass
	
