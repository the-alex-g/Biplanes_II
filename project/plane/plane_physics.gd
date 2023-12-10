class_name PlanePhysics
extends Resource

const GRAVITY := 9.81
const MASS := 700.0

@export var max_forward_velocity := 45.0
@export var min_forward_velocity := 25.0
@export var max_forward_accel := 8.0

var forward_velocity := 0.0


func calculate_velocity(basis:Basis, thrust:float, delta:float)->Vector3:
	var directional_vectors := _get_directional_vectors(basis)
	var velocity := Vector3.ZERO
	
	var forward_accel := _calculate_forward_accel(thrust) * delta
	
	forward_velocity = clampf(forward_velocity + forward_accel, min_forward_velocity, max_forward_velocity)
	
	var distance_from_level := sin(directional_vectors.up.angle_to(Vector3.UP))
	var forward_vector : Vector3 = directional_vectors.forward * forward_velocity
	var lift_vector : Vector3 = directional_vectors.up * _calculate_lift(distance_from_level)
	
	velocity += forward_vector + lift_vector
	
	velocity.y = lerp(velocity.y - GRAVITY, min(0.0, velocity.y) - GRAVITY, distance_from_level)
	
	return velocity * delta


func _get_directional_vectors(basis:Basis)->Dictionary:
	var directional_vectors := {}
	directional_vectors.forward = -basis.z
	directional_vectors.up = basis.y
	return directional_vectors


func _calculate_lift(distance_from_level:float)->float:
	var lift := lerpf(0.0, GRAVITY * 2, forward_velocity / max_forward_velocity)
	lift *= lerpf(1.0, 0.5, distance_from_level)
	return lift


func _calculate_forward_accel(thrust:float)->float:
	return _calculate_engine_force(thrust) / MASS - _get_drag(max_forward_accel, max_forward_velocity, forward_velocity)


func _calculate_engine_force(thrust:float)->float:
	return lerp(0.0, max_forward_accel * MASS, thrust)


func _get_drag(accel:float, max_value:float, current:float)->float:
	return lerp(0.0, accel, pow(current / max_value, 2.0))
