extends CharacterBody3D


enum State{
	Walking,
	Searching,
	Attacking,
	Fighting
}

@export var SPEED = 5.0
@export var Hp := 100
@export var attack_range := 10
@export var attack_damage := 50
@export var attack_interval := 1

var attacking := false

var current_state = State.Searching
var current_target = null


@onready var navigation : NavigationAgent3D = $NavigationAgent3D
const JUMP_VELOCITY = 4.5

var Targets :Array
func _ready() -> void:
	#castle = get_tree().get_first_node_in_group("Castle")
	#_pick_new_target()
	Targets = ["building"]

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
	$Label3D.text = str(current_state)
	match current_state:
		State.Searching:
			_search()
			current_state = State.Walking
			pass
		State.Walking:
			if is_instance_valid(current_target):
				var dist_to_target := global_position.distance_to(current_target.global_position)
				if dist_to_target <= attack_range:
					current_state = State.Attacking
				elif navigation.is_navigation_finished() and dist_to_target > attack_range:
					print("no path")
					_handle_no_path()
					pass
			else:
				current_state = State.Searching
			pass
		State.Attacking:
			if attacking:
				return
			print("attacking",attacking)
			attacking = true
			if is_instance_valid(current_target):
				current_target._damage(attack_damage,self)
				await get_tree().create_timer(attack_interval).timeout
			else:
				current_state = State.Searching
			attacking= false
			pass
		State.Fighting:
			pass
	pass
	

func _search() -> void:
	for group in Targets:
		var buildings = get_tree().get_nodes_in_group(group)
		if buildings.size() > 0:
			current_target = _find_nearest(buildings)
			navigation.target_position = current_target.global_position
			return 
	return 
	
	
	
func _find_nearest(candidates: Array) -> Node3D:
	var nearest : Node3D = candidates[0]
	var nearest_dist := global_position.distance_to(nearest.global_position)
	for c in candidates:
		var d := global_position.distance_to(c.global_position)
		if d < nearest_dist:
			nearest = c
			nearest_dist = d
	return nearest

func _handle_no_path() -> void:
	var walls := get_tree().get_nodes_in_group("Wall")
	if walls.size() > 0:
		current_target = _find_nearest(walls)
		navigation.target_position = current_target.global_position
	# else: genuinely stuck, nothing we can do — shouldn't normally happen

func _damage(value : int , entity : Node3D) -> bool:
	Hp -= value
	if Hp <= 0:
		queue_free()
		return false
	current_target = entity
	navigation.target_position = current_target.global_position
	current_state = State.Walking
	return true
