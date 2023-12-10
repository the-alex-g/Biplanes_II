class_name JoinBanner
extends TextureRect

@export var not_joined_color := Color(0.0, 0.0, 0.0, 0.5)

@onready var _check_mark : TextureRect = $Checkmark
@onready var _b_button : TextureRect = $HBoxContainer/BButton
@onready var _a_button : TextureRect = $HBoxContainer/AButton


func _ready()->void:
	_load_new_material()
	_check_mark.hide()
	_b_button.hide()
	_set_material_color(not_joined_color)


func _load_new_material()->void:
	var new_material := ShaderMaterial.new()
	new_material.shader = load("res://join_menu/join_banner.gdshader")
	material = new_material


func joined()->void:
	_b_button.show()


func left()->void:
	_set_material_color(not_joined_color)
	_b_button.hide()


func changed_color(new_color:Color)->void:
	_set_material_color(new_color)


func readied()->void:
	_a_button.hide()
	_check_mark.show()


func unreadied()->void:
	_a_button.show()
	_check_mark.hide()


func _set_material_color(new_color:Color)->void:
	material.set_shader_parameter("color", new_color)
