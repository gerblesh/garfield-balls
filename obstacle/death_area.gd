extends Area3D


func _ready() -> void:
	body_entered.connect(_on_entered)
	

func _on_entered(body: Node3D) -> void:
	var p := body as Ball
	if p == null:
		return
	
	p.reset_pos()
