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
