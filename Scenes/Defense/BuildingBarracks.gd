class_name BuildingBarracks
extends BuildingMiltaryTraining

func _ready() -> void:
	trainable = {
		"Knight": {
			"name": "Knight",
			"pop_cost": 1,
			"costs": {"iron": 0},
			"train_time": 3.0,
			"scene_path": "res://Scenes/Soldiers/Knight.tscn",
		},
	}
func _process(delta: float) -> void:
	super(delta)
	pass
