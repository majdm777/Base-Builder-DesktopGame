class_name CatapultBall
extends Node3D

@export var speed := 25.0
@export var arc_height := 12.0
@export var radius := 6.0            # splash radius
@export var edge_damage := 0.4       # damage multiplier at the very edge (1.0 = no falloff)

var damage := 50
var shooter : Node3D
var _start : Vector3
var _end : Vector3                   # fixed at launch, never updated
var _progress := 0.0
var _landed := false

@onready var area : Area3D = $Area


func _ready() -> void:
	area.monitoring = false          # off while flying, so it costs nothing


func launch(from: Vector3, to: Vector3, dmg: int, who: Node3D) -> void:
	global_position = from
	_start = from
	_end = to
	damage = dmg
	shooter = who


func _physics_process(delta: float) -> void:      # physics, so the area moves with the physics world
	if _landed:
		return
	var dist : float = max(_start.distance_to(_end), 0.1)
	_progress += speed * delta / dist
	var t : float = min(_progress, 1.0)

	var pos := _start.lerp(_end, t)
	pos.y += sin(t * PI) * arc_height
	global_position = pos

	if t >= 1.0:
		_landed = true
		_explode()


func _explode() -> void:
	global_position = _end

	# a new shape per ball, so changing the radius never affects other balls
	var shape := SphereShape3D.new()
	shape.radius = radius
	$Area/CollisionShape3D.shape = shape
	area.monitoring = true

	await get_tree().physics_frame        # let the physics server register the area
	await get_tree().physics_frame

	var who = shooter if is_instance_valid(shooter) else null
	for body in area.get_overlapping_bodies():
		if not is_instance_valid(body) or not body.is_in_group("Enemy"):
			continue
		# distance from the center, flat, so height doesn't matter
		var d := Vector2(body.global_position.x - _end.x, body.global_position.z - _end.z).length()
		var mult : float = lerp(1.0, edge_damage, clamp(d / radius, 0.0, 1.0))
		body._damage(int(damage * mult), who)

	queue_free()                          # last, after all the damage is applied
