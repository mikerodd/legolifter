extends Control


@onready var out_label: Label = get_node("HostageScore/MarginContainer/GridContainer/OutContainer/OutCount")
@onready var saved_label: Label = get_node("HostageScore/MarginContainer/GridContainer/SavedContainer/SaveCount")
@onready var dead_label: Label = get_node("HostageScore/MarginContainer/GridContainer/DeatContainer/DeadCount")
@onready var detained_label: Label = get_node("HostageScore/MarginContainer/GridContainer/DetainedContainer/DetainedCount")
@onready var heli_label : Label = get_node("HostageScore/MarginContainer/GridContainer/HeliContainer/HeliCount")
@onready var heli_lives_label : Label = get_node("HeliRemaining/HBoxContainer/Helilives")
@onready var score_label : Label = $HostageScore/MarginContainer/GridContainer/ScoreContainer/ScoreCount

func _ready() -> void:
	Messenger.update_scores.connect(self.update_scores)

		

func update_scores() -> void:
	saved_label.text = str(GameVariables.saved_count)
	detained_label.text = str(GameVariables.detained_count)
	dead_label.text = str(GameVariables.dead_count)
	out_label.text = str(GameVariables.out_count)
	heli_label.text = str(GameVariables.heli_count)
	heli_lives_label.text = str(GameVariables.heli_lives)
	score_label.text = str(GameVariables.score)
	
