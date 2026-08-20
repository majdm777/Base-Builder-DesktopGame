extends Node

enum State{
	play,
	building,
	destroying
}

var Current_State = State.play

var population : int = 0
var MaxPopulation : int = 4
var AvlPopulation : int = 0

var taxRate := 1

var Citizen : PackedScene

var FirePitSpaces : Array
var OccupiedFireSpaces : Array

var Happiness := 1

var foodbool := true

var spawnReady := true 

var Food : int =5000
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Citizen = ResourceLoader.load("res://Citizen.tscn")
	FirePitSpaces = get_tree().get_nodes_in_group("CitizenSpawnPoint")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if population < MaxPopulation && spawnReady && Happiness > 0 && FirePitSpaces.size() > 0:
		spawnReady = false
		await get_tree().create_timer(3.0).timeout
		spawnReady = true
		var citizen = Citizen.instantiate()
		FirePitSpaces[0].add_child(citizen)
		citizen.FirePitPos = FirePitSpaces[0]
		citizen.spawn_Object_Setup()
		OccupiedFireSpaces.append(FirePitSpaces.pop_at(0))
		population +=1
		AvlPopulation +=1
	elif  spawnReady && Happiness < 0 :
		spawnReady = false
		await get_tree().create_timer(3).timeout
		spawnReady = true
		if AvlPopulation >0:
			remove_citizen(1)
	if foodbool:
		foodbool = false
		await get_tree().create_timer(6.0).timeout
		ResourceManager.Food -= population
		if ResourceManager.Food < 0:
			ResourceManager.Food = 0
		foodbool = true
		ResourceManager.Gold += round(population * taxRate)
		var happinessValue = 0
		if ResourceManager.Food > 0:
			happinessValue +=1
		else:
			happinessValue-=10
		if taxRate > 0:
			happinessValue -=round(taxRate/2)
		Happiness += happinessValue
		if Happiness >=2:
			Happiness = 2
		elif Happiness <= -2:
			Happiness =-2
	pass
	pass
	
func remove_citizen(Cost : int):
	for i in range(0,Cost,1):
		FirePitSpaces.append(OccupiedFireSpaces[0])
		var temp : Node3D = OccupiedFireSpaces[0]
		delete_child(temp)
		OccupiedFireSpaces.remove_at(0)
		AvlPopulation -=1
		population -=1
		

func delete_child(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
