extends Node


var Wood : int = 20
var Stone : int = 20
var Iron : int = 20
var Gold : int = 0
var Food : int =100

var resources = {
	"wood":0,
	"stone":0,
	"iron":0,
	"food":0,
	"gold":0
}

var capacities = {
	"wood":20,
	"stone":20,
	"iron":20,
	"food":20
}

var wood_capacity : int = 20
var stone_capacity : int = 20
var iron_capacity : int = 20
var food_capacity: int = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_spawn_object(obj)-> void:
	capacities["wood"] += obj.wood_capacity 
	capacities["stone"] += obj.stone_capacity 
	capacities["iron"] += obj.iron_capacity 
	capacities["food"] += obj.food_capacity
	pass

func _on_despawn_object(obj)->void:
	capacities["wood"] -= obj.wood_capacity 
	if(resources["wood"] > capacities["wood"]): resources["wood"] = capacities["wood"]
	capacities["stone"] -= obj.stone_capacity 
	if(resources["stone"] > capacities["stone"]): resources["stone"] = capacities["stone"]
	capacities["iron"] -= obj.iron_capacity 
	if(resources["iron"] > capacities["iron"]): resources["iron"] = capacities["iron"]
	capacities["food"] -= obj.food_capacity
	if(resources["food"] > capacities["food"]): resources["food"] = capacities["food"]
	
	pass
