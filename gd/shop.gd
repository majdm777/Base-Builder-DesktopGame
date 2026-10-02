extends BuildingCommunityObject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func _interact(character: Node3D) -> bool:
	if current_occupants >= capacity:
		return false
	current_occupants += 1
 	# may add animation to the citizen later 
	await get_tree().create_timer(time_interacting).timeout
	current_occupants -= 1

	GameManager.on_community_interaction()

	return true
