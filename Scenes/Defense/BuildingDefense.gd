class_name BuildingDefense
extends BuildingObject

@export var capacity : int = 4
@export var damage_per_archer : int = 15
@export var attack_interval : float = 1.0


@onready var detection_area : Area3D = $Range

var occupants : Array
var cooldown := 0.0

var current_target
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() # Replace with function body.
	name = "WatchTower"


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
	cooldown = attack_interval
	current_target._damage(damage_per_archer * occupants.size() , self)



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
	
func _occupy(archer: Node3D) -> bool:
	if occupants.size() < capacity:
		occupants.append(archer)
		return true
	return false
func run_despawn():
	for i in occupants:
		pass  # survivors go back to the free pool
	occupants.clear()
	super()
