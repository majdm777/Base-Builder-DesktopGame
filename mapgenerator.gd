extends Node3D

@export var hex_mesh: Mesh
@export var map_width := 15
@export var map_height := 15
@export var hex_size := 1.5

func _ready():
	generate_map()

func generate_map():
	for q in range(map_width):
		for r in range(map_height):
			var tile = MeshInstance3D.new()
			tile.mesh = hex_mesh

			var x = 1.5 * hex_size * q
			var z = sqrt(3.0) * hex_size * (r + q / 2.0)

			tile.position = Vector3(x, 0, z)

			add_child(tile)
