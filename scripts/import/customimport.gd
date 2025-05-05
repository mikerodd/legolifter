@tool
extends EditorScenePostImport


func _post_import(scene):
	iterate(scene)
	return scene


func iterate(node):
	if node != null:
		#print("node name : " + node.name + " type " + node.get_class() + "contains: " + str(node.name.contains("-notdestruct")))
		
		if node.name.contains("-notdestruct"):
			pass
		if node is MeshInstance3D and not node.name.contains("-notdestruct"):
			var parent = node.get_parent()
			var body = RigidBody3D.new()
			var collision_shape = node.mesh.create_convex_shape(true, true)
			var shape = CollisionShape3D.new()
			shape.shape = collision_shape
			body.add_child(shape, true)
			#node.add_child(body, true)
			parent.add_child(body,true)
			var inst = node.duplicate()
			parent.remove_child(node)
			#parent.remove_child(inst)
			body.add_child(inst)
			inst.owner = parent.owner
			shape.position = inst.position
			shape.rotation = inst.rotation
			body.set_collision_layer(64)
			print("Collision layer 1 is??: %s" % body.get_collision_layer_value(1))
			body.set_collision_mask_value(4, true)
			body.owner = parent.owner
			shape.owner = parent.owner			



		for child in node.get_children():
			iterate(child)
