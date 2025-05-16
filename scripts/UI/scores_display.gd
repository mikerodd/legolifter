extends Control


@onready var out_label: Label = %OutCount
@onready var saved_label: Label = %SaveCount
@onready var dead_label: Label = %DeadCount
@onready var detained_label: Label = %DetainedCount
@onready var heli_label : Label = %HeliCount
@onready var heli_lives_label : Label = %Helilives
@onready var score_label : Label = %ScoreCount
@onready var version_label: Label = %Version
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
	version_label.text = GameVariables.version
	
