extends CharacterBody3D


enum Task {
	GettingResources,
	Searching,
	Walking,
	Delivering
}


var CurrentTask: Task = Task.Searching

var Hut
var HeldresourcesAmount: int = 0

var runOnce := true
@onready var navigationAgent: NavigationAgent3D = $NavigationAgent3D


const SPEED = 10.0


func _ready() -> void:
	# Optional: start searching when spawned
	
	CurrentTask = Task.Searching

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	# NPC movement
	if CurrentTask == Task.Walking:
		if not navigationAgent.is_navigation_finished():
			var targetPos = navigationAgent.get_next_path_position()
			var direction = global_position.direction_to(targetPos)
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			# Stop when reaching destination
			velocity.x = 0
			velocity.z = 0
	else:
		# Stop if not walking
		velocity.x = 0
		velocity.z = 0


	move_and_slide()



func _process(delta: float) -> void:

	match CurrentTask:
		Task.GettingResources:
			if runOnce:
				runOnce = false
				# Simulate collecting resources
				await get_tree().create_timer(2.0).timeout
				HeldresourcesAmount = 5
				runOnce = true
				CurrentTask = Task.Delivering

		Task.Delivering:
			if Hut != null:
				navigationAgent.target_position = Hut
				CurrentTask = Task.Walking

		Task.Searching:
			var resources = get_tree().get_nodes_in_group("Tree")
			if resources.size() > 0:
				var closest_tree = resources[0]
				navigationAgent.target_position = closest_tree.global_position
				CurrentTask = Task.Walking

		Task.Walking:
			if navigationAgent.is_navigation_finished():
				if HeldresourcesAmount == 0:
					CurrentTask = Task.GettingResources
				else:
					GameManager.Wood += HeldresourcesAmount
					HeldresourcesAmount = 0
					if runOnce:
						runOnce = false
						# Simulate collecting resources
						await get_tree().create_timer(2.0).timeout
						runOnce = true
					CurrentTask = Task.Searching
	$Label3D.text = str(CurrentTask)
