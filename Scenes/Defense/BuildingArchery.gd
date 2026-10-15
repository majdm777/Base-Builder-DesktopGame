extends BuildingMiltaryTraining


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trainable = {
		"Archer": {
			"name": "Archer",
			"pop_cost": 1,
			"costs": {"iron": 0},
			"train_time": 3.0,
			"scene_path": "res://Scenes/Soldiers/Knight.tscn",
		},
	}
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass
