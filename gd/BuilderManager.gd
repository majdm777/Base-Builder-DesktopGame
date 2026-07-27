extends Node3D



var WoodCutterHut : PackedScene = ResourceLoader.load("res://Assets/WoodCutters.tscn")
var StoneCutterhut : PackedScene = ResourceLoader.load("res://Assets/StoneMasons.tscn")
var StockPile : PackedScene = ResourceLoader.load("res://Assets/Stockpile.tscn")
var Wall : PackedScene = ResourceLoader.load("res://Assets/wallNarrow.tscn")
var CornerWall : PackedScene = ResourceLoader.load("res://Assets/wallNarrowCorner.tscn")
var GateWall : PackedScene = ResourceLoader.load("res://Assets/wallNarrowGate.tscn")
var Orchard : PackedScene = ResourceLoader.load("res://Assets/Orchard.tscn")
var House : PackedScene = ResourceLoader.load("res://Assets/House.tscn")

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
	if AbleToBuild :
		if Input.is_action_just_pressed("LeftMouseDown"):
			var obj = currentSpawnable.duplicate()
			get_tree().current_scene.add_child(obj)
			obj.ActiveBuildableObject = false
			obj.runSpawn()
			obj.position = currentSpawnable.position
			get_tree().get_nodes_in_group("NavMesh")[0].bake_navigation_mesh(true)
	pass

func SpawnWoodCutterHut():
	SpawnObj(WoodCutterHut)

func SpawnStoneCutterHutr():
	SpawnObj(StoneCutterhut)


func SpawnObj(obj: PackedScene):
	if currentSpawnable:
		currentSpawnable.queue_free()

	currentSpawnable = obj.instantiate()

	# Prevent the preview from blocking the ray
	currentSpawnable.collision_layer = 0
	currentSpawnable.collision_mask = 0

	get_tree().current_scene.add_child(currentSpawnable)

	GameManager.Current_State = GameManager.State.building
