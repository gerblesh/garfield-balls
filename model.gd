extends Node3D
var models: Dictionary[Ball.C, PackedScene] = {
	Ball.C.GARFIELD: preload("res://models/garfield/garf.tscn"),
	Ball.C.ANDRE: preload("res://models/andrew/andrew.tscn"),
	Ball.C.TELETUBBY: preload("res://models/teletuffy/teletuffy.tscn"),
	Ball.C.SUSSY: preload("res://models/sussy/sussy.tscn"),
	Ball.C.OG_GARFIELD: preload("res://models/garfield_og/garfield_og.tscn"),
}

var current_character: Node3D
var current_char: Ball.C = Ball.C.NULL

func set_character(i: Ball.C) -> void:
	if models.get(i) == null:
		return
	if is_instance_valid(current_character):
		current_character.queue_free()
	var s := models[i]
	current_character = s.instantiate()
	current_char = i
	add_child(current_character)
