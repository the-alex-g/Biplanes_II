class_name PlaneUpgrader
extends Resource

var plane : Biplane


func upgrade(item_field:UpgradableItem.UpgradeField)->void:
	match item_field:
		UpgradableItem.UpgradeField.MAX_SPEED:
			_upgrade_max_speed()
		UpgradableItem.UpgradeField.MIN_SPEED:
			_upgrade_min_speed()
		UpgradableItem.UpgradeField.ACCEL:
			_upgrade_accel()
		UpgradableItem.UpgradeField.TURN_ACCEL:
			_upgrade_turn_accel()
		UpgradableItem.UpgradeField.MAX_TURN_SPEED:
			_upgrade_max_turn_speed()
		UpgradableItem.UpgradeField.RANGE:
			_upgrade_range()


func _upgrade_max_speed()->void:
	plane.physics.max_forward_velocity += 5


func _upgrade_min_speed()->void:
	plane.physics.min_forward_velocity = clamp(plane.physics.min_forward_velocity + 5, 0.0, plane.physics.max_forward_velocity - 10)


func _upgrade_accel()->void:
	plane.physics.max_forward_accel += 1.0


func _upgrade_turn_accel()->void:
	plane.physics.max_turn_accel += 0.125


func _upgrade_max_turn_speed()->void:
	plane.physics.max_turn_velocity += TAU / 30


func _upgrade_range()->void:
	plane.firing_area.distance += 10
