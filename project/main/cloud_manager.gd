class_name CloudManager
extends Node

const PATH_TO_CLOUD := "res://main/cloud.tscn"

@export var cloud_speed := 5.0
@export var board_size := Vector3(1000, 500, 1000)

var _wind_direction := randf() * TAU


func _ready()->void:
	_add_timer(_change_wind_direction, 0.5, 2.0)
	_add_timer(_add_cloud, 10.0, 30.0)
	for _i:int in randi_range(3, 6):
		_add_cloud()


func _process(delta:float)->void:
	_move_clouds(delta)


func _add_timer(bind:Callable, min_wait:float, max_wait:float)->void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(min_wait, max_wait))
	timer.timeout.connect(bind)
	
	while timer.is_inside_tree():
		await timer.timeout
		timer.start(randf_range(min_wait, max_wait))


func _change_wind_direction()->void:
	_wind_direction += randf() - 0.5


func _move_clouds(delta:float)->void:
	for cloud:Cloud in get_tree().get_nodes_in_group("Cloud"):
		cloud.global_position += Vector3.FORWARD.rotated(Vector3.UP, _wind_direction) * cloud_speed * delta
		_cull_cloud(cloud)


func _cull_cloud(cloud:Cloud)->void:
	if cloud.global_position.x > board_size.x / 2 or cloud.global_position.z > board_size.z / 2:
		cloud.fade_out()


func _add_cloud()->void:
	var cloud := preload(PATH_TO_CLOUD).instantiate()
	add_child(cloud)
	cloud.global_position = _get_starting_cloud_position()
	cloud.start_emitting()


func _get_starting_cloud_position()->Vector3:
	var starting_position := Vector3.ZERO
	starting_position.y = lerpf(200.0, board_size.y - 50.0, randf())
	starting_position.x = board_size.x / 2
	starting_position.z = lerpf(-board_size.z / 2, board_size.z / 2, randf())
	return starting_position.rotated(Vector3.UP, TAU * randi_range(0, 3) / 4)
