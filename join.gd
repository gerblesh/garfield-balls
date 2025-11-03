extends Control

@onready var join: Button = $VBoxContainer/Join
@onready var ip: TextEdit = $VBoxContainer/IP
@onready var username: LineEdit = $VBoxContainer/LineEdit

@onready var host: Button = $VBoxContainer/Host

func _ready() -> void:
	if Network.player_info.name == "":
		join.disabled = true
		host.disabled = true
	else:
		username.text = Network.player_info.name

	join.pressed.connect(_on_join_pressed)
	host.pressed.connect(_on_host_pressed)
	username.text_submitted.connect(name_submitted)

func _on_join_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://lobby.tscn")
	Network.start_client(ip.text)

func _on_host_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://lobby.tscn")
	Network.start_server()

func name_submitted(txt: String) -> void:
	if txt == "":
		host.disabled = true
		join.disabled = true
		return
	host.disabled = false
	join.disabled = false
	Network.player_info = Network.new_player_info(txt, Ball.C.NULL)
