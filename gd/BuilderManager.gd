extends Node3D

var WoodCutterHut : PackedScene = ResourceLoader.load("res://Scenes/ResourceExtraction/wood_cutter.tscn")
var StoneCutterhut : PackedScene = ResourceLoader.load("res://Scenes/ResourceExtraction/stone_cutter_hut.tscn")
var IronMinerHut: PackedScene = ResourceLoader.load("res://Scenes/ResourceExtraction/iron_miner_hut.tscn")
var StockPile : PackedScene = ResourceLoader.load("res://Scenes/Storage/Stockpile.tscn")

var Mill : PackedScene = ResourceLoader.load("res://Scenes/Storage/mill.tscn")
var Farm : PackedScene = ResourceLoader.load("res://Scenes/Farms/farm.tscn")
var TreePlantation : PackedScene = ResourceLoader.load("res://Scenes/RecourceProducers/tree_planter.tscn")

var SmallHouse : PackedScene = ResourceLoader.load("res://Scenes/Houses/small_house.tscn")
var MediumHouse :PackedScene = ResourceLoader.load("res://Scenes/Houses/medium_house.tscn")

var StoneMine:PackedScene = ResourceLoader.load("res://Scenes/Mines/stone_mine.tscn")
var IronMine:PackedScene = ResourceLoader.load("res://Scenes/Mines/iron_mine.tscn")

var Church :PackedScene = ResourceLoader.load("res://Scenes/Community/Church.tscn")
var Shop :PackedScene = ResourceLoader.load("res://Scenes/Community/Shop.tscn")
var Bar :PackedScene = ResourceLoader.load("res://Scenes/Community/Bar.tscn")

var Wood_Wall : PackedScene = ResourceLoader.load("res://Scenes/Walls/Wood_Wall.tscn")
var Wood_Gate : PackedScene = ResourceLoader.load("res://Scenes/Walls/Wood_Gate.tscn")
var Stone_Wall : PackedScene = ResourceLoader.load("res://Scenes/Walls/Stone_Wall.tscn")
var Stone_Gate : PackedScene = ResourceLoader.load("res://Scenes/Walls/Stone_Gate.tscn")
var Stone_Arch : PackedScene = ResourceLoader.load("res://Scenes/Walls/Stone_Arch.tscn")
var Tight_Corner : PackedScene = ResourceLoader.load("res://Scenes/Walls/Stone_Corner_Tight.tscn")
var Wide_Corner : PackedScene = ResourceLoader.load("res://Scenes/Walls/Stone_Corner_Wide.tscn")


var WatchTower : PackedScene = ResourceLoader.load("res://Scenes/Defense/WatchTower.tscn")
var Post : PackedScene = ResourceLoader.load("res://Scenes/Defense/Post.tscn")
var Barracks : PackedScene = ResourceLoader.load("res://Scenes/Defense/Barracks.tscn")


var AbleToBuild : bool = true
var currentSpawnable : StaticBody3D

# --- Map reference (lazy, resolved on first use since this runs as an autoload) ---
var map_root : Node

signal selection_changed(node)
var selected : Node3D = null

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
		if Input.is_action_just_pressed("LeftMouseDown") and not _mouse_over_ui():
			_place_building()

	if Input.is_action_just_pressed("RightMouseDown"):
		currentSpawnable.queue_free()
		currentSpawnable = null
		GameManager.Current_State = GameManager.State.play
		return

	if Input.is_action_just_pressed("rotation"):
		currentSpawnable.rotation_degrees += Vector3(0, 45, 0)
func _mouse_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null


func _unhandled_input(event: InputEvent) -> void:
	if GameManager.Current_State != GameManager.State.play:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_0:
		if selected is BuildingBarracks:
			print("train: ", selected.train(GameManager.Soldiers["Archer"]))
	if event.is_action_pressed("ui_cancel"):
		clear_selection()
		return
	if not event.is_action_pressed("LeftMouseDown"):
		return
	if _mouse_over_ui():
		return

	var picked := _pick_selectable()
	if picked:
		select(picked)
	else:
		clear_selection()


func _pick_selectable() -> Node3D:
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	query.collide_with_areas = false

	for i in 8:
		var result := get_world_3d().direct_space_state.intersect_ray(query)
		if result.is_empty():
			return null
		var hit = result.collider
		if _is_selectable(hit):
			return hit
		query.exclude.append(result.rid)
	return null


func _is_selectable(node: Object) -> bool:
	if not node.has_method("build_info"):
		return false
	if "spawned" in node and not node.spawned:
		return false
	return true

func _place_building() -> void:
	var obj = currentSpawnable.duplicate()
	obj.position = currentSpawnable.position
	obj.rotation = currentSpawnable.rotation

	_get_map_root().add_child(obj)
	print("Placed object groups: ", obj.get_groups())

	obj.ActiveBuildableObject = false

	charge_object(obj)
	if obj.PopulationCost > 0:
		GameManager.assign_citizen()
	#GameManager.remove_citizen(obj.PopulationCost)

	# Wait until the navmesh has actually been rebaked to include this
	# building before spawning its actor, so it never spawns on stale nav data.
	if not obj.is_in_group("Gate"):
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

	if Input.is_action_just_released("LeftMouseDown") and not _mouse_over_ui():
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
				await _handle_navchunk(aabb)

func _handle_navchunk(aabb : AABB):
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
	GameManager.AvlPopulation -= obj.PopulationCost

# industry
func SpawnWoodCutterHut():
	SpawnObj(WoodCutterHut)
func SpawnStoneCutterHut():
	SpawnObj(StoneCutterhut)
func SpawnStockPile():
	SpawnObj(StockPile)
func spawn_ironmine_hut():
	SpawnObj(IronMinerHut)
# Population
func SpawnSmallHouse():
	SpawnObj(SmallHouse)
func SpawnMediumHouse():
	SpawnObj(MediumHouse)
# Food
func SpawnMill():
	SpawnObj(Mill)
func SpawnFarm():
	SpawnObj(Farm)
func SpawnTreePlantation():
	SpawnObj(TreePlantation)
# Wall

#Mines
func SpawnStoneMine():
	SpawnObj(StoneMine)
func SpawnIronMine():
	SpawnObj(IronMine)

#community
func SpawnChurch():
	SpawnObj(Church)
func SpawnShop():
	SpawnObj(Shop)
func SpawnBar():
	SpawnObj(Bar)

#wall
func SpawnWoodWall():
	SpawnObj(Wood_Wall)
func SpawnWoodGate():
	SpawnObj(Wood_Gate)
func SpawnWatchTower():
	SpawnObj(WatchTower)
func SpawnPost():
	SpawnObj(Post)
func SpawnBarracks():
	SpawnObj(Barracks)
func SpawnStoneWall():
	SpawnObj(Stone_Wall)
func SpawnStoneGate():
	SpawnObj(Stone_Gate)
func SpawnStoneArch():
	SpawnObj(Stone_Arch)
func SpawnTightCorner():
	SpawnObj(Tight_Corner)
func SpawnWideCorner():
	SpawnObj(Wide_Corner)
	

func SpawnObj(obj: PackedScene):
	if currentSpawnable:
		currentSpawnable.queue_free()

	currentSpawnable = obj.instantiate()

	currentSpawnable.collision_layer = 0
	currentSpawnable.collision_mask = 0

	get_tree().current_scene.add_child(currentSpawnable)

	GameManager.Current_State = GameManager.State.building


func select(node: Node3D) -> void:
	if selected == node:
		return
	selected = node
	selection_changed.emit(node)

func clear_selection() -> void:
	select(null)
