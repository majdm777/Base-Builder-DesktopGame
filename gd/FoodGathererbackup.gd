extends CharacterBody3D
enum Task {
	Harvesting,
	Searching,
	Walking,
	Delivering,
	Depositing,
	Waiting 
}
var FoodProducers : Array
var current_plot = null
var CurrentTask: Task = Task.Searching
var Hut
var HeldresourcesAmount: int = 0
@export var pocket_space := 5
var runOnce := true
@onready var navigationAgent: NavigationAgent3D = $NavigationAgent3D
@export var SPEED = 10.0
var going_to_mill := false
func _ready() -> void:
	Hut.plot_ready.connect(_on_plot_ready)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if CurrentTask == Task.Walking:
		if not navigationAgent.is_navigation_finished():
			var targetPos = navigationAgent.get_next_path_position()
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
	match CurrentTask:
		Task.Harvesting:
			if runOnce:
				runOnce = false
				await get_tree().create_timer(2.0).timeout
				HeldresourcesAmount += current_plot.plot_amount
				current_plot.current_state = current_plot.State.harvested
				# Harvest done — remove this plot from the queue for good
				if current_plot != null:
					FoodProducers.erase(current_plot)
					current_plot = null
				runOnce = true
				if HeldresourcesAmount >= pocket_space:
					HeldresourcesAmount =pocket_space
					CurrentTask = Task.Delivering
				else:
					CurrentTask = Task.Searching
				if FoodProducers.size() <= 0:
					CurrentTask = Task.Delivering

		Task.Delivering:
			var spawnedMill = get_spawned_mills()
			if spawnedMill.size() > 0 and HeldresourcesAmount > 0 and ResourceManager.Food < ResourceManager.food_capacity:
				var nearestMill = spawnedMill[0]
				for i in spawnedMill:
					if i.position.distance_to(position) < nearestMill.position.distance_to(position):
						nearestMill = i
				navigationAgent.target_position = nearestMill.get_node("SpawnPoint").global_position
				going_to_mill = true
			elif Hut != null:
				navigationAgent.target_position = Hut.get_node("SpawnPoint").global_position
				going_to_mill = false
			CurrentTask = Task.Walking

		Task.Searching:
			if FoodProducers.size() > 0 and HeldresourcesAmount < pocket_space:
				current_plot = FoodProducers[0]
				navigationAgent.target_position = current_plot.global_position
				CurrentTask = Task.Walking
			elif HeldresourcesAmount > 0 :
				CurrentTask = Task.Delivering
			else:
				CurrentTask = Task.Waiting

		Task.Walking:
			if navigationAgent.is_navigation_finished():
				if current_plot != null and pocket_space!=HeldresourcesAmount:
					CurrentTask = Task.Harvesting
				elif going_to_mill:
					CurrentTask = Task.Depositing
				else:
					# We were walking to deliver
					CurrentTask = Task.Waiting
		Task.Depositing:
			if runOnce and ResourceManager.Food < ResourceManager.food_capacity:
				runOnce=false
				await get_tree().create_timer(2.0).timeout
				ResourceManager.Food += HeldresourcesAmount
				if ResourceManager.Food > ResourceManager.food_capacity:
					ResourceManager.Food = ResourceManager.food_capacity
				HeldresourcesAmount = 0
				runOnce= true
			CurrentTask = Task.Searching
		Task.Waiting:
			if runOnce:
				runOnce=false
				await get_tree().create_timer(1.0).timeout
				runOnce= true
			CurrentTask = Task.Searching

	$Label3D.text = str(CurrentTask)

func _on_plot_ready(plot):
	FoodProducers.append(plot)
	
func get_spawned_mills() -> Array:
	var mills: Array = []
	for mill in get_tree().get_nodes_in_group("Mills"):
		if mill.spawned:
			mills.append(mill)
	return mills
