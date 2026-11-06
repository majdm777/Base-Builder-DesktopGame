class_name Archer
extends Soldier

const ARROW := preload("res://Scenes/Weapons/Arrow.tscn")
@export var shoot_height := 1.5  
var arrow : Node

#func _ready():
	#super()

func _physics_process(delta: float) -> void:
	super(delta)
	pass
	

func _process(delta: float) -> void:
	super(delta)
	pass
	
func _Attack() -> void:
	if cooldown:
		return
	cooldown = true

	if is_instance_valid(current_target) and ARROW:
		var arrow = ARROW.instantiate()
		BuilderManager.map_root.add_child(arrow)          # add first, then position
		arrow.launch(global_position + Vector3(0, shoot_height, 0),
				current_target, attack_damage, self)
		await get_tree().create_timer(attack_interval).timeout
	else:
		current_state = State.Idle

	cooldown = false
