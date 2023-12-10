extends Node3D

@onready var _plane_handler_container : PlaneHandlerContainer = $PlaneHandlerContainer


func _on_join_menu_game_started(player_colors:Dictionary)->void:
	_plane_handler_container.generate_plane_handlers(player_colors)
