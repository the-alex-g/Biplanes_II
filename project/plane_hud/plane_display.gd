class_name PlaneDisplay
extends Control

@export var plane : Biplane

@onready var _forward_speed_label : Label = $Readouts/ForwardSpeed
@onready var _altitude_label : Label = $Readouts/Altitude
@onready var _kill_banner_container : VBoxContainer = $KillBanners
@onready var _radar : Radar = $Readouts/Radar


func _ready()->void:
	_radar.plane = plane


func _process(_delta:float)->void:
	_forward_speed_label.text = "Forward Speed: " + str(round(plane.physics.forward_velocity))
	_altitude_label.text = "Altitude: " + str(round(plane.get_distance_from_ground()))


func update_kills(kills:Dictionary)->void:
	for banner in _kill_banner_container.get_children():
		banner.queue_free()
	for color:Color in kills:
		_add_kill_banner(color, kills[color])


func set_radar_planes(planes:Array[Biplane])->void:
	_radar.other_planes = planes


func _add_kill_banner(color:Color, kills:int)->void:
	var kill_banner : KillBanner = preload("res://plane/kill_banner.tscn").instantiate()
	kill_banner.color = color
	kill_banner.kills = kills
	_kill_banner_container.add_child(kill_banner)
