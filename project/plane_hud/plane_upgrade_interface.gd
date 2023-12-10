class_name PlaneUpgradeInterface
extends Control

signal launched

@export var player_index := -1
@export var launch_button := JOY_BUTTON_START


func _ready()->void:
	hide()


func _process(_delta:float)->void:
	if not visible:
		return
	
	if Input.is_joy_button_pressed(player_index, launch_button):
		launched.emit()
