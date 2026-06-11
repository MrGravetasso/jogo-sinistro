extends Camera2D

var player: Node2D

func _ready() -> void:
	get_player()

func _process(_delta: float) -> void:
	position = player.position

func get_player():
	var lugar = get_tree().get_nodes_in_group("player")
	
	if lugar.size() == 0:
		push_error("cade você bro?")
		return
	
	player = lugar[0]
