extends CharacterBody3D


enum Task {
	GettingResources,
	Searching,
	Walking,
	Delivering
}



@export_enum("Tree", "Rock", "Iron")
var ResourceNameToGet: String


var CurrentTask: Task = Task.Searching

var Hut
var HeldresourcesAmount: int = 0

@export var ResourceGenerationAmount :=0


var runOnce := true
@onready var navigationAgent: NavigationAgent3D = $NavigationAgent3D


@export var SPEED = 10.0

var currentResource


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
			if is_instance_valid(currentResource): 
				if runOnce:
					runOnce = false
					# Simulate collecting resources
					if is_instance_valid(currentResource):
						await get_tree().create_timer(2.0).timeout
						HeldresourcesAmount = currentResource._Harvest(ResourceGenerationAmount)
					runOnce = true
					CurrentTask = Task.Delivering
			else: 
				CurrentTask = Task.Searching

		Task.Delivering:
			#var stockpiles=get_tree().get_nodes_in_group("StockPile")
			var spawnedStockpiles = []
			var checked =get_tree().get_nodes_in_group("StockPile")
			if checked.size() > 0:
				for i in checked:
					if i.spawned:
						spawnedStockpiles.append(i)
			if spawnedStockpiles.size() > 0:
				var nearestStockPile = spawnedStockpiles[0]
				for i in spawnedStockpiles:
						if i.position.distance_to(position) < nearestStockPile.position.distance_to(position):
							nearestStockPile = i
				navigationAgent.target_position = nearestStockPile.get_node("SpawnPoint").global_position
			elif Hut != null:
				navigationAgent.target_position = Hut.global_position
			CurrentTask = Task.Walking

		Task.Searching:
			var resources = get_tree().get_nodes_in_group(ResourceNameToGet)
			if resources.size() > 0:
				var nearestResourceObject = resources[0]
				for i in resources:
					if i.position.distance_to(position) < nearestResourceObject.position.distance_to(position) and i.is_harvesting == false:
						nearestResourceObject = i
				navigationAgent.target_position = nearestResourceObject.global_position
				currentResource = nearestResourceObject
				CurrentTask = Task.Walking
			else :
				if self.global_position != Hut.global_position:
					navigationAgent.target_position = Hut.global_position
					CurrentTask = Task.Walking

		Task.Walking:
			if navigationAgent.is_navigation_finished():
				if HeldresourcesAmount == 0:
					CurrentTask = Task.GettingResources
				elif runOnce:
					runOnce = false
					match ResourceNameToGet:
						"Tree": GameManager.Wood += HeldresourcesAmount
						"Stone": GameManager.Stone += HeldresourcesAmount
						"Iron": GameManager.Iron += HeldresourcesAmount
					HeldresourcesAmount = 0
					await get_tree().create_timer(2.0).timeout
					runOnce = true
					CurrentTask = Task.Searching
	$Label3D.text = str(HeldresourcesAmount)
