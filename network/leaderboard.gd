extends PanelContainer

@onready var columns := $VBoxContainer/HBoxContainer.get_children()

# @onready var accesors := 
# class info:
# 	var column_name: String
# 	var column_accesor: String

var col_info : PackedStringArray = ["name", "laps", "wins"]

func _ready() -> void:
	Network.player_list_changed.connect(_on_player_list_changed)
	_on_player_list_changed()

func _on_player_list_changed() -> void:
	var arr: Array[Dictionary] = []
	for k in Network.players.keys():
		arr.append(Network.players[k])
		
	arr.sort_custom(func(a: Dictionary, b: Dictionary):
		return a.laps >= b.laps
	)
	for i in col_info.size():
		remove_children(columns[i])
		for p in arr:
			var label := Label.new()
			label.text = str(p[col_info[i]])
			columns[i].add_child(label)

func remove_children(n: Node) -> void:
	var children := n.get_children()
	for child in children:
		child.queue_free()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("leaderboard"):
		show()
		return
	hide()
