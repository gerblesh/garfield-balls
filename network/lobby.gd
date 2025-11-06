extends Control

# @export var player_list: VBoxContainer
@export var username_edit: LineEdit
@export var character_select: OptionButton
@export var start_game: Button
@export var player_label: Label

# var player_comp: PackedScene = preload("res://network/player_component.tscn")
#

@export var name_col: VBoxContainer
@export var character_col: VBoxContainer
@export var wins_col: VBoxContainer
@export var ready_col: VBoxContainer
@export var host_col: VBoxContainer

func _ready() -> void:
	# Network.player_connected.connect(_player_connected)
	# Network.player_disconnected.connect(_on_player_disconnected)
	Network.player_list_changed.connect(_on_player_list_changed)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	player_label.text = "%d/%d Players | %d/%d Ready" % [Network.players.size(), Network.MAX_PLAYERS, 0, Network.players.size()]
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
	
	_on_player_list_changed()

# func _player_connected(id: int, info: Dictionary) -> void:
# 	if id == Network.multiplayer.get_unique_id():
# 		return
# 	var new_p := player_comp.instantiate()
# 	new_p.player_name = info.name
# 	new_p.player_id = id
# 	player_list.add_child(new_p)

# func _on_player_disconnected(id: int) -> void:
# 	for child in player_list.get_children():
# 		if child.player_id == id:
# 			child.queue_free()
# 			return


func _on_username_edited(txt: String) -> void:
	if txt == "":
		username_edit.text = Network.player_info.name
		return

	var new_info := Network.player_info
	new_info.name = txt
	Network.change_player_info.rpc(new_info)

func _on_start_game_pressed() -> void:
	Network.load_game.rpc("res://network/game.tscn")


func _on_char_selected(idx: int) -> void:
	var new_char := idx as Ball.C
	var new_info := Network.player_info
	new_info.char = new_char
	Network.change_player_info.rpc(new_info)

func _on_player_list_changed() -> void:
	# if not Network.multiplayer.is_server():
	# 	return
	var not_ready := 0
	for k in Network.players:
		var p: Dictionary = Network.players[k]
		# if any of the characters are null or player names are empty, skip we are *not* ready
		if p.char == Ball.C.NULL or p.name == "":
			start_game.disabled = true
			not_ready += 1

	var total_players := Network.players.size()
	player_label.text = "%d/%d Players | %d/%d Ready" % [total_players, Network.MAX_PLAYERS, total_players - not_ready, total_players]
	if not_ready <= 0 and Network.multiplayer.is_server():
		start_game.disabled = false
	else:
		start_game.disabled = true

	var delete_all := func(n: Node) -> void:
			for i: int in n.get_child_count():
				if i < 1:
					# don't delete the header :-)
					continue
				n.get_child(i).queue_free()

	delete_all.call(name_col)
	delete_all.call(character_col)
	delete_all.call(wins_col)
	delete_all.call(ready_col)
	delete_all.call(host_col)
	# Display the Players
	# first, sort the list
	var sorted := Network.players.values()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary):
		return a.laps >= b.laps
	)
	for p in sorted:
		#var p: Dictionary = Network.players[k]
		# if k == Network.multiplayer.get_unique_id():
		# 	continue

		var name_label := Label.new()
		name_label.text = p.name
		name_col.add_child(name_label)

		var character_label := Label.new()
		character_label.text = Ball.C.keys()[p.char].capitalize()
		character_col.add_child(character_label)

		var wins_label := Label.new()
		wins_label.text = str(p.wins)
		wins_col.add_child(wins_label)

		var ready_label := Label.new()
		ready_label.text = "no" if p.char == Ball.C.NULL else "yes"
		ready_col.add_child(ready_label)

		var host_label := Label.new()
		host_label.text = "yes" if p.id == 1 else "no"
		host_col.add_child(host_label)
