extends Node3D



var WoodCutterHut : PackedScene = ResourceLoader.load("res://Assets/WoodCutters.tscn")
var StoneCutterhut : PackedScene = ResourceLoader.load("res://Assets/StoneMasons.tscn")
var StockPile : PackedScene = ResourceLoader.load("res://Assets/Stockpile.tscn")
var Wall : PackedScene = ResourceLoader.load("res://Assets/wallNarrow.tscn")
var CornerWall : PackedScene = ResourceLoader.load("res://Assets/wallNarrowCorner.tscn")
var GateWall : PackedScene = ResourceLoader.load("res://Assets/wallNarrowGate.tscn")
var Orchard : PackedScene = ResourceLoader.load("res://Assets/Orchard.tscn")
var House : PackedScene = ResourceLoader.load("res://Assets/House.tscn")

var currentSpawnable : StaticBody3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.Current_State == GameManager.State.building:
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(get_viewport().get_mouse_position())
		var to = from + camera.project_ray_normal(get_viewport().get_mouse_position())*1000
		var cursorPos=Plane(Vector3.UP,transform.origin.y).intersects_ray(from,to)
		currentSpawnable.position = Vector3(cursorPos.x,cursorPos.y,cursorPos.z)
	pass
	
func SpawnWoodCutterHut():
	SpawnObj(WoodCutterHut)

func SpawnStoneCutterHutr():
	SpawnObj(StoneCutterhut)


func SpawnObj(obj):
	if currentSpawnable !=null :
		currentSpawnable.queue_free()
	currentSpawnable = obj.instantiate()
	get_tree().root.add_child(currentSpawnable)
	GameManager.Current_State= GameManager.State.building
	pass 
