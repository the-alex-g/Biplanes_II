class_name UpgradableItem
extends Resource

@export var name := ""
@export var starting_cost := 10
@export var cost_per_level := 10

var level := 0
var cost : int : get = _get_cost


func upgrade()->void:
	level += 1


func _get_cost()->int:
	return starting_cost + cost_per_level * level
