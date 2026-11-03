class_name BuildingMine
extends BuildingObject

@export var time_mining :int

var ResourceAmount :int 
@export_enum("stone", "iron")
var ResourceType: String

@onready var SpawnPoint := $Building/SpawnPoint
@onready var Building := $Building

const MINE_CARD = preload("res://Scenes/Interface/mine_card.tscn")
var mine_card : Node

func _ready() -> void:
	super()
	$Building.SpawnPoint_ready.connect(_on_spawnpoint_ready)
	if is_instance_valid(SpawnPoint):
		ResourceAmount = SpawnPoint.remaining_resource_amount
	else:
		ResourceAmount = 0
	
func _process(delta: float) -> void:
	super(delta)
	if is_instance_valid(SpawnPoint):
		ResourceAmount = SpawnPoint.remaining_resource_amount
	else:
		ResourceAmount = 0
	#if run_once and spawned:
		#run_once = false
		#await _mining()
		#run_once = true
	#pass
	
# Called when the node enters the scene tree for the first time.
#func _mining():
	#var animation :=$CharacterBody3D/AnimationPlayer
	#if animation != null:
		#animation.play("mining")
		#await animation.animation_finished
		#
		#await get_tree().create_timer(time_mining).timeout
#
		#animation.play_backwards("mining")
		#await animation.animation_finished
		#await get_tree().create_timer(2).timeout
		#ResourceManager.resources[ResourceType] += ResourceAmount
		#print(ResourceManager.Iron)
	#pass

func build_info(container: Control) -> void:
	super(container)
	mine_card = MINE_CARD.instantiate()
	container.add_child(mine_card)
	mine_card.setup(self)
	pass
 
func update_info() -> void:
	super()
	if is_instance_valid(mine_card):
		mine_card.update()

func _on_spawnpoint_ready():
	if is_instance_valid(SpawnPoint):
		return
	SpawnPoint = $Building/SpawnPoint
