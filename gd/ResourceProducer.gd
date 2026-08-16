class_name ResourceProducer
extends StaticBody3D


@export var ResourceAmount :int = 10

var remaining_resource_amount = ResourceAmount


var is_harvesting: bool = false

@export_enum("Wood", "Stone", "Iron")
var ResourceType: String 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _Harvest(GathererCapacity: int) -> int:
	is_harvesting = true

	var amount: int

	if remaining_resource_amount >= GathererCapacity:
		remaining_resource_amount -= GathererCapacity
		amount = GathererCapacity
		
	else:
		amount = remaining_resource_amount
		remaining_resource_amount = 0
	
	on_harvest()
	if remaining_resource_amount <= 0:
		queue_free()

	is_harvesting = false
	return amount

func on_harvest() -> void:
	pass
