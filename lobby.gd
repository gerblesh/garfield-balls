extends Control

@export var player_list: VBoxContainer
@export var username_edit: LineEdit
@export var character_select: OptionButton
@export var start_game: Button
@export var player_label: Label
var player_comp: PackedScene = preload("res://player_component.tscn")

func _ready() -> void:
	Network.player_connected.connect(_player_connected)
	Network.player_disconnected.connect(_on_player_disconnected)
	Network.player_list_changed.connect(_on_player_list_changed)
	username_edit.text = Network.player_info.name
	username_edit.text_submitted.connect(_on_username_edited)
	start_game.pressed.connect(_on_start_game_pressed)
	start_game.disabled = true

	for key: String in Ball.C.keys():
		if key == "NULL":
			character_select.add_separator("Select Character")
		else:
			character_select.add_item(key.capitalize())
	character_select.selected = 0
	character_select.item_selected.connect(_on_char_selected)

func _player_connected(id: int, info: Dictionary) -> void:
	if id == Network.multiplayer.get_unique_id():
		return
	var new_p := player_comp.instantiate()
	new_p.player_name = info.name
	new_p.player_id = id
	player_list.add_child(new_p)

func _on_player_disconnected(id: int) -> void:
	for child in player_list.get_children():
		if child.player_id == id:
			child.queue_free()
			return


func _on_username_edited(txt: String) -> void:
	if txt == "":
		username_edit.text = Network.player_info.name
		return

	var new_info := Network.player_info
	new_info.name = txt
	Network.change_player_info.rpc(new_info)

func _on_start_game_pressed() -> void:
	Network.load_game.rpc("res://MIAN.tscn")


func _on_char_selected(idx: int) -> void:
	var new_char := idx as Ball.C
	var new_info := Network.player_info
	new_info.char = new_char
	Network.change_player_info.rpc(new_info)

func _on_player_list_changed() -> void:
	if not Network.multiplayer.is_server():
		return

	for k in Network.players:
		var p: Dictionary = Network.players[k]
		# if any of the characters are null or player names are empty, skip we are *not* ready
		if p.char == Ball.C.NULL or p.name == "":
			start_game.disabled = true
			return
	start_game.disabled = false
