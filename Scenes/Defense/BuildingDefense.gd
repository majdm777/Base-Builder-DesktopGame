class_name BuildingDefense
extends BuildingObject

const DEFENSE_CARD := preload("res://Scenes/Interface/defense_card.tscn")
const ARROW := preload("res://Scenes/Weapons/Arrow.tscn")
var defense_card
@export var shoot_height := 16.0

@export var capacity : int = 4
@export var damage_per_soldier : int = 15
@export var attack_interval : float = 1.0
@export var hides_occupants : bool = true 
var dps : float = 0

@onready var detection_area : Area3D = $Range
@export_enum("WatchTower") var DefenseType : String = "WatchTower"
var occupants : Array
var cooldown := 0.0

var current_target

var incoming := 0
var assigning_soldiers := false

@export var Available : bool = true # if true the tower can be occupied 
@export var Active := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() # Replace with function body.
	name = "Defense"
	dps = (damage_per_soldier * occupants.size()) / max(0.1 , attack_interval)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if not spawned: # or# archers.size() == 0:
		return
	cooldown -= delta
	if cooldown > 0.0:
		return
	current_target = _pick_target()
	if current_target == null:
		return
	print("ATTACK!")
	cooldown = attack_interval
	_Attack()

var remaining_spots : int:
	get: return capacity - occupants.size() - incoming

func _reserve_slot() -> bool:
	if not spawned or remaining_spots <= 0 or not Available:
		return false
	incoming += 1
	return true
func cancel_reservation() -> void:
	incoming = maxi(incoming - 1, 0)

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
	
func _occupy(soldier: Node3D) -> bool:
	incoming = maxi(incoming - 1, 0)
	if occupants.size() >= capacity:
		return false
	soldier.visible = ! hides_occupants
	occupants.append(soldier)
	return true
func run_despawn():
	for s in occupants:
		if is_instance_valid(s):
			s.on_post_lost()
	occupants.clear()
	super()
	occupants.clear()
	super()

func build_info(container: Control) -> void:
	super(container)
	defense_card = DEFENSE_CARD.instantiate()
	container.add_child(defense_card)
	defense_card.setup(self)
	pass
 
func update_info() -> void:
	super()
	if is_instance_valid(defense_card):
		defense_card.update()
	
func _Attack():
	if is_instance_valid(current_target) and ARROW:
		var arrow = ARROW.instantiate()
		BuilderManager.map_root.add_child(arrow)          # add first, then position
		arrow.launch(global_position + Vector3(0, shoot_height, 0),
				current_target, damage_per_soldier * occupants.size(), self)
		await get_tree().create_timer(attack_interval).timeout
