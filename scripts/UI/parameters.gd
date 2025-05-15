
#-757.0

extends UILifterElement

@onready var fs_check: CheckButton = $ParametersPanel/HBoxContainer/VBoxContainer/FullscreenMode
@onready var highgraph_check : CheckButton = $ParametersPanel/HBoxContainer/VBoxContainer/HighGraphics
@onready var wsad : ItemList = $ParametersPanel/HBoxContainer/VBoxContainer/UseWSAD
@onready var music_volume:HSlider = $ParametersPanel/HBoxContainer/VBoxContainer/Sound/Music2/MusicSlider
@onready var effects_volume: HSlider = $ParametersPanel/HBoxContainer/VBoxContainer/Sound/Music2/EffectSlider
@onready var music_label:Label = $ParametersPanel/HBoxContainer/VBoxContainer/Sound/Labels/MusicSliderLabel
@onready var effects_label: Label = $ParametersPanel/HBoxContainer/VBoxContainer/Sound/Labels/EffectSliderLabel

var ui_hide_position: float = -346.0
var ui_show_position: float = 5


func _show_me(_darken : bool = false ) -> void :
	fs_check.button_pressed = GameVariables.start_fullscreen
	highgraph_check.button_pressed = GameVariables.high_graphics
	music_volume.value = GameVariables.music_volume
	effects_volume.value = GameVariables.effects_volume
	if GameVariables.keyboard_use_wsad:
		wsad.select(0)
	else:
		wsad.select(1)
	
	super._show_me()
	

func _ready() -> void:
	Messenger.ui_show_parameters.connect(_show_me)


func _on_ok_pressed() -> void:
	GameVariables.start_fullscreen = fs_check.button_pressed
	GameVariables.high_graphics = highgraph_check.button_pressed
	GameVariables.music_volume = music_volume.value
	GameVariables.effects_volume = effects_volume.value
	if wsad.is_selected(0):
		GameVariables.keyboard_use_wsad = true
	else:
		GameVariables.keyboard_use_wsad = false
	
	GameVariables.save_parameters()
	_hide_me()


func _on_cancel_pressed() -> void:
	_hide_me()
