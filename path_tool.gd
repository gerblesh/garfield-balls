@tool
extends CSGPolygon3D


@onready var p: Path3D = $Path3D


func _ready() -> void:
	p.top_level = true
	p.global_position = Vector3.ZERO
	if !Engine.is_editor_hint():
		set_process(false)

func _process(delta: float) -> void:
	p.global_position = Vector3.ZERO
