extends SubViewportContainer

@onready var pivot : Node3D = $Viewport/Pivot
@onready var cam : Camera3D = $Viewport/Camera3D

const SPIN_SPEED := 0.6

# returns false when the node has no visible meshes
func show_node(node: Node3D) -> bool:
	clear()
	if not is_instance_valid(node) or not node.is_inside_tree():
		return false

	var found : Array = []
	_collect_meshes(node, found)
	if found.is_empty():
		return false

	var inv := node.global_transform.affine_inverse()
	var bounds := AABB()
	var first := true
	var entries : Array = []
	for m : MeshInstance3D in found:
		var rel : Transform3D = inv * m.global_transform
		var box : AABB = rel * m.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
		entries.append({"mesh": m, "rel": rel})

	var center := bounds.get_center()
	for e in entries:
		var src : MeshInstance3D = e.mesh
		var copy := MeshInstance3D.new()
		copy.mesh = src.mesh
		copy.material_override = src.material_override
		for s in src.mesh.get_surface_count():
			var mat := src.get_surface_override_material(s)
			if mat:
				copy.set_surface_override_material(s, mat)
		var t : Transform3D = e.rel
		t.origin -= center
		copy.transform = t
		pivot.add_child(copy)

	var radius : float = max(bounds.size.length() * 0.5, 0.5)
	var dist : float = radius / tan(deg_to_rad(cam.fov * 0.5)) * 1.15
	cam.look_at_from_position(Vector3(0, radius * 0.5, dist), Vector3.ZERO)
	pivot.rotation = Vector3.ZERO
	return true

func clear() -> void:
	for c in pivot.get_children():
		c.queue_free()

func _collect_meshes(n: Node, out: Array) -> void:
	for c in n.get_children():
		if c is Area3D:
			continue
		if c is MeshInstance3D and c.visible and c.mesh != null:
			out.append(c)
		_collect_meshes(c, out)

func _process(delta: float) -> void:
	if visible and is_visible_in_tree():
		pivot.rotation.y += SPIN_SPEED * delta
