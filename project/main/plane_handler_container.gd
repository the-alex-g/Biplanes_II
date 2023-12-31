class_name PlaneHandlerContainer
extends GridContainer

@export var ai_planes := 2

var _plane_handlers := {}


func generate_plane_handlers(player_colors:Dictionary)->void:
	if player_colors.size() == 1:
		columns = 1
	else:
		columns = 2
	
	for i:int in ai_planes:
		_add_AI_plane_handler(-i - 1)
	
	for player_index:int in player_colors.keys():
		_add_plane_handler(player_index, player_colors[player_index])
	
	_sync_radar()


func _add_AI_plane_handler(index:int)->void:
	var plane_handler := AIPlaneHandler.new()
	_plane_handlers[index] = plane_handler
	plane_handler.plane_destroyed.connect(_on_plane_handler_plane_destroyed.bind(index))
	add_child(plane_handler)


func _add_plane_handler(player_index:int, color:Color)->void:
	var plane_handler : PlaneHandler = load("res://plane_hud/plane_handler.tscn").instantiate()
	plane_handler.player_index = player_index
	plane_handler.color = color
	_plane_handlers[player_index] = plane_handler
	
	plane_handler.plane_destroyed.connect(_on_plane_handler_plane_destroyed.bind(player_index))
	
	add_child(plane_handler)


func _on_plane_handler_plane_destroyed(destroyer_index:int, destroyed_plane_index:int)->void:
	if destroyer_index >= 0:
		_plane_handlers[destroyer_index].log_kill(_plane_handlers[destroyed_plane_index].color)


func _sync_radar()->void:
	for plane_handler in _plane_handlers.values():
		var other_planes : Array[PlaneRoot] = []
		for other_plane_handler in _plane_handlers.values():
			if other_plane_handler != plane_handler:
				other_planes.append(other_plane_handler.plane)
		if plane_handler is PlaneHandler:
			plane_handler.set_radar_planes(other_planes)
