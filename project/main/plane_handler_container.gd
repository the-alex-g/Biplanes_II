class_name PlaneHandlerContainer
extends GridContainer

@onready var _screen_size := DisplayServer.window_get_size()


func _ready()->void:
	generate_plane_handlers([0, 1])


func generate_plane_handlers(players:Array[int])->void:
	if players.size() > 2:
		columns = 2
	for player_index:int in players:
		_add_plane_handler(player_index, players)


func _add_plane_handler(player_index:int, players:Array[int])->void:
	var plane_handler : PlaneHandler = load("res://plane/plane_handler.tscn").instantiate()
	plane_handler.player_index = player_index
	add_child(plane_handler)
