class_name BuildingCommunityObject
extends BuildingObject

@export var capacity : int = 3
@export var time_interacting = 5
var current_occupants : int = 0

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)

func _interact(character: Node3D) -> bool:
	return true
