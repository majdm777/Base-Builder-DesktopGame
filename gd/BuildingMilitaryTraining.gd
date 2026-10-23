class_name BuildingMiltaryTraining
extends BuildingObject

signal queue_changed

const TRAINING_SECTION := preload("res://Scenes/InterFace/training_section.tscn")   # adjust the path
var training_ui : Node

# What this barracks can train. One entry per soldier type.
# "costs" uses the same keys as ResourceManager.resources, so a knight can cost food, etc.
var trainable : Dictionary = {}

var queue : Array = []     # soldier types, the front one is being trained
var progress := 0.0        # seconds spent on the front entry

func _ready() -> void:
	trainable = {
		"Archer": {
			"name": "Archer",
			"pop_cost": 1,
			"costs": {"iron": 0},
			"train_time": 3.0,
			"scene_path": "res://Scenes/Soldiers/Knight.tscn",
		},
	}
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
	if not spawned:
		return false
	var d : Dictionary = trainable[type]
	if GameManager.AvlPopulation < d.pop_cost:
		return false
	for res in d.costs:
		if ResourceManager.resources[res] < d.costs[res]:
			return false
	return true


# Cost is charged now, so queued soldiers can never be paid for twice.
func train(type) -> bool:
	if not can_train(type):
		return false
	var d : Dictionary = trainable[type]
	for res in d.costs:
		ResourceManager.resources[res] -= d.costs[res]
	GameManager.assign_citizen()
	GameManager.Soldiers[type] += 1   #TODO
	queue.append(type)
	queue_changed.emit()
	return true


func cancel(index: int) -> void:
	if index < 0 or index >= queue.size():
		return
	var d : Dictionary = trainable[queue[index]]
	for res in d.costs:
		ResourceManager.resources[res] += d.costs[res]
	# TODO: give the citizen back to the pool 
	queue.remove_at(index)
	if index == 0:
		progress = 0.0                    # the next entry starts from zero
	queue_changed.emit()


func _spawn_soldier(type) -> void:
	var scene : PackedScene = load(trainable[type].scene_path)
	var soldier = scene.instantiate()
	#soldier.soldier_type = type           # see question 3
	BuilderManager.map_root.add_child(soldier)
	soldier.global_position = $SpawnPoint.global_position
	#GameManager.Soldiers[type.name] += 1


func run_despawn() -> void:
	while not queue.is_empty():
		cancel(queue.size() - 1)          # refund everything still queued
	super()


func build_info(container: Control) -> void:
	super(container)                       # common section first
	training_ui = TRAINING_SECTION.instantiate()
	container.add_child(training_ui)
	training_ui.setup(self)

func update_info() -> void:
	super()
	if is_instance_valid(training_ui):
		training_ui.update()
