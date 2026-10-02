class_name BuildingCommunityObject
extends BuildingObject

@export var capacity : int = 3
var current_occupants : int = 0

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)

func _interact(character: Node3D) -> bool:
	if current_occupants >= capacity:
		return false
		
	current_occupants += 1
	if is_instance_valid(character):
		character.visible = false
	await get_tree().create_timer(5.0).timeout
	current_occupants -= 1
	if is_instance_valid(character):
		character.visible = true
	GameManager.on_community_interaction()

	return true
