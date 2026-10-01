class_name BuildingCommunityObject
extends BuildingObject

@export var capacity : int = 3
var current_occupants : int = 0

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)

func _interact(Character : Node3D) -> bool:
	if current_occupants >= capacity:
		return false  # full, citizen should leave and wander again

	current_occupants += 1
	await get_tree().create_timer(5.0).timeout
	current_occupants -= 1
	GameManager.on_community_interaction()
	return true
