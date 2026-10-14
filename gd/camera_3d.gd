extends Node3D

@export var move_speed := 100.0
@export var edge_size := 20.0      # width of the scroll zone in pixels

@export var min_x := -150.0
@export var max_x := 150.0
@export var min_z := -154.0
@export var max_z := 154.0


func _mouse_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null


func _process(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var mouse_pos := get_viewport().get_mouse_position()
	var over_ui := _mouse_over_ui()

	# ---- Edge scrolling: slow at the start of the zone, full speed at the very edge ----
	var dir := Vector2.ZERO

	if mouse_pos.x < edge_size:
		dir.x = -(1.0 - mouse_pos.x / edge_size)
	elif mouse_pos.x > viewport_size.x - edge_size:
		dir.x = (mouse_pos.x - (viewport_size.x - edge_size)) / edge_size

	if mouse_pos.y < edge_size:
		dir.y = -(1.0 - mouse_pos.y / edge_size)
	elif mouse_pos.y > viewport_size.y - edge_size:
		dir.y = (mouse_pos.y - (viewport_size.y - edge_size)) / edge_size

	dir = dir.clamp(Vector2(-1, -1), Vector2(1, 1))
	global_position += global_transform.basis.x * dir.x * move_speed * delta
	global_position += global_transform.basis.z * dir.y * move_speed * delta

	# ---- Rotate and zoom (blocked while the mouse is over the UI) ----
	if Input.is_action_just_released("middleMouseButton") and not over_ui:
		rotation_degrees += Vector3(0, 90, 0)

	if Input.is_action_just_released("MouseWheelUp") and not over_ui:
		if $Camera3D.global_position.distance_to(global_position) > 45:
			$Camera3D.global_position -= $Camera3D.global_transform.basis.z * 10

	if Input.is_action_just_released("MouseWheelDown") and not over_ui:
		if $Camera3D.global_position.distance_to(global_position) < 200:
			$Camera3D.global_position += $Camera3D.global_transform.basis.z * 10

	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.z = clamp(global_position.z, min_z, max_z)
