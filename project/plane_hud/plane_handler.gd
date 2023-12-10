class_name PlaneHandler
extends Control

signal plane_destroyed(destroyer_index)

const OFF_BOARD_POSITION := Vector3(0, -1000, 0)

@export var player_index := -1
@export var world_size := Vector3(1000, 500, 1000)
@export var min_spawn_height := 50.0
@export var max_spawn_height := 150.0

var color : Color
var _kills := {}
var _kills_this_flight := 0
var _plane_upgrader := PlaneUpgrader.new()

@onready var _plane : Biplane = $SubViewportContainer/SubViewport/Biplane
@onready var _upgrade_interface : PlaneUpgradeInterface = $PlaneUpgradeInterface


func _ready()->void:
	_respawn_plane()
	_plane.player_index = player_index
	_plane.color = color
	_upgrade_interface.player_index = player_index
	_plane_upgrader.plane = _plane


func _respawn_plane()->void:
	var spawn_position := _get_spawn_position()
	_kills_this_flight = 0
	_plane.global_position = spawn_position
	_plane.look_at(Vector3(0, spawn_position.y, 0))
	_plane.reset()


func _get_spawn_position()->Vector3:
	return Vector3(
		randf_range(-world_size.x, world_size.x) / 2.0,
		randf_range(min_spawn_height, min(max_spawn_height, world_size.y)),
		randf_range(-world_size.z, world_size.z) / 2.0
	)


func log_kill(destroyed_plane_index:int)->void:
	if _kills.has(destroyed_plane_index):
		_kills[destroyed_plane_index] += 1
	else:
		_kills[destroyed_plane_index] = 1
	_kills_this_flight += 1


func _on_biplane_destroyed(destroyer_index:int)->void:
	plane_destroyed.emit(destroyer_index)
	_plane.disabled = true
	_plane.global_position = OFF_BOARD_POSITION
	_upgrade_interface.open(_kills_this_flight)


func _on_plane_upgrade_interface_launched()->void:
	_upgrade_interface.hide()
	_respawn_plane()


func _on_plane_upgrade_interface_item_upgraded(item_name:String)->void:
	_plane_upgrader.upgrade(item_name)
