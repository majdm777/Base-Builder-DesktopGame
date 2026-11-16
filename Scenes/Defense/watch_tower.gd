extends BuildingDefense

const ARROW := preload("res://Scenes/Weapons/Arrow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func _attack() -> void:
	if not is_instance_valid(current_target):
		return
	var arrow = ARROW.instantiate()
	BuilderManager.map_root.add_child(arrow)         # add first, then position
	arrow.launch(global_position + Vector3(0, shoot_height, 0),
			current_target, damage_per_soldier * occupants.size(), self)
