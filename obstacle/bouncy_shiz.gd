extends Area3D


@export var jumpy: float

func _ready() -> void:
	body_entered.connect(_body_entered)


func _body_entered(b: Node3D) -> void:
	var body := b as RigidBody3D
	if body == null:
		return # top bruh
	body.apply_central_impulse(basis.y * jumpy)
