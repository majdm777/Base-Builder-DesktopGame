extends Node3D

var main_node:StaticBody3D
var Map
var plots: Array = []

var _Tree: PackedScene = ResourceLoader.load("res://Scenes/RecourceProducers/Trees/tree.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Map = get_parent().get_parent().get_parent()
	plots = get_children()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
