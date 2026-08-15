extends Node3D



var WoodCutterHut : PackedScene = ResourceLoader.load("res://Scenes/WoodCutterHut.tscn")
var StoneCutterhut : PackedScene = ResourceLoader.load("res://Scenes/StoneMasons.tscn")
var StockPile : PackedScene = ResourceLoader.load("res://Scenes/Stockpile.tscn")

var Wall : PackedScene = ResourceLoader.load("res://Scenes/wallNarrow.tscn")
var CornerWall : PackedScene = ResourceLoader.load("res://Scenes/wallNarrowCorner.tscn")
var GateWall : PackedScene = ResourceLoader.load("res://Scenes/wallNarrowGate.tscn")

var Orchard : PackedScene = ResourceLoader.load("res://Scenes/Orchard.tscn")
var Granery : PackedScene = ResourceLoader.load("res://Scenes/Granery.tscn")

var House : PackedScene = ResourceLoader.load("res://Scenes/House.tscn")

var AbleToBuild : bool = true

var currentSpawnable : StaticBody3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.Current_State == GameManager.State.building:
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result:
			var cursor_pos = result.position
			currentSpawnable.position = Vector3(
				round(cursor_pos.x),
				0,
				round(cursor_pos.z)
			)
			currentSpawnable.ActiveBuildableObject=true
		if AbleToBuild && Can_Afford(currentSpawnable) && GameManager.AvlPopulation >= currentSpawnable.PopulationCost  :
			if Input.is_action_just_pressed("LeftMouseDown"):
				var obj = currentSpawnable.duplicate()
				get_tree().current_scene.add_child(obj)
				print("Placed object groups: ", obj.get_groups())
				obj.ActiveBuildableObject = false
				obj.runSpawn()
				obj.spawned = true 
				charge_object(obj)
				GameManager.remove_citizen(obj.PopulationCost)
				obj.position = currentSpawnable.position
				#get_tree().get_nodes_in_group("NavMesh")[0].bake_navigation_mesh(true)
		if Input.is_action_just_pressed("RightMouseDown"):
			currentSpawnable.queue_free()
			currentSpawnable = null
			GameManager.Current_State = GameManager.State.play
		if Input.is_action_just_pressed("rotation"):
			currentSpawnable.rotation_degrees += Vector3(0,90,0)
	if GameManager.Current_State == GameManager.State.destroying:
		if is_instance_valid(currentSpawnable):
			currentSpawnable.queue_free()
			currentSpawnable = null
		if Input.is_action_just_released("LeftMouseDown"):
			var camera = get_viewport().get_camera_3d()
			var mouse_pos = get_viewport().get_mouse_position()
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
			var spaceState=get_world_3d().direct_space_state
			var result = spaceState.intersect_ray(
						PhysicsRayQueryParameters3D.create(from, to))

			if result and result.collider.is_in_group("building"):
				result.collider.run_despawn()
	pass

func Can_Afford(obj) -> bool:
	if GameManager.Wood - obj.WoodCost < 0 :
		return false
	if GameManager.Stone - obj.StoneCost < 0 :
		return false
	if GameManager.Iron - obj.IronCost < 0 :
		return false
	if GameManager.Gold - obj.GoldCost < 0 :
		return false
	return true
		
func charge_object(obj):
	GameManager.Wood -= obj.WoodCost
	GameManager.Stone -= obj.StoneCost
	GameManager.Iron -= obj.IronCost
	GameManager.Gold -= obj.GoldCost
	
#industry 
func SpawnWoodCutterHut():
	SpawnObj(WoodCutterHut)
func SpawnStoneCutterHut():
	SpawnObj(StoneCutterhut)
func SpawnStockPile():
	SpawnObj(StockPile)
func SpawnIronCutterHut():
	pass
#Population
func SpawnHouse():
	SpawnObj(House)
#Food
func SpawnGranery():
	SpawnObj(Granery)
func SpawnOrchard():
	SpawnObj(Orchard)
#Wall
func SpawnWall():
	SpawnObj(Wall)
func SpawnWallCorner():
	SpawnObj(CornerWall)
func SpawnWallGate():
	SpawnObj(GateWall)

func SpawnObj(obj: PackedScene):
	if currentSpawnable:
		currentSpawnable.queue_free()

	currentSpawnable = obj.instantiate()
	

	# Prevent the preview from blocking the ray
	currentSpawnable.collision_layer = 1
	currentSpawnable.collision_mask = 1

	get_tree().current_scene.add_child(currentSpawnable)

	GameManager.Current_State = GameManager.State.building
