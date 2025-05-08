class_name LegoDestroyer extends Node

signal destroy_begin
signal destroy_end

@export var destroy_model: PackedScene
@export_node_path("Node3D") var initial_model_np : NodePath
@onready var initial_model : Node3D = get_node(initial_model_np)
@export_category("others")
@export var explode_intensity : float = 4
@export_node_path("Marker3D") var center_of_explosion_np
@onready var center_of_explosion: Marker3D = get_node(center_of_explosion_np)


var is_destroyed : bool = false 




	
	
func destroy(show_explode: bool = true) -> void:
	if is_destroyed:
		return


	is_destroyed = true

	var destroy_model_inst: Node3D = destroy_model.instantiate()
	get_tree().get_root().add_child(destroy_model_inst)
	destroy_model_inst.transform = Transform3D(initial_model.global_basis, initial_model.global_position)
	if show_explode:
		apply_impulse(destroy_model_inst)
	destroy_begin.emit()	
	if show_explode:
		await get_tree().create_timer(3).timeout
	if remove_pieces(destroy_model_inst) == 0:
		destroy_model_inst.queue_free()
	destroy_end.emit()
	
	
func apply_impulse(node: Node3D):
	for p in node.get_children():
		if p is RigidBody3D:
			p.apply_impulse(p.get_child(1).position * randf_range(0.1,explode_intensity), center_of_explosion.global_position)
			p.apply_torque(center_of_explosion.global_position - p.position)

		if p.get_child_count() > 0:
			apply_impulse(p)

func remove_pieces(p: Node3D, remaining : int = 0) -> int :
	if not p.name.contains("-notdestruct"):
		if p.get_child_count() == 0:
			p.queue_free()
		else:
			for p2 in p.get_children():
				if p2 is Node3D: remaining += remove_pieces(p2, remaining)
		return remaining
	else: return remaining + 1
