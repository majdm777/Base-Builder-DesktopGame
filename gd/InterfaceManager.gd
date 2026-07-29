extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass# Replace with function body.func _process(delta: float) -> void:
func _process(delta: float) -> void:
	$ResourcesBox/WoodLabel/WoodCountLabel.text = str(GameManager.Wood, " W")
	$ResourcesBox/FoodLabel/FoodCountLabel.text = str(GameManager.Food, " F")
	$ResourcesBox/GoldLabel/GoldCountLabel.text = str(GameManager.Gold, " G")
	$ResourcesBox/IronLabel/IronCountLabel.text = str(GameManager.Iron, " I")
	$ResourcesBox/StoneLabel/StoneCountLabel.text = str(GameManager.Stone, " S")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.



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


func _on_build_stock_pile_button_button_down() -> void:
	BuilderManager.SpawnStockPile()
	pass # Replace with function body.


#func _on_build_wood_cutter_button_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#BuilderManager.SpawnWoodCutterHut()
	#else:
		#GameManager.Current_State = GameManager.State.play
	#pass # Replace with function body.
