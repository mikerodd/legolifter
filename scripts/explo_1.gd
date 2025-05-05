extends Node3D


func _ready() -> void:
	$incendescent.emitting = true
	$smoke_explosion.emitting = true
	


func _on_incendescent_finished() -> void:
	self.queue_free()
	
