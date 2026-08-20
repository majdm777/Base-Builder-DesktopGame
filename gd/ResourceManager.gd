extends Node


var Wood : int = 20
var Stone : int = 20
var Iron : int = 20
var Gold : int = 20
var Food : int =100

var wood_capacity : int = 20
var stone_capacity : int = 20
var iron_capacity : int = 20
var gold_capacity: int = 20
var food_capacity: int = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_spawn_object(obj)-> void:
	wood_capacity += obj.wood_capacity 
	stone_capacity += obj.stone_capacity 
	iron_capacity += obj.iron_capacity 
	gold_capacity += obj.gold_capacity
	food_capacity += obj.food_capacity
	pass

func _on_despawn_object(obj)->void:
	wood_capacity -= obj.wood_capacity 
	if(Wood > wood_capacity): Wood = wood_capacity
	stone_capacity -= obj.stone_capacity 
	if(Stone > stone_capacity): Stone = stone_capacity
	iron_capacity -= obj.iron_capacity 
	if(Iron > iron_capacity): Iron = iron_capacity
	gold_capacity -= obj.gold_capacity
	if(Gold > gold_capacity): Gold = gold_capacity
	food_capacity -= obj.food_capacity
	if(Food > food_capacity): Food = food_capacity
	
	pass
