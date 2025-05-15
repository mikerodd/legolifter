extends AudioStreamPlayer3D


@export var breaks : Array[Resource] 


func _ready() -> void:
	self.stream = breaks[LiveDemo.randi_range(self,0,breaks.size() - 1)]
	pass
	
