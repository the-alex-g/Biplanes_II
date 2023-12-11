class_name PlaneUpgrader
extends Resource

var plane : Biplane


func upgrade(item_name:String)->void:
	match item_name:
		"Max Speed":
			_upgrade_max_speed()


func _upgrade_max_speed()->void:
	plane.physics.max_forward_velocity += 5
