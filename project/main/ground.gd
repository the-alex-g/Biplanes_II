@tool
class_name Ground
extends MeshInstance3D

@export var map_size := Vector2.ZERO
@export var detail := 32
@export var height := 10.0
@export var noise : FastNoiseLite
@export var generate : bool : set = _set_generate


func _ready()->void:
	_generate_map()


func _set_generate(_value:bool)->void:
	_generate_map()
	generate = false


func _generate_map()->void:
	noise.seed = randi()
	
	_create_ground_mesh(_get_textured_surface())
	_create_collision_shape()


func _create_ground_mesh(surface:Array)->void:
	var new_mesh := ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface)
	
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.FOREST_GREEN
	new_mesh.surface_set_material(0, material)
	
	mesh = new_mesh


func _get_textured_surface()->Array:
	var surface := _get_flat_mesh_surface()
	var new_verticies := _get_textured_surface_verticies(surface)
	surface[Mesh.ARRAY_VERTEX] = new_verticies
	surface[Mesh.ARRAY_NORMAL] = new_verticies
	return surface


func _get_flat_mesh_surface()->Array:
	var plane_mesh := PlaneMesh.new()
	plane_mesh.subdivide_depth = detail
	plane_mesh.subdivide_width = detail
	plane_mesh.size = map_size
	return plane_mesh.surface_get_arrays(0)


func _get_textured_surface_verticies(surface:Array)->PackedVector3Array:
	var textured_verticies : PackedVector3Array = []
	for vertex in surface[Mesh.ARRAY_VERTEX]:
		var new_vertex := Vector3(
			vertex.x,
			noise.get_noise_2d(vertex.x, vertex.z) * height,
			vertex.z
		)
		textured_verticies.append(new_vertex)
	return textured_verticies


func _create_collision_shape()->void:
	for child in get_children():
		child.queue_free()
	create_trimesh_collision()
