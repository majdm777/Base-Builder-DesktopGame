class_name gatherer
extends CharacterBody3D

enum Task {
	Gathering,
	Searching,
	Walking,
	Delivering,
	Depositing,
	Waiting 
}

var CurrentTask: Task = Task.Searching
var Hut
var Producers : Array

@onready var navigationAgent: NavigationAgent3D = $NavigationAgent3D
var HeldresourcesAmount: int = 0

@export var SPEED = 10.0
@export var pocket_space := 5
@export_enum("wood","stone","iron","food") var resource_type: String

var going_to_storage := false
# Called when the node enters the scene tree for the first time.

var runOnce : bool = true

var current_target 
func _ready() -> void:
	pass # Replace with function body.

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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match CurrentTask:
		Task.Gathering:
			if runOnce:
				runOnce = false
				await get_tree().create_timer(2.0).timeout
				if current_target.has_method("_Harvest"):
					HeldresourcesAmount += current_target._Harvest(pocket_space)
				else:
					HeldresourcesAmount += current_target.amount
				if "current_state" in current_target:
					current_target.current_state = current_target.State.harvested
				# Harvest done — remove this plot from the queue for good
				if current_target != null:
					Producers.erase(current_target)
					current_target = null
				runOnce = true
				if HeldresourcesAmount >= pocket_space:
					HeldresourcesAmount =pocket_space
					CurrentTask = Task.Delivering
				else:
					CurrentTask = Task.Searching
				if Producers.size() <= 0:
					CurrentTask = Task.Delivering

		Task.Delivering:
			var spawnedStorage = get_spawned_storage()
			if spawnedStorage.size() > 0 and HeldresourcesAmount > 0 and ResourceManager.resources[resource_type] < ResourceManager.capacities[resource_type]:
				var nearest_storage = spawnedStorage[0]
				for i in spawnedStorage:
					if i.position.distance_to(position) < nearest_storage.position.distance_to(position):
						nearest_storage = i
				navigationAgent.target_position = nearest_storage.get_node("SpawnPoint").global_position
				going_to_storage = true
			elif Hut != null:
				navigationAgent.target_position = Hut.get_node("SpawnPoint").global_position
				going_to_storage = false
			CurrentTask = Task.Walking

		Task.Searching:
			_find_resources()
			if Producers.size() > 0 and HeldresourcesAmount < pocket_space:
				current_target = Producers[0]
				navigationAgent.target_position = current_target.global_position
				CurrentTask = Task.Walking
			elif HeldresourcesAmount > 0 :
				CurrentTask = Task.Delivering
			else:
				CurrentTask = Task.Waiting

		Task.Walking:
			if navigationAgent.is_navigation_finished():
				if current_target != null and pocket_space!=HeldresourcesAmount:
					CurrentTask = Task.Gathering
				elif going_to_storage:
					CurrentTask = Task.Depositing
				else:
					# We were walking to deliver
					CurrentTask = Task.Waiting
		Task.Depositing:
			if runOnce and ResourceManager.resources[resource_type] < ResourceManager.capacities[resource_type]:
				runOnce=false
				await get_tree().create_timer(2.0).timeout
				ResourceManager.resources[resource_type] += HeldresourcesAmount
				if ResourceManager.resources[resource_type] > ResourceManager.capacities[resource_type]:
					ResourceManager.resources[resource_type] = ResourceManager.capacities[resource_type]
				HeldresourcesAmount = 0
				runOnce= true
			CurrentTask = Task.Searching
		Task.Waiting:
			if runOnce:
				runOnce=false
				await get_tree().create_timer(1.0).timeout
				runOnce= true
			CurrentTask = Task.Searching

	$Label3D.text = str(HeldresourcesAmount)
	#print(CurrentTask)

func get_spawned_storage() -> Array:
	return []
func _find_resources()->void:
	pass
