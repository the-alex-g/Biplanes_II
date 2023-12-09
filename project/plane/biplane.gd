class_name Biplane
extends CharacterBody3D

const LENGTH := 7.0 # meters
const MESH_LENGTH := 0.0 # units

@export var player_index := 0
@export var turn_speed := TAU / 4
@export_group("Controls")
@export var controls := PlaneControls.new()

var physics := PlanePhysics.new()


func _ready()->void:
	controls.player_index = player_index


func _physics_process(delta:float)->void:
	rotate_y(controls.get_yaw_axis() * delta * turn_speed)
	rotate_object_local(Vector3.RIGHT, controls.get_pitch_axis() * delta * turn_speed)
	
	var _collision := move_and_collide(physics.calculate_velocity(global_basis, controls.get_thrust_axis(), delta))
