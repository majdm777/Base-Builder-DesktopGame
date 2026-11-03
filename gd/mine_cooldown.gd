extends Node3D

var marker: Marker3D
var marker_position: Vector3
var marker_script
var marker_group
var marker_resourcer_type

@onready var cooldown_timer := Timer.new()

@export var COOLDOWN := 120

signal SpawnPoint_ready()

func _ready():
	marker = get_node_or_null("SpawnPoint")
	if marker == null:
		create_marker()
	marker_position = marker.position
	marker_script = marker.get_script()
	marker_group = marker.get_groups()
	marker_resourcer_type = marker.ResourceType
	marker.tree_exited.connect(_on_marker_freed)
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = COOLDOWN
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	

func create_marker():
	marker = Marker3D.new()
	marker.set_script(marker_script)
	marker.add_to_group(marker_group[0])
	marker.name = "SpawnPoint"
	marker.amount = 20
	marker.ResourceType = marker_resourcer_type
	marker.position = marker_position
	add_child(marker)
	SpawnPoint_ready.emit()
	marker.tree_exited.connect(_on_marker_freed)

func _on_marker_freed():
	marker = null
	if !is_inside_tree():
		return
	cooldown_timer.start()

func _on_cooldown_timer_timeout():
	if !is_inside_tree():
		return
	create_marker()
	pass
