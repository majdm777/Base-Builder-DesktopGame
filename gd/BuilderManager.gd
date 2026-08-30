extends Node3D

var WoodCutterHut : PackedScene = ResourceLoader.load("res://Scenes/ResourceExtraction/wood_cutter.tscn")
var StoneCutterhut : PackedScene = ResourceLoader.load("res://Scenes/ResourceExtraction/StoneMasons.tscn")
var IronMineHut: PackedScene = ResourceLoader.load("res://Scenes/Mines/iron_mine.tscn")
var StockPile : PackedScene = ResourceLoader.load("res://Scenes/Storage/Stockpile.tscn")

var Wall : PackedScene = ResourceLoader.load("res://Scenes/Walls/wallNarrow.tscn")
var CornerWall : PackedScene = ResourceLoader.load("res://Scenes/Walls/wallNarrowCorner.tscn")
var GateWall : PackedScene = ResourceLoader.load("res://Scenes/Walls/wallNarrowGate.tscn")

var Orchard : PackedScene = ResourceLoader.load("res://Scenes/Orchard.tscn")
var Mill : PackedScene = ResourceLoader.load("res://Scenes/Storage/mill.tscn")
var Farm : PackedScene = ResourceLoader.load("res://Scenes/Farms/farm.tscn")

var House : PackedScene = ResourceLoader.load("res://Scenes/Houses/House.tscn")

var AbleToBuild : bool = true
var currentSpawnable : StaticBody3D

# --- Map reference (lazy, resolved on first use since this runs as an autoload) ---
var map_root : Node


func _get_map_root() -> Node:
	if map_root == null:
		map_root = get_tree().current_scene.find_child("Map", true, false)
	return map_root


# --- Building footprint, read straight off the StaticBody3D's own CollisionShape3D ---
# (Not the Area3D's shape - that one's just for placement-validity checks.)
func _building_world_aabb(building: StaticBody3D) -> AABB:
	var collision_shape := building.get_node("CollisionShape3D") as CollisionShape3D
	var local_aabb := collision_shape.shape.get_debug_mesh().get_aabb()
	return collision_shape.global_transform * local_aabb


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
	query.collision_mask = 2
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

	_get_map_root().add_child(obj)
	print("Placed object groups: ", obj.get_groups())

	obj.ActiveBuildableObject = false

	charge_object(obj)
	GameManager.remove_citizen(obj.PopulationCost)

	# Wait until the navmesh has actually been rebaked to include this
	# building before spawning its actor, so it never spawns on stale nav data.
	var aabb := _building_world_aabb(obj)
	await NavChunks.rebake_affected_chunks(aabb)

	obj.collision_layer = 1
	obj.collision_mask = 1

	obj.runSpawn()
	obj.spawned = true


func _handle_destroying_state() -> void:
	if is_instance_valid(currentSpawnable):
		currentSpawnable.queue_free()
		currentSpawnable = null

	if Input.is_action_just_released("LeftMouseDown"):
		var camera := get_viewport().get_camera_3d()
		var mouse_pos := get_viewport().get_mouse_position()

		var from := camera.project_ray_origin(mouse_pos)
		var to := from + camera.project_ray_normal(mouse_pos) * 1000.0

		var query := PhysicsRayQueryParameters3D.create(from, to)

		# Building collision layer
		query.collision_mask = 1

		var result := get_world_3d().direct_space_state.intersect_ray(query)

		if result:
			print(result.collider.name)
			var building = result.collider

			if building.is_in_group("building") and building.spawned:
				print("Destroying: ", building.name)

				# Capture the footprint BEFORE freeing - once run_despawn()
				# queue_frees it, the CollisionShape3D is gone.
				var aabb := _building_world_aabb(building)

				building.run_despawn()

				# queue_free() is deferred; wait a frame so the building has
				# actually left the tree before the bake scans nav_geometry,
				# otherwise the removed building can leave a phantom obstacle
				# in the navmesh until some unrelated rebake happens to fix it.
				await get_tree().process_frame
				await NavChunks.rebake_affected_chunks(aabb)


func Can_Afford(obj) -> bool:
	if ResourceManager.resources["wood"] - obj.WoodCost < 0:
		return false
	if ResourceManager.resources["stone"] - obj.StoneCost < 0:
		return false
	if ResourceManager.resources["iron"] - obj.IronCost < 0:
		return false
	if ResourceManager.resources["gold"] - obj.GoldCost < 0:
		return false
	return true


func charge_object(obj):
	ResourceManager.resources["wood"] -= obj.WoodCost
	ResourceManager.resources["stone"] -= obj.StoneCost
	ResourceManager.resources["iron"] -= obj.IronCost
	ResourceManager.resources["gold"] -= obj.GoldCost

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

	currentSpawnable.collision_layer = 0
	currentSpawnable.collision_mask = 0

	get_tree().current_scene.add_child(currentSpawnable)

	GameManager.Current_State = GameManager.State.building
