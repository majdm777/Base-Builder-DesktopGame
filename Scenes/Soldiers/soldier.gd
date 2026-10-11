class_name Soldier
extends CharacterBody3D

enum State {
	Idle,
	Walking,
	Attacking,
	Garrisoned,
	Dieing,
}

const JUMP_VELOCITY = 4.5

@export var SPEED := 17.0
@export var Health := 100

@export var attack_damage := 10
@export var attack_interval := 1.5

var attacking := false
var fighting := false
var is_alive :bool = true

var current_state = State.Idle
var current_target = null

@onready var attack_area : Area3D = $AttackRange
@onready var navigation : NavigationAgent3D = $NavigationAgent3D
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if current_state == State.Walking:
		if not navigation.is_navigation_finished():
			var targetPos = navigation.get_next_path_position()
			var direction = global_position.direction_to(targetPos)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func _process(delta: float) -> void:
	$Label3D.text = str(Health)
	match current_state :
		
		State.Idle:
			current_target = _enemy()
			if current_target != null:
				attacking = true
				current_state = State.Walking
				return
			current_target = _find_checkpoint()
			if current_target != null and current_target._reserve_slot():
				attacking = false
				current_state = State.Walking
				return
			pass
		
		State.Walking:
			if is_instance_valid(current_target):
				navigation.target_position = current_target.global_position
				if attacking:
					if _is_in_attack_range():
						current_state = State.Attacking
					elif navigation.is_navigation_finished():
						attacking = false
						current_state = State.Idle
					pass
				else:
					if navigation.is_navigation_finished():
						if is_instance_valid(current_target):
							if current_target._occupy(self) :
								current_state = State.Garrisoned
							else:
								current_state = State.Idle
			else:
				current_state = State.Idle
			pass
		
		State.Attacking:
			_Attack()
			pass
		
		State.Garrisoned:
			pass
		
		State.Dieing:
			pass
	pass


func _find_checkpoint() -> Node3D:
	var _CP :Node3D = null
	var space = 100
	for cp in get_tree().get_nodes_in_group("Post"):
		var remaining_spaces = cp.remaining_spots
		if remaining_spaces == 0:
			continue
		if remaining_spaces < space:
			space = remaining_spaces
			_CP = cp
	return _CP

func _enemy() -> Node3D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	return _find_nearest(enemies)
	
	
func _find_nearest(candidates: Array) -> Node3D:
	if candidates.size() <= 0:
		return null
	var nearest : Node3D = candidates[0]
	var nearest_dist := global_position.distance_to(nearest.global_position)
	for c in candidates:
		var d := global_position.distance_to(c.global_position)
		if d < nearest_dist:
			nearest = c
			nearest_dist = d
	return nearest

func _is_in_attack_range() -> bool:
	if current_target == null:
		return false
	for body in attack_area.get_overlapping_bodies():
		if body == current_target:
			return true
	return false

func _Attack() :
	
	if fighting:
		return
	fighting = true 
	if is_instance_valid(current_target):
		if current_target._damage(attack_damage , self):
			await get_tree().create_timer(attack_interval).timeout
		
	else:
		current_state= State.Idle
	fighting = false 

func on_post_lost():
	visible = true 
	current_state = State.Idle
	
func _damage(value : int , entity : Node3D) -> bool:
	Health -= value
	if Health <= 0:
		queue_free()
		return false
	return true
