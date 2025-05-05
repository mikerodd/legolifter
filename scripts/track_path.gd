extends Path3D



@export_range(1,200) var nb_threads: int
@export var offset: float
@export var speed: float

@onready var first_track:PathFollow3D = $thread1
@onready var track_path:Path3D = $"."

var time = 0 
var current_speed:float = 0
var forward = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_track: PathFollow3D 
	for d in range(nb_threads - 1):
		new_track = first_track.duplicate()
		new_track.progress = d * offset
		track_path.add_child(new_track)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_speed == 0:
		return
	
	var count = 0
	var p
	time += delta
	for idx:PathFollow3D in track_path.get_children():
		p =  speed * time +  (offset * count)
		idx.progress = forward * p
		count += 1

func move_forward() -> void:
		current_speed = speed
		forward = 1

func move_backward() -> void:
		current_speed = speed
		forward = -1

func move_stop() -> void:
		current_speed = 0
