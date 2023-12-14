class_name PlaneRoot
extends CharacterBody3D

signal destroyed(destroyer_index)

const LENGTH := 7.0 # meters
const MESH_LENGTH := 10.0 # units

@export var health := 6.0
@export var cooldown_time := 0.5
@export var player_index := -1 : set = _set_player_index

var physics := PlanePhysics.new()
var disabled := false
var color : Color : set = _set_color
var _can_shoot := true

@onready var firing_area : FiringArea = $FiringArea
@onready var _cooldown_timer : Timer = $CooldownTimer


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


func _resolve_collision(collision:KinematicCollision3D)->void:
	if collision != null:
		if not collision.get_collider().is_in_group("WorldBounds") or self is AIPlane:
			destroy(-1)
			if collision.get_collider().has_method("destroy"):
				collision.get_collider().destroy(-1)


func _set_player_index(value:int)->void:
	player_index = value


func _set_color(value:Color)->void:
	color = value
	var new_material := ShaderMaterial.new()
	new_material.shader = load("res://plane/biplane.gdshader")
	new_material.set_shader_parameter("body_color", color)
	$MeshInstance3D.material_override = new_material
