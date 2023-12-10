class_name PlaneHandlerContainer
extends GridContainer

var _plane_handlers := {}


func generate_plane_handlers(player_colors:Dictionary)->void:
	if player_colors.size() == 1:
		columns = 1
	else:
		columns = 2
	
	for player_index:int in player_colors.keys():
		_add_plane_handler(player_index, player_colors[player_index])


func _add_plane_handler(player_index:int, color:Color)->void:
	var plane_handler : PlaneHandler = load("res://plane_hud/plane_handler.tscn").instantiate()
	plane_handler.player_index = player_index
	plane_handler.color = color
	_plane_handlers[player_index] = plane_handler
	
	plane_handler.plane_destroyed.connect(_on_plane_handler_plane_destroyed.bind(player_index))
	
	add_child(plane_handler)


func _on_plane_handler_plane_destroyed(destroyer_index:int, destroyed_plane_index:int)->void:
	if destroyer_index != -1:
		_plane_handlers[destroyer_index].log_kill(_plane_handlers[destroyed_plane_index].color)
