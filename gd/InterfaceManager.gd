extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	pass # Replace with function body.


func _on_build_wood_cutter_button_button_down() -> void:
	BuilderManager.SpawnWoodCutterHut()
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	BuilderManager.AbleToBuild = false
	pass # Replace with function body.


func _on_area_2d_area_exited(area: Area2D) -> void:
	BuilderManager.AbleToBuild = true
	
	pass # Replace with function body.
