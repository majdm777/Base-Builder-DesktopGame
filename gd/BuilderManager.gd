extends Node3D

var WoodCutterHut : PackedScene = ResourceLoader.load("res://Scenes/WoodCutterHut.tscn")
var StoneCutterhut : PackedScene = ResourceLoader.load("res://Scenes/StoneMasons.tscn")
var IronMineHut: PackedScene = ResourceLoader.load("res://Scenes/RecourceProducers/Iron/iron_mine.tscn")
var StockPile : PackedScene = ResourceLoader.load("res://Scenes/Stockpile.tscn")

var Wall : PackedScene = ResourceLoader.load("res://Scenes/wallNarrow.tscn")
var CornerWall : PackedScene = ResourceLoader.load("res://Scenes/wallNarrowCorner.tscn")
var GateWall : PackedScene = ResourceLoader.load("res://Scenes/wallNarrowGate.tscn")

var Orchard : PackedScene = ResourceLoader.load("res://Scenes/Orchard.tscn")
var Mill : PackedScene = ResourceLoader.load("res://Scenes/mill.tscn")
var Farm : PackedScene = ResourceLoader.load("res://Scenes/RecourceProducers/Food/farm.tscn")

var House : PackedScene = ResourceLoader.load("res://Scenes/House.tscn")

var AbleToBuild : bool = true
var currentSpawnable : StaticBody3D

# --- Nav baking queue state ---
var nav_region : NavigationRegion3D
var isBaking : bool = false
var bake_pending : bool = false


func _ready() -> void:
	nav_region = get_tree().get_nodes_in_group("NavRegion")[0]
	nav_region.bake_finished.connect(_on_bake_finished)


func _process(delta: float) -> void:
	if GameManager.Current_State == GameManager.State.building:
		_handle_building_state()

	if GameManager.Current_State == GameManager.State.destroying:
		_handle_destroying_state()


func _handle_building_state() -> void:
	if not is_instance_valid(currentSpawnable):
		return

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
		currentSpawnable.ActiveBuildableObject = true

	if AbleToBuild and Can_Afford(currentSpawnable) and GameManager.AvlPopulation >= currentSpawnable.PopulationCost:
		if Input.is_action_just_pressed("LeftMouseDown"):
			_place_building()

	if Input.is_action_just_pressed("RightMouseDown"):
		currentSpawnable.queue_free()
		currentSpawnable = null
		GameManager.Current_State = GameManager.State.play
		return

	if Input.is_action_just_pressed("rotation"):
		currentSpawnable.rotation_degrees += Vector3(0, 90, 0)


func _place_building() -> void:
	var obj = currentSpawnable.duplicate()
	obj.position = currentSpawnable.position
	obj.rotation = currentSpawnable.rotation

	nav_region.add_child(obj)
	print("Placed object groups: ", obj.get_groups())

	obj.ActiveBuildableObject = false

	charge_object(obj)
	GameManager.remove_citizen(obj.PopulationCost)

	# Wait until the navmesh has actually been rebaked to include this
	# building before spawning its actor, so it never spawns on stale nav data.
	await request_bake()

	obj.runSpawn()
	obj.spawned = true


func _handle_destroying_state() -> void:
	if is_instance_valid(currentSpawnable):
		currentSpawnable.queue_free()
		currentSpawnable = null

	if Input.is_action_just_released("LeftMouseDown"):
		var camera = get_viewport().get_camera_3d()
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
		var spaceState = get_world_3d().direct_space_state
		var result = spaceState.intersect_ray(
			PhysicsRayQueryParameters3D.create(from, to))

		if result and result.collider.is_in_group("building"):
			result.collider.run_despawn()
			await request_bake()


# --- Nav baking queue ---

# Starts a bake if none is running, or marks that another bake is needed
# once the current one finishes. Always resolves AFTER a bake that includes
# all geometry changes requested up to the point this was called.
func request_bake() -> void:
	if isBaking:
		bake_pending = true
		await nav_region.bake_finished
		return

	isBaking = true
	nav_region.bake_navigation_mesh(true)
	await nav_region.bake_finished


func _on_bake_finished() -> void:
	isBaking = false
	if bake_pending:
		bake_pending = false
		isBaking = true
		nav_region.bake_navigation_mesh(true)


func Can_Afford(obj) -> bool:
	if GameManager.Wood - obj.WoodCost < 0:
		return false
	if GameManager.Stone - obj.StoneCost < 0:
		return false
	if GameManager.Iron - obj.IronCost < 0:
		return false
	if GameManager.Gold - obj.GoldCost < 0:
		return false
	return true


func charge_object(obj):
	GameManager.Wood -= obj.WoodCost
	GameManager.Stone -= obj.StoneCost
	GameManager.Iron -= obj.IronCost
	GameManager.Gold -= obj.GoldCost

# industry
func SpawnWoodCutterHut():
	SpawnObj(WoodCutterHut)
func SpawnStoneCutterHut():
	SpawnObj(StoneCutterhut)
func SpawnStockPile():
	SpawnObj(StockPile)
func spawn_ironmine_hut():
	SpawnObj(IronMineHut)
# Population
func SpawnHouse():
	SpawnObj(House)
# Food
func SpawnMill():
	SpawnObj(Mill)
func SpawnOrchard():
	SpawnObj(Orchard)
func SpawnFarm():
	SpawnObj(Farm)
# Wall
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

	currentSpawnable.collision_layer = 1
	currentSpawnable.collision_mask = 1

	get_tree().current_scene.add_child(currentSpawnable)

	GameManager.Current_State = GameManager.State.building
