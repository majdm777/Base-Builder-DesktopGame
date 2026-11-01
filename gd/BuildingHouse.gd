extends BuildingObject

var remaining_space : int
var added_to_group := false

const HOUSE_CARD := preload("res://Scenes/Interface/house_card.tscn")

var house_card : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	remaining_space = IncreaseCapAmount
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if not added_to_group and spawned:
		add_to_group("House")
		added_to_group = true
	pass


func occupy() -> Marker3D:
	remaining_space -= 1
	return $SpawnPoint

func run_despawn():
	if is_in_group("House") and remaining_space != IncreaseCapAmount :
		print("you can't remove an occupied house")
		return 
	if SpawnActor and CurrentActor:
		CurrentActor.queue_free()
	GameManager.population -= PopulationCost
	if IncreaseCapAmount:
		GameManager.MaxPopulation -= IncreaseCapAmount
	ResourceManager._on_despawn_object(self)
	queue_free()

func build_info(container: Control) -> void:
	super(container)
	house_card = HOUSE_CARD.instantiate()
	container.add_child(house_card)
	house_card.setup(self)
	pass
 
func update_info() -> void:
	super()
	if is_instance_valid(house_card):
		house_card.update()
	
