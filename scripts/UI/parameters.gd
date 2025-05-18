
#-757.0

extends UILifterElement

@onready var fs_check: CheckButton = %FullscreenMode
@onready var highgraph_check : CheckButton = %HighGraphics
@onready var wsad : ItemList = %UseWSAD
@onready var music_volume:HSlider = %MusicSlider
@onready var effects_volume: HSlider = %EffectSlider
@onready var music_off : CheckBox = %MusicOff
@onready var effects_off: CheckBox = %EffectsOff

var ui_hide_position: float =  0 #- self.size.x  #-757
var ui_show_position: float = self.size.x # 235.0

#var ui_hide_position: float = -380.0
#var ui_show_position: float = 5

func _ready() -> void:
	super._ready()
	Messenger.ui_show_parameters.connect(_show_me)



func _show_me(_darken : bool = false ) -> void :
	fs_check.button_pressed = GameVariables.start_fullscreen
	highgraph_check.button_pressed = GameVariables.high_graphics
	music_volume.value = GameVariables.music_volume
	effects_volume.value = GameVariables.effects_volume
	music_off.button_pressed = GameVariables.music_off
	effects_off.button_pressed = GameVariables.effects_off
	music_volume.editable = not music_off.button_pressed
	effects_volume.editable = not effects_off.button_pressed
	
	if GameVariables.keyboard_use_wsad:
		wsad.select(0)
	else:
		wsad.select(1)
	
	super._show_me(_darken)
	



func _on_ok_pressed() -> void:
	GameVariables.start_fullscreen = fs_check.button_pressed
	GameVariables.high_graphics = highgraph_check.button_pressed
	GameVariables.music_volume = music_volume.value
	GameVariables.effects_volume = effects_volume.value
	GameVariables.music_off = music_off.button_pressed
	GameVariables.effects_off = effects_off.button_pressed
	if wsad.is_selected(0):
		GameVariables.keyboard_use_wsad = true
	else:
		GameVariables.keyboard_use_wsad = false
	
	GameVariables.save_parameters()
	_hide_me()


func _on_cancel_pressed() -> void:
	_hide_me()


func _on_music_off_pressed() -> void:
	music_volume.editable = not music_off.button_pressed


func _on_effects_off_pressed() -> void:
	effects_volume.editable = not effects_off.button_pressed
