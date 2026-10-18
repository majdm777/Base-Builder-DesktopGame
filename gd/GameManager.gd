extends Node

enum State{
	play,
	building,
	destroying,
}

var food_availability := 60
var safty := 20
var community := 20

var Current_State = State.play

var population : int = 0
var MaxPopulation : int = 0
var AvlPopulation : int = 0

var Soldiers = {
	"Archer" : 0,
	"Knight" : 0
}

var Workers = {
	"Farmer" : 0,
	"Wood Cutter" : 0,
	"Stone Miner" : 0,
	"Iron Miner" : 0
}

var taxRate := 1

var TCitizen : PackedScene
var citizen_spawn_cooldown := 12

var Happiness := 100

var spawnReady := true
var FoundHouse := false

@onready var food_timer := Timer.new()
@onready var food_consumption_timer := Timer.new()
@onready var community_decay_timer := Timer.new()
@onready var citizen_spawn_timer := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TCitizen = ResourceLoader.load("res://Citizen.tscn")

	add_child(food_timer)
	food_timer.one_shot = true
	food_timer.timeout.connect(_on_food_timer_timeout)
	_restart_food_timer()
	
	add_child(citizen_spawn_timer)
	citizen_spawn_timer.one_shot = true
	citizen_spawn_timer.wait_time = citizen_spawn_cooldown
	citizen_spawn_timer.timeout.connect(_on_citizen_spawn_timeout)
	citizen_spawn_timer.start()

	add_child(food_consumption_timer)
	food_consumption_timer.wait_time = 10.0
	food_consumption_timer.one_shot = false
	food_consumption_timer.timeout.connect(_on_food_consumption_timeout)
	food_consumption_timer.start()
	
	add_child(community_decay_timer)
	community_decay_timer.wait_time = 8.0
	community_decay_timer.one_shot = false
	community_decay_timer.timeout.connect(_on_community_decay_timeout)
	community_decay_timer.start()


func _restart_food_timer() -> void:
	if ResourceManager.resources["food"] == 0:
		food_timer.wait_time = 5.0
	else:
		food_timer.wait_time = 7.5
	food_timer.start()


func _on_food_timer_timeout() -> void:
	if ResourceManager.resources["food"] == 0:
		if food_availability > 0:
			food_availability -= 1
	else:
		if food_availability <= 60:
			food_availability += 1
	_restart_food_timer()


func _on_citizen_spawn_timeout() -> bool:
	if Happiness > 60 && population < MaxPopulation :
		FoundHouse = false
		if _spawn_citizen():
			spawnReady = true
			citizen_spawn_timer.wait_time = citizen_spawn_cooldown
			citizen_spawn_timer.start()
			return true
	spawnReady = false
	citizen_spawn_timer.wait_time = 1
	citizen_spawn_timer.start()
	return false

func _on_food_consumption_timeout() -> void:
	ResourceManager.resources["food"] -= population
	if ResourceManager.resources["food"] < 0:
		ResourceManager.resources["food"] = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:                                                 
	Happiness = food_availability + safty + community
func assign_citizen():
	if AvlPopulation <= 0:
		return 
	for node in BuilderManager.map_root.get_children():
		if node is Citizen:
			node.queue_free()
			AvlPopulation -= 1
			return
	pass

func _spawn_citizen() -> bool:
	var houses = get_tree().get_nodes_in_group("House")
	if houses.size() > 0:
		var citizen = TCitizen.instantiate()
		for house in houses:
			if is_instance_valid(house) and house.spawned and house.remaining_space > 0 :
				BuilderManager.map_root.add_child(citizen)
				citizen.Home = house.occupy()
				citizen.global_position = citizen.Home.global_position
				citizen.current_task = citizen.Task.Wondering
				FoundHouse = true
				population += 1
				if population > MaxPopulation:
					population = MaxPopulation
				AvlPopulation += 1
				break
		if not FoundHouse:
			citizen.queue_free()
			return false
		return true
	return false
func _on_community_decay_timeout() -> void:
	if AvlPopulation <= 0:
		return
	var decay_amount : int = 1 + int(population / 10.0)  # divisor = 10, tune as needed
	community = max(0, community - decay_amount)

func on_community_interaction() -> void:
	community = min(20, community + 1)
