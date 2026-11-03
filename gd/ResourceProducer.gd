class_name ResourceProducer
extends Node3D


@export var amount :int = 10

var remaining_resource_amount 
var is_empty :bool = false

var is_harvesting: bool = false

@export_enum("Wood", "Stone", "Iron")
var ResourceType: String 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remaining_resource_amount = amount
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_empty and not is_harvesting:
		pass
	pass
func _Harvest(GathererCapacity: int) -> int:
	is_harvesting = true

	var _amount: int

	if remaining_resource_amount >= GathererCapacity:
		remaining_resource_amount -= GathererCapacity
		_amount = GathererCapacity
		
	else:
		_amount = remaining_resource_amount
		remaining_resource_amount = 0
	
	await on_harvest()
	if remaining_resource_amount <= 0:
		is_empty = true

	is_harvesting = false
	return amount

func on_harvest() -> void:
	pass
