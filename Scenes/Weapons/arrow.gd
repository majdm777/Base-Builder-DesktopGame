class_name Arrow
extends Node3D

@export var speed := 40.0
@export var arc_height := 0

var target : Node3D
var shooter : Node3D
var damage := 10
var _start : Vector3
var _end : Vector3
var _progress := 0.0

func launch(from: Vector3, tgt: Node3D, dmg: int, who: Node3D) -> void:
	global_position = from
	_start = from
	_end = tgt.global_position + Vector3(0, 1.0, 0)
	target = tgt
	damage = dmg
	shooter = who

func _process(delta: float) -> void:
	if is_instance_valid(target):
		_end = target.global_position + Vector3(0, 1.0, 0)   # homing: always aims at the current position
	var dist := _start.distance_to(_end)
	_progress += speed * delta / max(dist, 0.1)
	var t : float = min(_progress, 1.0)

	var prev := global_position
	var pos := _start.lerp(_end, t)
	pos.y += sin(t * PI) * arc_height                         # the arc
	global_position = pos
	if prev.distance_to(pos) > 0.001:
		look_at(pos + (pos - prev))                           # point along the flight path

	if t >= 1.0:
		if is_instance_valid(target):
			target._damage(damage, shooter if is_instance_valid(shooter) else null)
		queue_free()
