class_name Radar
extends Control

@export var bg_circle_color := Color.DARK_GREEN
@export var in_range_dot_color := Color.LAWN_GREEN
@export var out_of_range_dot_color := Color.RED
@export var border_color := Color.BLACK
@export var pointer_line_color := Color.WHITE
@export var max_range := 500.0
@export var radius := 50.0
@export var pointer_length := 6.0
@export var dot_radius := 3.0

var plane : Biplane
var other_planes : Array[PlaneRoot]

@onready var _circle_center := Vector2.ONE * radius


func _process(_delta:float)->void:
	queue_redraw()


func _draw()->void:
	_draw_radar_disk()
	_draw_dots()
	_draw_pointer()


func _draw_radar_disk()->void:
	draw_circle(_circle_center, radius, bg_circle_color)
	draw_circle(_circle_center, 5, border_color)
	draw_arc(_circle_center, radius, 0, TAU, 32, border_color, 2.0)


func _draw_pointer()->void:
	draw_line(_circle_center, _circle_center + _get_plane_direction_vector() * pointer_length, pointer_line_color, 2.0)


func _get_plane_direction_vector()->Vector2:
	var forward_vector := plane.physics.get_forward_vector(plane.global_transform)
	return Vector2(forward_vector.x, forward_vector.z).normalized().rotated(PI)


func _draw_dots()->void:
	for plane_position in _get_plane_positions():
		var dot_offset := _calculate_dot_offset(plane_position)
		if radius - dot_offset.length() < 1:
			draw_circle(_circle_center + dot_offset, dot_radius, out_of_range_dot_color)
		else:
			draw_circle(_circle_center + dot_offset, dot_radius, in_range_dot_color)


func _get_plane_positions()->PackedVector2Array:
	var positions : PackedVector2Array = []
	for other_plane:PlaneRoot in other_planes:
		if not other_plane.disabled:
			positions.append(Vector2(other_plane.global_position.x, other_plane.global_position.z))
	return positions


func _calculate_dot_offset(plane_position:Vector2)->Vector2:
	var plane_position_2d := Vector2(plane.global_position.x, plane.global_position.z)
	var distance := plane_position_2d.distance_to(plane_position)
	var direction := (plane_position_2d - plane_position).normalized()
	if distance < max_range:
		return direction * radius * distance / max_range
	return direction * radius
