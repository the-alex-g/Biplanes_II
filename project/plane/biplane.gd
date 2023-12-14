class_name Biplane
extends PlaneRoot

@export var controls := PlaneControls.new()

@onready var _ground_detector : RayCast3D = $GroundDetector


func _physics_process(delta:float)->void:
	if disabled:
		return
	
	_ground_detector.global_rotation = Vector3.ZERO
	
	rotate_y(physics.calculate_yaw_velocity(controls.get_yaw_axis(), delta))
	rotate_object_local(Vector3.RIGHT, physics.calculate_pitch_velocity(controls.get_pitch_axis(), delta))
	
	if controls.is_shoot_button_pressed() and _can_shoot:
		_shoot()
	
	var collision := move_and_collide(physics.calculate_velocity(global_basis, controls.get_thrust_axis(), delta))
	_resolve_collision(collision)


func get_distance_from_ground()->float:
	if _ground_detector.is_colliding():
		return global_position.y - _ground_detector.get_collision_point().y
	return 0.0


func _set_player_index(value:int)->void:
	print(player_index)
	player_index = value
	controls.player_index = player_index
