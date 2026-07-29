extends StaticBody3D

@export var WoodCost : float
@export var StoneCost : float
@export var IronCost : float 
@export var GoldCost : float 
@export var PopulationCost : int


var object : Array 
var ActiveBuildableObject : bool
var spawned : bool = false
@export var SpawnActor : bool = true
@export var Actor : PackedScene
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
		var actor = Actor.instantiate()
		get_tree().root.add_child(actor)
		actor.global_position = $SpawnPoint.global_position
		actor.Hut = $SpawnPoint.global_position
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
