extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(b: Node3D) -> void:
	var ball = b as Ball
	if ball == null:
		return
	Network.lap.rpc()
	ball.reset_pos()
	Network.local_status("Lap!!")
