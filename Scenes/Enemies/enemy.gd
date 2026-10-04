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

var current_state = State.Searching
var current_target = null


@onready var navigation : NavigationAgent3D = $NavigationAgent3D
const JUMP_VELOCITY = 4.5

var Targets :Array
func _ready() -> void:
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
