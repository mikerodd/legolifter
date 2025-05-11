extends LightmapGI



func _ready() -> void:
	if GameVariables.use_lightmap:
		visible = true
	else:
		visible = false
