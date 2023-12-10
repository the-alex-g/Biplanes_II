class_name PlaneHandler
extends Control

@export var player_index := -1
@export var world_size := Vector3(1000, 500, 1000)
@export var min_spawn_height := 50.0
@export var max_spawn_height := 150.0

@onready var _plane : Biplane = $SubViewportContainer/SubViewport/Biplane


func _ready()->void:
	_respawn_plane()
	_plane.player_index = player_index


func _respawn_plane()->void:
	var spawn_position := _get_spawn_position()
	_plane.global_position = spawn_position
	_plane.look_at(Vector3(0, spawn_position.y, 0))


func _get_spawn_position()->Vector3:
	return Vector3(
		randf_range(-world_size.x, world_size.x) / 2.0,
		randf_range(min_spawn_height, min(max_spawn_height, world_size.y)),
		randf_range(-world_size.z, world_size.z) / 2.0
	)
