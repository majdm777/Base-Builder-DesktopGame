

extends Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


@export var move_speed := 500.0
@export var edge_size := 200

func _process(delta):
	var viewport_size = get_viewport().size
	var mouse_pos = get_viewport().get_mouse_position()

	# Left / Right
	if mouse_pos.x <= edge_size:
		global_position -= global_transform.basis.x *move_speed * delta
	elif mouse_pos.x >= viewport_size.x - edge_size:
		global_position += global_transform.basis.x * move_speed * delta

	# Top / Bottom
	if mouse_pos.y <= edge_size:
		global_position -= global_transform.basis.z * move_speed * delta
	elif mouse_pos.y >= viewport_size.y - edge_size:
		global_position +=global_transform.basis.z * move_speed * delta
	
	if Input.is_action_just_released("middleMouseButton"):
		rotation_degrees += Vector3(0,90,0)
	if Input.is_action_just_released("MouseWheelUp"):
		if $Camera3D.global_position.distance_to(global_position) > 700:
			$Camera3D.global_position-= $Camera3D.global_transform.basis.z * 10
	if Input.is_action_just_released("MouseWheelDown"):
		if $Camera3D.global_position.distance_to(global_position) < 1500:
			$Camera3D.global_position+= $Camera3D.global_transform.basis.z * 10
	pass
