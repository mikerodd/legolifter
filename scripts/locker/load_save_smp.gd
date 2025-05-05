class_name LoadSaveSMP 

const YAFSM = preload("res://addons/imjp94.yafsm/YAFSM.gd")
const StackPlayer = YAFSM.StackPlayer
const StateMachinePlayer = YAFSM.StateMachinePlayer



func _retrieve_data(smp : StateMachinePlayer) -> Dictionary:
	var ret : Dictionary = {}

	# StackPlayer	
	ret.set("_stack",var_to_str(smp._stack))
	ret.set("current", var_to_str(smp.current))
	
	# StateMachinePlayer
	ret.set("active", smp.active)
	ret.set("autostart", smp.autostart)
	ret.set("update_process_mode", smp.update_process_mode)
	ret.set("_is_started", smp._is_started)
	ret.set("_is_update_locked", smp._is_update_locked)
	ret.set("_was_transited", smp._was_transited)
	ret.set("_is_param_edited", smp._is_param_edited)
	ret.set("_parameters", var_to_str(smp._parameters))
	ret.set("_local_parameters",var_to_str(smp._local_parameters))
	ret.set("state_machine",var_to_str(smp.state_machine))
	return ret

func disconnect_signals(callables: Dictionary, signals: Array[Signal]) -> void:
	for s in signals: 
		callables.set(s.get_name()  , s.get_connections())
		for cals in s.get_connections():
			s.disconnect(cals.callable)	

func reconnect_signals(callables: Dictionary, _signals: Array[Signal]) -> void:
		
	for key in callables.keys():
		for con in callables[key]:
			var s: Signal = con.signal
			s.connect(con.callable, con.flags)

func _put_data(smp : StateMachinePlayer, 
		res: Dictionary,
		block_sp_signals: bool = false, 
		block_smp_signals: bool = false
		) -> void:


	var callables : Dictionary = {}
	var sp_signals : Array[Signal] = [smp.pushed,smp.popped]
	var smp_signals : Array[Signal] = [smp.transited,smp.entered,smp.exited,smp.updated]
	var signals : Array[Signal] = []
	signals.append_array(sp_signals if block_sp_signals else [])
	signals.append_array(smp_signals if block_smp_signals else [])
	disconnect_signals(callables, signals)

	# StackPlayer	
	var new_stack: Array =  str_to_var(res["_stack"])
	print("previous smp._stack : %s" % var_to_str(smp._stack))
	smp.reset(-1, StackPlayer.ResetEventTrigger.LAST_TO_DEST)
	for st in new_stack:
		smp.push(st)
	print("new smp._stack : %s" % var_to_str(smp._stack))
	smp.current = str_to_var(res["current"])
	
	# StateMachinePlayer
	smp.active = res["active"]
	smp.autostart = res["autostart"]
	smp.update_process_mode = res["update_process_mode"]
	smp._is_started = res["_is_started"]
	smp._is_update_locked = res["_is_update_locked"]
	smp._was_transited = res["_was_transited"]
	smp._is_param_edited = res["_is_param_edited"]
	smp._parameters = str_to_var(res["_parameters"])
	smp._local_parameters = str_to_var(res["_local_parameters"])
	smp.state_machine = str_to_var(res["state_machine"])
	
	reconnect_signals(callables, signals)


func display_infos(smp : StateMachinePlayer) -> void:
	print ("Current smp stack:")
	for d in smp._stack:
		print(d)
		
	print ("current parameters:")
	for d in smp._parameters.keys():
		print(" key: %s, value: %s" % [d, smp._parameters[d]])
		
	print ("current local parameters:")
	for d1 in smp._local_parameters.keys():
		print("  local parameters for %s" % d1)
		for d2 in smp._local_parameters[d1].keys():
			print("   key: %s, value: %s" % [d2, smp._local_parameters[d1][d2]])
				
	
