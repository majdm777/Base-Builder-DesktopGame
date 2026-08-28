class_name BuildingObject
extends StaticBody3D
signal building_spawned

@export var WoodCost : int
@export var StoneCost : int
@export var IronCost : int 
@export var GoldCost : float 

@export var PopulationCost : int
@export var IncreasePopcap : bool = false
@export var IncreaseCapAmount := 0


@export var wood_capacity : int = 0
@export var stone_capacity : int = 0
@export var iron_capacity : int = 0
@export var gold_capacity : int = 0
@export var food_capacity : int = 0

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

var run_once :bool = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func runSpawn():
	if SpawnActor:
		CurrentActor = Actor.instantiate()
		CurrentActor.Hut = self
		await get_tree().create_timer(2).timeout
		get_tree().root.add_child(CurrentActor)
		CurrentActor.global_position = $SpawnPoint.global_position
		var nav_map: RID = CurrentActor.get_world_3d().navigation_map
		var closest_point: Vector3 = NavigationServer3D.map_get_closest_point(nav_map, $SpawnPoint.global_position)
	if IncreasePopcap:
		GameManager.MaxPopulation += IncreaseCapAmount
	ResourceManager._on_spawn_object(self)
	spawned = true
	building_spawned.emit()

func run_despawn():
	if SpawnActor and CurrentActor:
		CurrentActor.queue_free()
	GameManager.population -= PopulationCost
	if IncreaseCapAmount:
		GameManager.population -= IncreaseCapAmount
	ResourceManager._on_despawn_object(self)
	queue_free()

func _on_area_area_entered(area: Area3D) -> void:
	if(ActiveBuildableObject):
		BuilderManager.AbleToBuild = false
		object.append(area)
	pass # Replace with function body.


func _on_area_area_exited(area: Area3D) -> void:
	if ActiveBuildableObject:
		if not object.has(area):
			return  # was never tracked, nothing to remove
		object.erase(area)
		if object.size() <= 0:
			BuilderManager.AbleToBuild = true
			
