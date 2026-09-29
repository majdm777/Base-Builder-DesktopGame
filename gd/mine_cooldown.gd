extends Node3D

var marker: Marker3D
var marker_position: Vector3
var marker_script
var marker_group
var marker_resourcer_type


func _ready():
	marker = get_node_or_null("SpawnPoint")
	if marker == null:
		create_marker()
	marker_position = marker.position
	marker_script = marker.get_script()
	marker_group = marker.get_groups()
	marker_resourcer_type = marker.ResourceType
	marker.tree_exited.connect(_on_marker_freed)

func create_marker():
	marker = Marker3D.new()
	marker.set_script(marker_script)
	marker.add_to_group(marker_group[0])
	marker.name = "SpawnPoint"
	marker.amount = 20
	marker.ResourceType = marker_resourcer_type
	marker.position = marker_position
	add_child(marker)
	marker.tree_exited.connect(_on_marker_freed)

func _on_marker_freed():
	marker = null
	if !is_inside_tree():
		return
	await get_tree().create_timer(120.0).timeout

	if !is_inside_tree():
		return
	create_marker()
