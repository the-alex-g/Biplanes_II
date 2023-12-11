class_name Biplane
extends CharacterBody3D

signal destroyed(destroyer_index)

const LENGTH := 7.0 # meters
const MESH_LENGTH := 10.0 # units

@export var player_index := 0 : set = _set_player_index
@export var health := 6.0
@export var cooldown_time := 0.5
@export_group("Controls")
@export var controls := PlaneControls.new()

var physics := PlanePhysics.new()
var disabled := false
var color : Color : set = _set_color
var _can_shoot := true

@onready var firing_area : FiringArea = $FiringArea
@onready var _cooldown_timer : Timer = $CooldownTimer
@onready var _ground_detector : RayCast3D = $GroundDetector


func _ready()->void:
	controls.player_index = player_index


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


func _shoot()->void:
	firing_area.shoot(player_index)
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


func reset()->void:
	disabled = false
	physics.reset()


func get_distance_from_ground()->float:
	if _ground_detector.is_colliding():
		return global_position.y - _ground_detector.get_collision_point().y
	return 0.0


func _resolve_collision(collision:KinematicCollision3D)->void:
	if collision != null:
		destroy(-1)
		if collision.get_collider().has_method("destroy"):
			collision.get_collider().destroy(-1)


func _set_player_index(value:int)->void:
	player_index = value
	controls.player_index = player_index


func _set_color(value:Color)->void:
	color = value
	var new_material := StandardMaterial3D.new()
	new_material.albedo_color = color
	$MeshInstance3D.material_override = new_material
