extends StaticBody3D


@export var ResourceAmount :int = 10

var is_harvesting: bool = false

@export_enum("Wood", "Stone", "Iron")
var ResourceType: String 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _Harvest(GathererCapacity : int) -> int:
	var amount : int
	is_harvesting = true

	if ResourceAmount >= GathererCapacity :
		ResourceAmount -= GathererCapacity
		amount = GathererCapacity
	else:
		amount = ResourceAmount
		ResourceAmount = 0
		queue_free()
		
	is_harvesting = false
	return amount
	
