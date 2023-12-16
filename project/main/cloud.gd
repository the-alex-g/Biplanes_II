class_name Cloud
extends Area3D

@onready var _particles : CPUParticles3D = $CPUParticles3D


func fade_out()->void:
	_particles.emitting = false


func start_emitting()->void:
	_particles.emitting = true


func _on_cpu_particles_3d_finished():
	queue_free()


func _on_body_entered(body:PhysicsBody3D)->void:
	if body is PlaneRoot:
		body.conceal(self)


func _on_body_exited(body:PhysicsBody3D)->void:
	if body is PlaneRoot:
		body.reveal(self)
