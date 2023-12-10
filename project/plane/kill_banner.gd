class_name KillBanner
extends TextureRect

var kills := 0
var color : Color

@onready var label : Label = $Label


func _ready()->void:
	self_modulate = color
	label.text = str(kills)
