class_name UpgradableItem
extends Resource

enum UpgradeField {MAX_SPEED, MIN_SPEED, ACCEL, TURN_ACCEL, MAX_TURN_SPEED, RANGE}

@export var name := ""
@export var starting_cost := 1
@export var cost_per_level := 5
@export var upgrade_field : UpgradeField

var level := 0
var cost : int : get = _get_cost


func upgrade()->void:
	level += 1


func _get_cost()->int:
	return starting_cost + cost_per_level * level
