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
@export var soldier :String = "Knight"
@export var post_groups : Array[String] = ["Post"]

@export var attack_damage := 10
@export var attack_interval := 1.5

var chasing_enemy := false
var cooldown := false
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
				chasing_enemy = true
				navigation.target_position = current_target.global_position
				current_state = State.Walking
				return
			current_target = _find_post()
			if current_target != null and current_target._reserve_slot():
				chasing_enemy = false
				navigation.target_position = current_target.global_position
				current_state = State.Walking
				return
			pass
		
		State.Walking:
			if is_instance_valid(current_target):
				if chasing_enemy:
					navigation.target_position = current_target.global_position
					if _is_in_attack_range():
						current_state = State.Attacking
					elif navigation.is_navigation_finished():
						chasing_enemy = false
						current_state = State.Idle
					pass
				else:
					if navigation.is_navigation_finished():
						if is_instance_valid(current_target):
							if current_target._occupy(self) :
								current_state = State.Garrisoned
								#visible = false
								return
							else:
								current_state = State.Idle
			else:
				current_state = State.Idle
			pass
		
		State.Attacking:
			if not is_instance_valid(current_target):
				current_state = State.Idle
			elif not _is_in_attack_range():
				current_state = State.Walking   # chase again
			else:
				_Attack()
		
		State.Garrisoned:
			pass
		
		State.Dieing:
			pass
	pass


func _find_post() -> Node3D:
	for group in post_groups:
		var best : Node3D = null
		var best_free := 0
		for p in get_tree().get_nodes_in_group(group):
			if is_instance_valid(p) and p.remaining_spots > best_free:
				best_free = p.remaining_spots
				best = p
		if best != null:
			return best
	return null

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
	
	if cooldown:
		return
	cooldown = true 
	if is_instance_valid(current_target):
		if current_target._damage(attack_damage , self):
			await get_tree().create_timer(attack_interval).timeout
		
	else:
		current_state= State.Idle
	cooldown = false 

func on_post_lost():
	visible = true 
	current_state = State.Idle
	
func _damage(value : int , entity : Node3D) -> bool:
	Health -= value
	if Health <= 0:
		is_alive = false
		GameManager.Soldiers[soldier] -= 1
		queue_free()
		return false
	return true

#func _die() -> void:
	#if not is_alive:
		#return
	#is_alive = false
	#current_state = State.Dieing
	#if is_instance_valid(post):
		#if post.occupants.has(self):
			#post._leave(self)
		#else:
			#post._cancel_reservation()
	#GameManager.army[soldier_type] -= 1
	#queue_free()
