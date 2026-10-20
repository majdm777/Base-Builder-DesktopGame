class_name Post
extends BuildingObject

@export var capacity : int = 4
@export var hides_occupants : bool = false   # tower: true, checkpoint: false
@export var post_group : String = "Post"         # "Tower" or "CheckPoint"

var occupants : Array = []
var incoming := 0
var assigning_soldiers := false

func _ready() -> void:
	name = "Normal Post"

func _process(delta: float) -> void:
	if AttackManager.attack_in_progress and occupants.size() > 0 and not assigning_soldiers:
		assigning_soldiers = true
		await assign()
		assigning_soldiers = false
	
var remaining_spots : int:
	get: return capacity - occupants.size() - incoming

func runSpawn():
	await super()
	add_to_group(post_group)
	add_to_group("building")    # join only when really placed, so the ghost never counts

func _reserve_slot() -> bool:
	if not spawned or remaining_spots <= 0:
		return false
	incoming += 1
	return true

func cancel_reservation() -> void:
	incoming = maxi(incoming - 1, 0)

func _occupy(soldier: Node3D) -> bool:
	incoming = maxi(incoming - 1, 0)
	if occupants.size() >= capacity:
		return false
	soldier.visible = ! hides_occupants
	occupants.append(soldier)
	return true

func leave(soldier: Node3D) -> void:
	occupants.erase(soldier)

func run_despawn():
	for s in occupants:
		if is_instance_valid(s):
			s.on_post_lost()
	occupants.clear()
	super()

func assign():
	var lost_occupants = occupants.duplicate()
	occupants.clear()
	for s in lost_occupants:
		if is_instance_valid(s):
			s.on_post_lost()
			await get_tree().create_timer(1).timeout
