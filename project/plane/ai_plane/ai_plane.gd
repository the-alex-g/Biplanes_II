class_name AIPlane
extends CharacterBody3D
signal destroyed(destroyer_index)

const LENGTH := 7.0 # meters
const MESH_LENGTH := 10.0 # units
const MIN_ALTITUDE := 50.0
const CRUISING_ALTITUDE := 70
const MIN_Y_DISTANCE_TO_TARGET := 10.0
const MAX_VERTICAL_ANGLE := PI / 8
const COLOR := Color.SLATE_GRAY

@export var health := 6.0
@export var cooldown_time := 0.5

var physics := PlanePhysics.new()
var disabled := false
var _can_shoot := true
var _target : Biplane
var _target_altitude : float
var _global_delta : float

@onready var firing_area : FiringArea = $FiringArea
@onready var _cooldown_timer : Timer = $CooldownTimer
@onready var _front_arc : Area3D = $FrontArc


func _ready()->void:
	_set_color(COLOR)


func _physics_process(delta:float)->void:
	_global_delta = delta
	
	if disabled:
		return
	
	if global_position.y < MIN_ALTITUDE:
		_target_altitude = MIN_ALTITUDE
	elif _has_target():
		_target_altitude = _target.global_position.y
	else:
		_target_altitude = CRUISING_ALTITUDE
	
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


func _shoot()->void:
	firing_area.shoot(-1)
	_can_shoot = false
	_cooldown_timer.start(cooldown_time)
	
	await _cooldown_timer.timeout
	
	_can_shoot = true


func damage(amount:float, damager:int)->void:
	health -= amount
	if health <= 0.0:
		destroy(damager)


func destroy(destroyer:int)->void:
	if disabled:
		return
	
	destroyed.emit(destroyer)


func _reset()->void:
	disabled = false
	physics.reset()


func _resolve_collision(collision:KinematicCollision3D)->void:
	if collision != null:
		destroy(-1)
		if collision.get_collider().has_method("destroy"):
			collision.get_collider().destroy(-1)


func _set_color(value:Color)->void:
	var new_material := ShaderMaterial.new()
	new_material.shader = preload("res://plane/biplane.gdshader")
	new_material.set_shader_parameter("body_color", value)
	$MeshInstance3D.material_override = new_material


func _on_detection_area_body_entered(body:PhysicsBody3D)->void:
	if body is Biplane and _target == null:
		_set_target(body)


func _set_target(new_target:Biplane)->void:
	_target = new_target
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
