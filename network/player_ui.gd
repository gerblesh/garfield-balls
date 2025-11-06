extends HBoxContainer

var player_id: int
var player_name: String

@onready var label: Label = $Label
@onready var remove: Button = $Button

func _ready() -> void:
	label.text = player_name
	Network.player_info_changed.connect(_on_info_changed)
	if Network.multiplayer.is_server():
		remove.pressed.connect(remove_pressed)
	else:
		remove.disabled = true
		remove.disabled = true

func _on_info_changed(id: int, new_info: Dictionary) -> void:
	if id == player_id:
		label.text = new_info.name

# ONLY called on the server
func remove_pressed() -> void:
	Network.kick_player(player_id)
	
