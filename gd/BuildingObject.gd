extends StaticBody3D

@export var WoodCost : float
@export var StoneCost : float
@export var IronCost : float 
@export var GoldCost : float 
@export var PopulationCost : int
@export var IncreasePopcap : bool = false
@export var IncreaseCapAmount := 5


var object : Array 
var ActiveBuildableObject : bool
var spawned : bool = false
@export var SpawnActor : bool = false
@export var Actor : PackedScene

var CurrentActor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area.area_entered.connect(_on_area_area_entered)
	$Area.area_exited.connect(_on_area_area_exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func runSpawn():
	if SpawnActor:
		CurrentActor = Actor.instantiate()
		CurrentActor.Hut = $SpawnPoint
		get_tree().root.add_child(CurrentActor)
		CurrentActor.global_position = $SpawnPoint.global_position
		
	if IncreasePopcap :
		GameManager.MaxPopulation += IncreaseCapAmount
		
func run_despawn():
	if SpawnActor and CurrentActor:
		CurrentActor.queue_free()
	GameManager.population -= PopulationCost
	if IncreaseCapAmount:
		GameManager.population -= IncreaseCapAmount
	queue_free()

func _on_area_area_entered(area: Area3D) -> void:
	if(ActiveBuildableObject):
		BuilderManager.AbleToBuild = false
		object.append(area)
	pass # Replace with function body.


func _on_area_area_exited(area: Area3D) -> void:
	if(ActiveBuildableObject):
		object.remove_at(object.find(area))
		if object.size() <= 0:
			BuilderManager.AbleToBuild = true
	pass # Replace with function body.
