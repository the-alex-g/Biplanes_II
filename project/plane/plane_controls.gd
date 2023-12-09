class_name PlaneControls
extends Resource

const AXIS_DAMPER := 0.1

@export var thrust_axis := JOY_AXIS_TRIGGER_RIGHT
@export var yaw_axis := JOY_AXIS_LEFT_X
@export var pitch_axis := JOY_AXIS_RIGHT_Y

var player_index := -1


func get_pitch_axis()->float:
	return get_axis_strength(pitch_axis)


func get_yaw_axis()->float:
	return get_axis_strength(yaw_axis, true)


func get_thrust_axis()->float:
	return get_axis_strength(thrust_axis)


func get_axis_strength(axis:JoyAxis, invert := false)->float:
	var axis_strength := Input.get_joy_axis(player_index, axis)
	if invert:
		axis_strength *= -1
	if abs(axis_strength) > AXIS_DAMPER:
		return axis_strength
	return 0.0
