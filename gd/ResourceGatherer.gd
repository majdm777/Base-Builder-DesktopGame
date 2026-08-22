class_name resource_gatherer
extends gatherer

@export_enum("Tree","Rock") var ResourceName : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func _find_resources():
	Producers = []
	for building in get_tree().get_nodes_in_group(ResourceName):
			Producers.append(building)
	Producers.sort_custom(func(a, b):
		return global_position.distance_squared_to(a.global_position) < \
			  	global_position.distance_squared_to(b.global_position)  )

func get_spawned_storage() -> Array:
	var Stock_Piles: Array = []
	for stock_pile in get_tree().get_nodes_in_group("StockPile"):
		if stock_pile.spawned:
			Stock_Piles.append(stock_pile)
	return Stock_Piles
