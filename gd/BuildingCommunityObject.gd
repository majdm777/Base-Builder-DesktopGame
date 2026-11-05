class_name BuildingCommunityObject
extends BuildingObject

const COMMUNITY_CARD := preload("res://Scenes/Interface/community_card.tscn")
var community_card

@export var capacity : int = 3
@export var time_interacting = 5
var current_occupants : int = 0
@export var interaction_Value := 1

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)

func _interact(character: Node3D) -> bool:
	return true

func build_info(container: Control) -> void:
	super(container)
	community_card = COMMUNITY_CARD.instantiate()
	container.add_child(community_card)
	community_card.setup(self)
	pass
 
func update_info() -> void:
	super()
	if is_instance_valid(community_card):
		community_card.update()
	
