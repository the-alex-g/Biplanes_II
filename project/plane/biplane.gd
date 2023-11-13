class_name Biplane
extends CharacterBody3D

const GRAVITY := 9.81
const AXIS_DAMPER := 0.1

@export var player_index := 0
@export var mass := 700.0
@export var max_speed := 45.0
@export var min_air_speed := 30
@export var linear_acceleration := 5.0
@export_group("Controls")
@export var thrust_axis := JOY_AXIS_TRIGGER_RIGHT
@export var yaw_axis := JOY_AXIS_LEFT_X
@export var pitch_axis := JOY_AXIS_RIGHT_Y

var _current_speed := 45.0
var _vertical_velocity := 0.0

@onready var _initial_mass := mass


func _physics_process(delta:float)->void:
	var thrust_velocity := (_get_thrust_force() / mass) * delta
	_current_speed += thrust_velocity
	
	rotate_y(_get_axis_strength(yaw_axis, true) * delta * TAU / 4)
	rotate_object_local(Vector3.RIGHT, _get_axis_strength(pitch_axis) * delta * TAU / 4)
	
	var directional_vectors := _get_directional_vectors()
	var forward_velocity : Vector3 = directional_vectors.forward * _current_speed
#	var lift_accel := _get_lift_force() / mass
#	var lift_vector : Vector3 = directional_vectors.up * lift_accel
#	var vertical_lift := lift_vector.y
	
#	lift_vector.y = 0
	var vertical_acceleration := _get_lift_force() * cos(rotation.x) / mass - GRAVITY
	_vertical_velocity += vertical_acceleration * delta
	
	var total_velocity := forward_velocity + Vector3.UP * _vertical_velocity# + lift_vector
	
	print(_current_speed, ", ", total_velocity.y, ", ", vertical_acceleration)
	
	move_and_collide(total_velocity * delta)


func _get_directional_vectors()->Dictionary:
	var global_basis := global_transform.basis
	var directional_vectors := {}
	directional_vectors.forward = -global_basis.z
	directional_vectors.up = global_basis.y
	return directional_vectors


func _get_thrust_force()->float:
	var thrust_strength := _get_axis_strength(thrust_axis, false, false)
	var thrust_force : float = lerp(0.0, linear_acceleration * _initial_mass, thrust_strength)
	thrust_force -= _get_drag_force(linear_acceleration, max_speed, _current_speed)
	return thrust_force


func _get_lift_force()->float:
	return lerp(0.0, GRAVITY * _initial_mass, _current_speed / min_air_speed)


func _get_axis_strength(axis:JoyAxis, invert := false, dampen := true)->float:
	var axis_strength := Input.get_joy_axis(player_index, axis)
	if invert:
		axis_strength *= -1
	if dampen:
		if abs(axis_strength) > AXIS_DAMPER:
			return axis_strength
		return 0.0
	return axis_strength


func _get_drag_force(accel:float, max_value:float, current:float)->float:
	return lerp(0.0, accel * _initial_mass, pow(current / max_value, 2.0))
