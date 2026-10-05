extends CharacterBody3D


enum State{
	Walking,
	Searching,
	Attacking,
	Fighting
}

@export var SPEED = 5.0
@export var Hp := 100
@export var attack_range := 1.5
@export var attack_damage := 10
@export var attack_interval := 1.5

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

	if current_target == null:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
		return

	var dist_to_target := global_position.distance_to(current_target.global_position)

	if dist_to_target <= attack_range:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		_try_attack()
	elif navigation.is_navigation_finished() and dist_to_target > attack_range:
		# Nav thinks it's "finished" but we're not actually in range — no path exists
		_handle_no_path()
	else:
		var next_pos := navigation.get_next_path_position()
		var direction := (next_pos - global_position).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	move_and_slide()

func _process(delta: float) -> void:
	
	match current_state:
		State.Searching:
			_search()
			current_state = State.Walking
			pass
		State.Walking:
			
			pass
		State.Attacking:
			pass
		State.Fighting:
			pass
	pass
	

func _search() -> void:
	for group in Targets:
		var buildings = get_tree().get_nodes_in_group(group)
		if buildings.size > 0:
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

func _try_attack() -> void:
	if attacking:
		return
	attacking = true
	await get_tree().create_timer(attack_interval).timeout
	if is_instance_valid(current_target):
		print("Attacking ", current_target.name)
		# current_target.take_damage(attack_damage)  # once health exists (step 3)
		# check if target destroyed -> _pick_new_target()
	attacking = false
