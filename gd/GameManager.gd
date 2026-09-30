extends Node

enum State{
	play,
	building,
	destroying,
}

var food_availability := 60
var fbool := true
var safty := 20
var community := 20

var Current_State = State.play

var population : int = 0
var MaxPopulation : int = 4
var AvlPopulation : int = 0

var taxRate := 1

var Citizen : PackedScene

var Happiness := 100

var foodbool := true

var spawnReady := true 
var FoundHouse := false

var Food : int = 5000
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Citizen = ResourceLoader.load("res://Citizen.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Happiness = food_availability + safty + community
	
	if ResourceManager.resources["food"] == 0:
		if fbool :
			fbool = false
			if food_availability > 0:
				await get_tree().create_timer(5.0).timeout
				food_availability -= 1
			fbool = true
	else:
		if fbool :
			fbool = false
			if food_availability <= 60:
				await get_tree().create_timer(7.5).timeout
				food_availability += 1
			fbool = true
	
	if Happiness > 60 && population < MaxPopulation && spawnReady:
		spawnReady = false
		FoundHouse = false;
		var houses = get_tree().get_nodes_in_group("House")
		if houses.size() > 0:
			await get_tree().create_timer(3.0).timeout
			var citizen = Citizen.instantiate()
			for house in houses:
				if is_instance_valid(house) and house.spawned and house.remaining_space > 0 :
					BuilderManager.map_root.add_child(citizen)
					citizen.Home = house.occupy()
					citizen.global_position = citizen.Home.global_position
					citizen.current_task = citizen.Task.Sitting
					FoundHouse = true;
					population += 1
					AvlPopulation += 1
					break 
			#citizen.Spawn()
			if not FoundHouse:
				citizen.queue_free()
		spawnReady = true
	if foodbool:
		foodbool = false
		await get_tree().create_timer(10.0).timeout
		ResourceManager.resources["food"] -= population
		if ResourceManager.resources["food"] < 0:
			ResourceManager.resources["food"] = 0
		foodbool = true
