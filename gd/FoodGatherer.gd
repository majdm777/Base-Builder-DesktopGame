extends CharacterBody3D


enum Task {
	GettingFood,
	Searching,
	Walking,
	Delivering
}

var FoodProducers : Array
var foodIndex : int


var CurrentTask: Task = Task.Searching

var Hut
var HeldresourcesAmount: int = 0

@export var ResourceGenerationAmount :=0


var runOnce := true
@onready var navigationAgent: NavigationAgent3D = $NavigationAgent3D


@export var SPEED = 10.0


func _ready() -> void:
	# Optional: start searching when spawned
	FoodProducers = Hut.get_node("Resources").get_children()
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
	var spawnedGranery = []
	var checked =get_tree().get_nodes_in_group("Granery")
	if checked.size() > 0:
		for i in checked:
			if i.spawned:
				spawnedGranery.append(i)

	match CurrentTask:
		Task.GettingFood:
			if runOnce:
				runOnce = false
				# Simulate collecting resources
				await get_tree().create_timer(2.0).timeout
				HeldresourcesAmount += ResourceGenerationAmount
				foodIndex += 1
				runOnce = true
				CurrentTask = Task.Searching
				
				if foodIndex >= FoodProducers.size():
					CurrentTask = Task.Delivering

			pass

		Task.Delivering:
			#var stockpiles=get_tree().get_nodes_in_group("StockPile")

			if spawnedGranery.size() > 0:
				var nearestGranery = spawnedGranery[0]
				for i in spawnedGranery:
						if i.position.distance_to(position) < nearestGranery.position.distance_to(position):
							nearestGranery = i
				navigationAgent.target_position = nearestGranery.get_node("SpawnPoint").global_position
			elif Hut != null:
				navigationAgent.target_position = Hut.global_postion
			CurrentTask = Task.Walking

		Task.Searching:
			navigationAgent.target_position = FoodProducers[foodIndex].global_position
			CurrentTask = Task.Walking

		Task.Walking:
			if navigationAgent.is_navigation_finished():
				if foodIndex != FoodProducers.size() :
					
					CurrentTask = Task.GettingFood
					
				else:
					GameManager.Food +=HeldresourcesAmount
					foodIndex = 0
					HeldresourcesAmount = 0
					if runOnce:
						runOnce = false
						# Simulate collecting resources
						await get_tree().create_timer(2.0).timeout
						runOnce = true
					CurrentTask = Task.Searching
	$Label3D.text = str(HeldresourcesAmount)
