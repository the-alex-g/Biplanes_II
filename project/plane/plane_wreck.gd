class_name PlaneWreck
extends CharacterBody3D

const GRAVITY := 9.81
const VELOCITY := 30.0

var color : Color
var direction : Vector3
var on_fire_progress := 0.0
var is_on_fire := false
var exploding_progress := 0.0

@onready var _spin_speed_factor := (randf() - 0.5) * TAU / 6
@onready var _spin := _get_spin_vector()
@onready var _mesh : MeshInstance3D = $MeshInstance3D


func _ready()->void:
	var new_material := StandardMaterial3D.new()
	new_material.albedo_color = color
	_mesh.material_override = new_material


func _physics_process(delta:float)->void:
	_mesh.rotation += _spin * _spin_speed_factor * delta
	var movement_vector := direction * VELOCITY
	movement_vector.y = -GRAVITY - min(movement_vector.y, 0.0)
	var collision := move_and_collide(movement_vector * delta)
	_resolve_collision(collision)
	_process_fire()


func _process_fire()->void:
	if not is_on_fire:
		if randi() % 2 == 0:
			on_fire_progress += 1
		if on_fire_progress >= 100:
			is_on_fire = true
			$CPUParticles3D.emitting = true
	else:
		if randi() % 2 == 0:
			exploding_progress += 1
		if exploding_progress >= 100:
			_explode()


func _get_spin_vector()->Vector3:
	return Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5) * 2.0


func _resolve_collision(collision:KinematicCollision3D)->void:
	if collision != null:
		_explode()
		if collision.get_collider().has_method("destroy"):
			collision.get_collider().destroy(-1)


func _explode()->void:
	var explosion : PlaneExplosion = load("res://plane/plane_explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	queue_free()


func destroy(_destroyer_index:int)->void:
	_explode()
