extends Node3D

@onready var wood_meshes := $wood.get_children()
@onready var stone_meshes := $stone.get_children()
@onready var iron_meshes := $iron.get_children()

const WOOD_LEVELS := [1, 2, 4, 8, 16, 32, 64, 128, 256]
const STONE_LEVELS := [1, 2, 4, 8, 16, 32, 64, 128, 256]
const IRON_LEVELS := [1, 2, 4, 8, 16, 32, 64, 128, 256]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var wood_index := -1
	var stone_index := -1
	var iron_index := -1
	for i in WOOD_LEVELS.size():
		if ResourceManager.resources["wood"] >= WOOD_LEVELS[i]:
			wood_index = i
	for i in wood_meshes.size():
		wood_meshes[i].visible = (i <= wood_index)

	for i in STONE_LEVELS.size():
		if ResourceManager.resources["stone"] >= STONE_LEVELS[i]:
			stone_index = i
	for i in stone_meshes.size():
		stone_meshes[i].visible = (i <= stone_index)

	for i in IRON_LEVELS.size():
		if ResourceManager.resources["iron"] >= IRON_LEVELS[i]:
			iron_index = i
	for i in iron_meshes.size():
		iron_meshes[i].visible = (i <= iron_index)
	pass
