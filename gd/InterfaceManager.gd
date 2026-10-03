extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass# Replace with function body.func _process(delta: float) -> void:
func _process(delta: float) -> void:
	$ResourcesBox/WoodLabel/WoodCountLabel.text = str(ResourceManager.resources["wood"], "/",ResourceManager.capacities["wood"])
	$ResourcesBox/FoodLabel/FoodCountLabel.text = str(ResourceManager.resources["food"], "/",ResourceManager.capacities["food"])
	$ResourcesBox/GoldLabel/GoldCountLabel.text = str(ResourceManager.resources["gold"])
	$ResourcesBox/IronLabel/IronCountLabel.text = str(ResourceManager.resources["iron"], "/",ResourceManager.capacities["iron"])
	$ResourcesBox/StoneLabel/StoneCountLabel.text = str(ResourceManager.resources["stone"], "/",ResourceManager.capacities["stone"])
	$PopulationBox/AlvPop/AvlPopValue.text = str(GameManager.AvlPopulation)
	$PopulationBox/Hap/HapValue.text = str(GameManager.Happiness)
	$PopulationBox/Pop/PopValue.text= str(GameManager.population) + "/" + str(GameManager.MaxPopulation)
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
	BuilderManager.spawn_ironmine_hut()
	pass # Replace with function body.


func _on_build_mill_button_down() -> void:
	BuilderManager.SpawnMill()
	pass # Replace with function body.
func _on_build_orchard_button_down() -> void:
	BuilderManager.SpawnOrchard()
	pass # Replace with function body.


func _on_build_house_button_down() -> void:
	BuilderManager.SpawnSmallHouse()
	pass # Replace with function body.



func _on_destory_mode_button_down() -> void:
	GameManager.Current_State = GameManager.State.destroying
	pass # Replace with function body.


func _on_build_farm_button_down() -> void:
	BuilderManager.SpawnFarm()
	pass # Replace with function body.


func _on_stone_mine_button_down() -> void:
	BuilderManager.SpawnStoneMine()
	pass # Replace with function body.


func _on_tree_plantation_button_down() -> void:
	BuilderManager.SpawnTreePlantation()
	pass # Replace with function body.


func _on_iron_mine_button_down() -> void:
	BuilderManager.SpawnIronMine()
	pass # Replace with function body.


func _on_church_button_down() -> void:
	BuilderManager.SpawnChurch()
	pass # Replace with function body.





func _on_shop_button_down() -> void:
	BuilderManager.SpawnShop()
	pass # Replace with function body.


func _on_bar_button_down() -> void:
	BuilderManager.SpawnBar()
	pass # Replace with function body.


func _on_build_house_2_button_down() -> void:
	BuilderManager.SpawnMediumHouse()
	pass # Replace with function body.


func _on_wall_lvl_1_button_down() -> void:
	BuilderManager.SpawnWall_lvl1()
	pass # Replace with function body.


func _on_wall_gate_lvl_1_button_down() -> void:
	BuilderManager.SpawnGate_lvl1()
	pass # Replace with function body.
