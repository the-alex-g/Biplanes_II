class_name PlanePhysics
extends Resource

const GRAVITY := 9.81
const MASS := 700.0

@export var max_forward_velocity := 45.0
@export var max_forward_accel := 10.0
@export_range(GRAVITY, INF) var max_lift := 10.0
@export_range(GRAVITY / 2, INF) var min_lift := GRAVITY

var vertical_velocity := 0.0
var forward_velocity := 0.0


func calculate_velocity(basis:Basis, thrust:float, delta:float)->Vector3:
	var directional_vectors := _get_directional_vectors(basis)
	var velocity := Vector3.ZERO
	
	var forward_accel := _calculate_forward_accel(thrust) * delta
	
	forward_velocity += forward_accel
	vertical_velocity -= GRAVITY * delta
	
	var forward_vector : Vector3 = directional_vectors.forward * forward_velocity
	var lift_vector : Vector3 = directional_vectors.up * _calculate_lift() * delta
	
	vertical_velocity += directional_vectors.forward.y * _calculate_engine_force(thrust) * delta / MASS + lift_vector.y
	forward_vector.y = 0
	lift_vector.y = 0
	
	velocity += forward_vector + lift_vector + Vector3.UP * vertical_velocity
	
	return velocity


func _get_directional_vectors(basis:Basis)->Dictionary:
	var directional_vectors := {}
	directional_vectors.forward = -basis.z
	directional_vectors.up = basis.y
	return directional_vectors


func _calculate_lift()->float:
	return lerp(min_lift, max_lift, forward_velocity / max_forward_velocity)


func _calculate_forward_accel(thrust:float)->float:
	return _calculate_engine_force(thrust) / MASS - _get_drag(max_forward_accel, max_forward_velocity, forward_velocity)


func _calculate_engine_force(thrust:float)->float:
	return lerp(0.0, max_forward_accel * MASS, thrust)


func _get_drag(accel:float, max_value:float, current:float)->float:
	return lerp(0.0, accel, pow(current / max_value, 2.0))
