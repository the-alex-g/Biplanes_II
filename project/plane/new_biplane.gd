extends CharacterBody3D

const AXIS_DAMPER := 0.1
const LENGTH := 7.0 # meters
const MESH_LENGTH := 0.0 # units

@export var player_index := 0
@export_group("Controls")
@export var thrust_axis := JOY_AXIS_TRIGGER_RIGHT
@export var yaw_axis := JOY_AXIS_LEFT_X
@export var pitch_axis := JOY_AXIS_RIGHT_Y

var _physics := PlanePhysics.new()


func _physics_process(delta:float)->void:
	rotate_y(_get_axis_strength(yaw_axis, true) * delta * TAU / 4)
	rotate_object_local(Vector3.RIGHT, _get_axis_strength(pitch_axis) * delta * TAU / 4)
	
	move_and_collide(_physics.calculate_velocity(global_basis, _get_axis_strength(thrust_axis), delta))


func _get_axis_strength(axis:JoyAxis, invert := false, dampen := true)->float:
	var axis_strength := Input.get_joy_axis(player_index, axis)
	if invert:
		axis_strength *= -1
	if dampen:
		if abs(axis_strength) > AXIS_DAMPER:
			return axis_strength
		return 0.0
	return axis_strength
