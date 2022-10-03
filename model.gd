extends Node3D
var models: Array[PackedScene] = [
	preload("res://models/garfield/garf.tscn"),
	preload("res://models/andrew/andrew.tscn")
]

var current_character: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	set_character(0)

func set_character(i: int):
	if is_instance_valid(current_character):
		current_character.queue_free()
	current_character = models[i].instantiate()
	add_child(current_character)

func _unhandled_input(event):
	if Input.is_action_just_pressed("char1"):
		set_character(0)
	if Input.is_action_just_pressed("char2"):
		set_character(1)
	
