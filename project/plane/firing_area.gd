class_name FiringArea
extends Area3D

@export var damage := 1.0
@export var distance := 100.0 : set = _set_distance
@export var radius := 1.0 : set = _set_radius

@onready var _collision_shape : CollisionShape3D = $CollisionShape3D


func _ready()->void:
	_update_collision_shape()


func shoot(shooter_index:int)->void:
	for body:PhysicsBody3D in get_overlapping_bodies():
		if body.has_method("damage"):
			body.damage(damage, shooter_index)


func has_targets()->bool:
	return get_overlapping_bodies().size() > 0


func _set_distance(value:float)->void:
	distance = value
	_update_collision_shape()


func _set_radius(value:float)->void:
	radius = value
	_update_collision_shape()


func _update_collision_shape()->void:
	var new_shape := CylinderShape3D.new()
	new_shape.height = distance
	new_shape.radius = radius
	_collision_shape.shape = new_shape
	_collision_shape.position.z = -distance / 2
