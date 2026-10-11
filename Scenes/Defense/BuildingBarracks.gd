class_name BuildingBarracks
extends BuildingObject

signal queue_changed

# what this barracks can train. Add a row per soldier type.
# scene_path is a string (loaded at spawn time), so a missing scene can't break parsing.
var trainable : Dictionary = {
	GameManager.Soldier.ARCHER: {
		"name": "Archer",
		"pop_cost": 1,
		"iron_cost": 5,
		"train_time": 10.0,
		"scene_path": "res://Scenes/Soldiers/archer.tscn",
	},
}

var queue : Array = []   # soldier types waiting, front is being trained
var progress := 0.0      # seconds spent on the front entry

func _process(delta: float) -> void:
	super(delta)
	if not spawned or queue.is_empty():
		return
	progress += delta
	var type = queue[0]
	if progress >= trainable[type].train_time:
		queue.pop_front()
		progress = 0.0
		_spawn_soldier(type)
		queue_changed.emit()

func can_train(type) -> bool:
	var d : Dictionary = trainable[type]
	return spawned \
		and GameManager.AvlPopulation >= d.pop_cost \
		and ResourceManager.resources["iron"] >= d.iron_cost

# cost is charged now, so queued soldiers can never be double-spent
func train(type) -> bool:
	if not can_train(type):
		return false
	var d : Dictionary = trainable[type]
	ResourceManager.resources["iron"] -= d.iron_cost
	GameManager.assign_citizen()
	queue.append(type)
	queue_changed.emit()
	return true

func cancel(index: int) -> void:
	if index < 0 or index >= queue.size():
		return
	var d : Dictionary = trainable[queue[index]]
	ResourceManager.resources["iron"] += d.iron_cost
	# TODO: give the pop back (see note below)
	queue.remove_at(index)
	if index == 0:
		progress = 0.0   # the next entry starts from zero
	queue_changed.emit()

func _spawn_soldier(type) -> void:
	var scene : PackedScene = load(trainable[type].scene_path)
	var soldier = scene.instantiate()
	BuilderManager.map_root.add_child(soldier)
	soldier.global_position = $SpawnPoint.global_position
	GameManager.army[type] += 1

func run_despawn() -> void:
	while not queue.is_empty():
		cancel(queue.size() - 1)   # refund everything still queued
	super()
