class_name BuildingCatapult
extends BuildingDefense

const BALL := preload("res://Scenes/Weapons/ball.tscn")   
@export var min_range := 12.0          # a catapult can't hit what's right next to it
@export var splash_radius := 6.0
@export var ball_speed := 25.0
@export var Damage := 50
@export var rotation_offset: float = 35.0
var can_fire :bool = true

@onready var turret = $building_tower_catapult_blue/building_tower_catapult_blue/catapult_turret_blue

@onready var animator :AnimationPlayer = $building_tower_catapult_blue/AnimationPlayer

func _ready() -> void:
	super()
	
func get_dps() -> float:
	return Damage / max(0.1,attack_interval)
# prefer the enemy with the most neighbours inside the splash radius
func _pick_target() -> Node3D:
	var enemies : Array = []
	for body in detection_area.get_overlapping_bodies():
		if is_instance_valid(body) and body.is_in_group("Enemy") \
				and global_position.distance_to(body.global_position) >= min_range:
			enemies.append(body)

	var best : Node3D = null
	var best_score := -1
	for e in enemies:
		var score := 0
		for o in enemies:
			if e.global_position.distance_to(o.global_position) <= splash_radius:
				score += 1
		if score > best_score:
			best_score = score
			best = e
	return best

func _process(delta: float) -> void:
	super(delta)
	if current_target:
		var direction = current_target.global_position - turret.global_position
		var target_angle = atan2(direction.y, direction.x)

		turret.global_rotation.z = target_angle + deg_to_rad(rotation_offset)
		
func _attack() -> void:
	if not can_fire or not is_instance_valid(current_target):
		return
	can_fire = false

	animator.play("launch")
	await animator.animation_finished
	if not is_inside_tree():
		return

	# a lot can change during the animation, so check again before releasing
	_clean_occupants()
	if not occupants.is_empty():
		if not is_instance_valid(current_target):
			current_target = _pick_target()
		if current_target != null:
			_fire_ball()

	animator.play("re-load")
	can_fire = true


func _fire_ball() -> void:
	var from := global_position + Vector3(0, shoot_height, 0)
	var ball = BALL.instantiate()
	BuilderManager.map_root.add_child(ball)            # add first, then position
	ball.radius = splash_radius
	ball.speed = ball_speed
	ball.launch(from, _predict(current_target, from),
			Damage, self)

# aim where the enemy will be when the ball lands
func _predict(target: Node3D, from: Vector3) -> Vector3:
	var vel := Vector3.ZERO
	if "velocity" in target:
		vel = target.velocity
		vel.y = 0.0                                   # ignore gravity
	var pos := target.global_position
	for i in 3:
		var flight_time : float = from.distance_to(pos) / ball_speed
		pos = target.global_position + vel * flight_time
	return pos

func _can_fire() -> bool:
	return can_fire
