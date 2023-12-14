class_name AIPlane
extends PlaneRoot

const MIN_ALTITUDE := 50.0
const MIN_Y_DISTANCE_TO_TARGET := 10.0
const COLOR := Color.SLATE_GRAY

var _target : Biplane
var _target_altitude : float
var _global_delta : float
var _cruising_altitude := 100.0

@onready var _front_arc : Area3D = $FrontArc


func _ready()->void:
	_set_color(COLOR)
	_cruising_altitude = lerpf(MIN_ALTITUDE * 2, 300.0, randf())


func _physics_process(delta:float)->void:
	_global_delta = delta
	
	if disabled:
		return
	
	if global_position.y < MIN_ALTITUDE:
		_target_altitude = MIN_ALTITUDE
	elif _has_target():
		_target_altitude = _target.global_position.y
	else:
		_target_altitude = _cruising_altitude
	
	if abs(_distance_from_target_altitude()) > 5.0:
		_turn_towards_target_altitude()
	else:
		_pitch(0.0)
	
	if _has_target():
		_yaw_towards_target()
	else:
		_yaw(0.0)
	
	if _can_shoot and firing_area.has_targets():
		print("BANG BBANG")
		_shoot()
	
	var collision := move_and_collide(physics.calculate_velocity(global_basis, _get_thrust(), delta))
	_resolve_collision(collision)


func _get_yaw_direction_to_target()->float:
	return sign(global_position.signed_angle_to(_target.global_position, Vector3.UP) + global_rotation.y)


func _get_pitch_strength_to_target()->float:
	if abs(_target.global_position.y - global_position.y) > MIN_Y_DISTANCE_TO_TARGET:
		if _target.global_position.y > global_position.y:
			return -1.0
		return 1.0
	return 0.0


func _get_thrust()->float:
	if _target != null:
		return 1.0
	return 0.0


func reset()->void:
	_target = null
	super.reset()


func _on_detection_area_body_entered(body:PhysicsBody3D)->void:
	if body is Biplane and _target == null:
		_set_target(body)


func _set_target(value:Biplane)->void:
	_target = value
	if _target != null:
		if not _target.is_connected("destroyed", _on_target_destroyed):
			_target.connect("destroyed", _on_target_destroyed, CONNECT_ONE_SHOT)


func _on_target_destroyed(_destroyer:int)->void:
	_target = null


func _get_percent_pitch_velocity()->float:
	return physics.pitch_velocity / physics.max_turn_velocity


func _distance_from_target_altitude()->float:
	return global_position.y - _target_altitude


func _turn_towards_target_altitude()->void:
	if _distance_from_target_altitude() < 0.0:
		if _get_angle_from_level() < 0.0:
			_pitch(1.0)
		else:
			_pitch(0.0)
	else:
		if _get_angle_from_level() > -0.1:
			_pitch(-1.0)
		else:
			_pitch(0.0)


func _pitch(strength:float)->void:
	rotate_object_local(Vector3.RIGHT, physics.calculate_pitch_velocity(strength, _global_delta))


func _get_angle_from_level()->float:
	return asin(physics.get_forward_vector(global_transform).y)


func _has_target()->bool:
	return is_instance_valid(_target)


func _yaw_towards_target()->void:
	if not _is_target_in_front_arc():
		_yaw(1.0)


func _is_target_in_front_arc()->bool:
	return _front_arc.get_overlapping_bodies().has(_target)


func _yaw(strength:float)->void:
	rotate_y(physics.calculate_yaw_velocity(strength, _global_delta))


func _on_detection_area_body_exited(body:PhysicsBody3D)->void:
	if body == _target:
		_set_target(null)
