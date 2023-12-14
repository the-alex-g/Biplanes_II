class_name PlaneHandler
extends Control

signal plane_destroyed(destroyer_index)

const OFF_BOARD_POSITION := Vector3(0, -1000, 0)
const CAN_FIRE_COLOR := Color(0.0, 1.0, 0.0, 0.5)
const CANNOT_FIRE_COLOR := Color(1.0, 0.0, 0.0, 0.5)

@export var player_index := -1
@export var world_size := Vector3(1000, 500, 1000)
@export var min_spawn_height := 50.0
@export var max_spawn_height := 150.0

var color : Color
var _kills := {}
var _kills_this_flight := 0
var _plane_upgrader := PlaneUpgrader.new()

@onready var plane : Biplane = $SubViewportContainer/SubViewport/Biplane
@onready var _upgrade_interface : PlaneUpgradeInterface = $PlaneUpgradeInterface
@onready var _plane_display : PlaneDisplay = $PlaneDisplay
@onready var _targeting_ring : TextureRect = $TargetingRing


func _ready()->void:
	_respawn_plane()
	plane.player_index = player_index
	plane.color = color
	_upgrade_interface.player_index = player_index
	_plane_upgrader.plane = plane


func _process(_delta:float)->void:
	_targeting_ring.self_modulate = CAN_FIRE_COLOR if plane.firing_area.has_targets() else CANNOT_FIRE_COLOR


func set_radar_planes(planes:Array[PlaneRoot])->void:
	_plane_display.set_radar_planes(planes)


func _respawn_plane()->void:
	var spawn_position := _get_spawn_position()
	_kills_this_flight = 0
	plane.global_position = spawn_position
	plane.look_at(Vector3(0, spawn_position.y, 0))
	plane.reset()


func _get_spawn_position()->Vector3:
	return Vector3(
		randf_range(-world_size.x, world_size.x) / 2.0,
		randf_range(min_spawn_height, min(max_spawn_height, world_size.y)),
		randf_range(-world_size.z, world_size.z) / 2.0
	)


func log_kill(destroyed_plane_color:Color)->void:
	if _kills.has(destroyed_plane_color):
		_kills[destroyed_plane_color] += 1
	else:
		_kills[destroyed_plane_color] = 1
	_kills_this_flight += 1
	_plane_display.update_kills(_kills)


func _on_biplane_destroyed(destroyer_index:int)->void:
	plane_destroyed.emit(destroyer_index)
	_create_plane_wreck(plane.global_transform)
	plane.disabled = true
	plane.global_position = OFF_BOARD_POSITION
	_upgrade_interface.open(_kills_this_flight)


func _create_plane_wreck(transform:Transform3D)->void:
	var wreck : PlaneWreck = load("res://plane/wreck/plane_wreck.tscn").instantiate()
	wreck.global_transform = transform
	wreck.direction = plane.physics.get_forward_vector(transform)
	wreck.color = color
	wreck.wreck_velocity = plane.physics.forward_velocity
	add_child(wreck)


func _on_plane_upgrade_interface_launched()->void:
	_upgrade_interface.hide()
	_respawn_plane()


func _on_plane_upgrade_interface_item_upgraded(item_field:UpgradableItem.UpgradeField)->void:
	_plane_upgrader.upgrade(item_field)
