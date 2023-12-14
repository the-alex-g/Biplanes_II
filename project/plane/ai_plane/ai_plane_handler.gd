class_name AIPlaneHandler
extends Node

signal plane_destroyed(destroyer_index)

const OFF_BOARD_POSITION := Vector3(0, -1000, 0)

@export var world_size := Vector3(1000, 500, 1000)
@export var min_spawn_height := 50.0
@export var max_spawn_height := 150.0

var color : Color : get = _get_color

@onready var plane : AIPlane


func _ready()->void:
	plane = preload("res://plane/ai_plane/ai_plane.tscn").instantiate()
	plane.destroyed.connect(_on_biplane_destroyed)
	add_child(plane)
	_respawn_plane()


func _respawn_plane()->void:
	var spawn_position := _get_spawn_position()
	plane.global_position = spawn_position
	plane.look_at(Vector3(0, spawn_position.y, 0))
	plane.reset()


func _get_spawn_position()->Vector3:
	return Vector3(
		randf_range(-world_size.x, world_size.x) / 2.0,
		randf_range(min_spawn_height, min(max_spawn_height, world_size.y)),
		randf_range(-world_size.z, world_size.z) / 2.0
	)


func _on_biplane_destroyed(destroyer_index:int)->void:
	plane_destroyed.emit(destroyer_index)
	_create_plane_wreck(plane.global_transform)
	plane.disabled = true
	plane.global_position = OFF_BOARD_POSITION
	
	await get_tree().create_timer(2.0 + randf() * 4.0).timeout
	
	_respawn_plane()


func _create_plane_wreck(transform:Transform3D)->void:
	var wreck : PlaneWreck = preload("res://plane/wreck/plane_wreck.tscn").instantiate()
	wreck.global_transform = transform
	wreck.direction = plane.physics.get_forward_vector(transform)
	wreck.color = plane.COLOR
	wreck.wreck_velocity = plane.physics.forward_velocity
	add_child(wreck)


func _get_color()->Color:
	return plane.color
