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
var MaxPopulation : int = 4
var AvlPopulation : int = 0

var taxRate := 1

var TCitizen : PackedScene

var Happiness := 100

var spawnReady := true
var FoundHouse := false

var Food : int = 5000

@onready var food_timer := Timer.new()
@onready var food_consumption_timer := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TCitizen = ResourceLoader.load("res://Citizen.tscn")

	add_child(food_timer)
	food_timer.one_shot = true
	food_timer.timeout.connect(_on_food_timer_timeout)
	_restart_food_timer()

	add_child(food_consumption_timer)
	food_consumption_timer.wait_time = 10.0
	food_consumption_timer.one_shot = false
	food_consumption_timer.timeout.connect(_on_food_consumption_timeout)
	food_consumption_timer.start()


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

func _on_food_consumption_timeout() -> void:
	ResourceManager.resources["food"] -= population
	if ResourceManager.resources["food"] < 0:
		ResourceManager.resources["food"] = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Happiness = food_availability + safty + community

	if Happiness > 60 && population < MaxPopulation && spawnReady:
		spawnReady = false
		FoundHouse = false
		var houses = get_tree().get_nodes_in_group("House")
		if houses.size() > 0:
			await get_tree().create_timer(3.0).timeout
			var citizen = TCitizen.instantiate()
			BuilderManager.map_root.add_child(citizen)
			for house in houses:
				if is_instance_valid(house) and house.spawned and house.remaining_space > 0 :
					citizen.Home = house.occupy()
					citizen.global_position = citizen.Home.global_position
					citizen.current_task = citizen.Task.Sitting
					FoundHouse = true
					population += 1
					AvlPopulation += 1
					break
			if not FoundHouse:
				citizen.queue_free()
		spawnReady = true
func assign_citizen():
	for node in BuilderManager.map_root.get_children():
		if node is Citizen:
			node.queue_free()
			return
	pass
