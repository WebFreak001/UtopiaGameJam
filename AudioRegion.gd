extends Node3D

@export var streams : Array[AudioStream]
@export var sleep_min : float = 0
@export var sleep_max : float = 5
@export var bus : StringName = &"Master"
@export var max_distance : float = 20

var sleep_time : float = 0

func _ready():
	play_next()

func play_next():
	var stream = streams[randi() % streams.size()]
	# print("play next stream", stream)
	$AudioSource.stream = stream
	$AudioSource.play()
	$AudioSource.bus = bus
	$AudioSource.max_distance = max_distance

func _process(delta):
	var source = $AudioSource
	# print("tick", source.playing, sleep_time)
	if source.playing:
		pass
	elif sleep_time > 0:
		sleep_time -= delta
	else:
		play_next()
		sleep_time = randf_range(sleep_min, sleep_max)
