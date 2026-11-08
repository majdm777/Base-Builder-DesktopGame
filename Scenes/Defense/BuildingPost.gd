class_name BuildingPost
extends BuildingObject

@export var capacity : int = 4
@export var hides_occupants : bool = false   # tower: true, checkpoint: false


@export_enum("NORMAL","PRIORITY","GATE","RANGE") var PostType : String = "NORMAL"

var occupants : Array = []  
var incoming := 0
var assigning_soldiers := false

@export var Available : bool = true # if true the post can be occupied 

func _ready() -> void:
	super()
	AttackManager.round_started.connect(_on_round_started)
	name = "Normal Post"

func _process(delta: float) -> void:
	super(delta)
	
var remaining_spots : int:
	get: return capacity - occupants.size() - incoming

func runSpawn():
	await super()
	add_to_group("Post")
	add_to_group("building")    # join only when really placed, so thea ghost never counts

func _reserve_slot() -> bool:
	if not spawned or remaining_spots <= 0 or not Available:
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

func _deploy():
	if occupants.size() > 0 and not assigning_soldiers:
		assigning_soldiers = true
		await assign()
		assigning_soldiers = false
	pass

func _on_round_started():
	_deploy()
