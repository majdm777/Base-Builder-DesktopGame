extends BuildingCommunityObject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if current_occupants  > 0 :
		$Node3D/OmniLight3D.visible = true
		$Node3D/OmniLight3D2.visible = true
	else:
		$Node3D/OmniLight3D.visible = false
		$Node3D/OmniLight3D2.visible = false
	pass

func _interact(character: Node3D) -> bool:
	if current_occupants >= capacity:
		return false
	current_occupants += 1
	if is_instance_valid(character):
		character.visible = false
	await get_tree().create_timer(time_interacting).timeout
	current_occupants -= 1
	if is_instance_valid(character):
		character.visible = true
	GameManager.on_community_interaction()

	return true
