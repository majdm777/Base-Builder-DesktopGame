extends CharacterBody3D
enum Task {
	harvesting,
	Searching,
	Walking,
	Delivering
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
	var spawnedGranery = []
	var checked = get_tree().get_nodes_in_group("Granery")
	if checked.size() > 0:
		for i in checked:
			if i.spawned:
				spawnedGranery.append(i)

	match CurrentTask:
		Task.harvesting:
			if runOnce:
				runOnce = false
				HeldresourcesAmount += current_plot.plot_amount
				if HeldresourcesAmount > pocket_space:
					HeldresourcesAmount -=current_plot.plot_amount
					CurrentTask = Task.Delivering
					runOnce = true
					return
				await get_tree().create_timer(2.0).timeout
				current_plot.current_state = current_plot.State.harvested

				# Harvest done — remove this plot from the queue for good
				if current_plot != null:
					FoodProducers.erase(current_plot)
					current_plot = null

				runOnce = true
				CurrentTask = Task.Searching

				if FoodProducers.size() <= 0:
					CurrentTask = Task.Delivering

		Task.Delivering:
			if spawnedGranery.size() > 0 and HeldresourcesAmount > 0:
				var nearestGranery = spawnedGranery[0]
				for i in spawnedGranery:
					if i.position.distance_to(position) < nearestGranery.position.distance_to(position):
						nearestGranery = i
				navigationAgent.target_position = nearestGranery.get_node("SpawnPoint").global_position
			elif Hut != null:
				navigationAgent.target_position = Hut.get_node("SpawnPoint").global_position
			CurrentTask = Task.Walking

		Task.Searching:
			if FoodProducers.size() > 0:
				current_plot = FoodProducers[0]
				navigationAgent.target_position = current_plot.global_position
				CurrentTask = Task.Walking
			else:
				CurrentTask = Task.Delivering

		Task.Walking:
			if navigationAgent.is_navigation_finished():
				if current_plot != null:
					CurrentTask = Task.harvesting
				else:
					# We were walking to deliver
					GameManager.Food += HeldresourcesAmount
					HeldresourcesAmount = 0
					if runOnce:
						runOnce = false
						await get_tree().create_timer(2.0).timeout
						runOnce = true
					CurrentTask = Task.Searching

	$Label3D.text = str(HeldresourcesAmount)

func _on_plot_ready(plot):
	FoodProducers.append(plot)
