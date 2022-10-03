extends Node3D
var models: Array[PackedScene] = [
	preload("res://models/garfield/garf.tscn"),
	preload("res://models/andrew/andrew.tscn")
]

var current_character: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	set_character(1)
	pass # Replace with function body.

func set_character(i: int):
	if is_instance_valid(current_character):
		current_character.queue_free()
	current_character = models[i].instantiate()
	add_child(current_character)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
