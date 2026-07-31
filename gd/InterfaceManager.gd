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





func _on_area_2d_area_entered(area: Area2D) -> void:
	BuilderManager.AbleToBuild = false
	pass # Replace with function body.
func _on_area_2d_area_exited(area: Area2D) -> void:
	BuilderManager.AbleToBuild = true
	
	pass # Replace with function body.


func _on_build_stock_pile_button_button_down() -> void:
	BuilderManager.SpawnStockPile()
	pass # Replace with function body.
func _on_build_wood_cutter_button_button_down() -> void:
	BuilderManager.SpawnWoodCutterHut()
	pass # Replace with function body.
func _on_build_stone_cutter_hut_button_down() -> void:
	BuilderManager.SpawnStoneCutterHut()
	pass # Replace with function body.
func _on_build_iron_cutter_hut_button_down() -> void:
	pass # Replace with function body.


func _on_build_granery_button_down() -> void:
	BuilderManager.SpawnGranery()
	pass # Replace with function body.
func _on_build_orchard_button_down() -> void:
	BuilderManager.SpawnOrchard()
	pass # Replace with function body.


func _on_build_house_button_down() -> void:
	BuilderManager.SpawnHouse()
	pass # Replace with function body.


func _on_build_wall_narrow_button_down() -> void:
	BuilderManager.SpawnWall()
	pass # Replace with function body.

func _on_build_wall_narrow_corner_button_down() -> void:
	BuilderManager.SpawnWallCorner()
	pass # Replace with function body.


func _on_build_wall_narrow_gate_button_down() -> void:
	BuilderManager.SpawnWallGate()
	pass # Replace with function body.
