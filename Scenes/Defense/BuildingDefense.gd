class_name BuildingDefense
extends BuildingObject

const DEFENSE_CARD := preload("res://Scenes/Interface/defense_card.tscn")


@export_enum("WatchTower") var DefenseType : String = "WatchTower"
@export var capacity : int = 4
@export var damage_per_soldier : int = 15
@export var attack_interval : float = 1.0
@export var shoot_height := 16.0
@export var hides_occupants : bool = true
@export var Available : bool = true    # can soldiers be assigned here
@export var Active := true             # does it shoot

var defense_card
var occupants : Array = []
var incoming := 0
var cooldown := 0.0
var current_target : Node3D = null

@onready var detection_area : Area3D = $Range

# a ghost or a closed tower never reports free slots
var remaining_spots : int:
	get:
		if not spawned or not Available:
			return 0
		return capacity - occupants.size() - incoming


func _process(delta: float) -> void:
	super(delta)
	if not spawned or not Active:
		return
	cooldown -= delta
	if cooldown > 0.0:
		return
	_clean_occupants()
	if occupants.is_empty():
		return
	current_target = _pick_target()
	if current_target == null:
		return
	cooldown = attack_interval
	_attack()


func get_dps() -> float:
	return damage_per_soldier * occupants.size() / max(0.1, attack_interval)


# ---------------- Combat ----------------

func _pick_target() -> Node3D:
	var nearest : Node3D = null
	var nearest_dist := INF
	for body in detection_area.get_overlapping_bodies():
		if not is_instance_valid(body) or not body.is_in_group("Enemy"):
			continue
		var d := global_position.distance_to(body.global_position)
		if d < nearest_dist:
			nearest = body
			nearest_dist = d
	return nearest


func _attack() -> void:
	pass


# ---------------- Garrison ----------------

func _reserve_slot() -> bool:
	if remaining_spots <= 0:
		return false
	incoming += 1
	return true


func _cancel_reservation() -> void:
	incoming = maxi(incoming - 1, 0)


func _occupy(soldier: Node3D) -> bool:
	incoming = maxi(incoming - 1, 0)
	if occupants.size() >= capacity:
		return false
	occupants.append(soldier)
	soldier.visible = not hides_occupants
	return true


func _leave(soldier: Node3D) -> void:         # call this from the soldier's death code
	occupants.erase(soldier)


func _clean_occupants() -> void:               # safety net for freed nodes
	occupants = occupants.filter(func(s): return is_instance_valid(s))


func _release_all() -> void:
	for s in occupants.duplicate():
		if is_instance_valid(s):
			s.on_post_lost()
	occupants.clear()


func _deploy() -> void:
	_release_all()


func run_despawn():
	_release_all()
	super()


# ---------------- Info panel ----------------

func build_info(container: Control) -> void:
	super(container)
	defense_card = DEFENSE_CARD.instantiate()
	container.add_child(defense_card)
	defense_card.setup(self)


func update_info() -> void:
	super()
	if is_instance_valid(defense_card):
		defense_card.update()
