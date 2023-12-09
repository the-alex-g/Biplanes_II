extends Control

@export var plane : Biplane

@onready var _forward_speed_label : Label = $Readouts/ForwardSpeed
@onready var _altitude_label : Label = $Readouts/Altitude


func _process(_delta:float)->void:
	_forward_speed_label.text = "Forward Speed: " + str(round(plane.physics.forward_velocity))
	_altitude_label.text = "Altitude: " + str(round(plane.global_position.y))
