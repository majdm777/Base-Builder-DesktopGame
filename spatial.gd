extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mesh_instance := $Map/terrain/MeshInstance3D
	print(mesh_instance.global_transform * mesh_instance.get_aabb())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
