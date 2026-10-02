class_name Citizen
extends CharacterBody3D


@export var SPEED = 5.0
const JUMP_VELOCITY = 4
var run_once := true
var Target

enum Task{
	Walking,
	Sitting,
	Sleeping,
	Wondering
}

var Home : Marker3D
var going_home :bool = false
@onready var  navigation : NavigationAgent3D = $NavigationAgent
var current_task = Task.Walking
var activities : Array

func _ready() -> void:
	pass
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if current_task == Task.Walking and not navigation.is_navigation_finished():
		var next_pos := navigation.get_next_path_position()
		var direction := (next_pos - global_position).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process(delta: float) -> void:
	$Label3D.text = str(current_task)
	match current_task:
		Task.Sitting:
			if run_once:
				run_once = false
				if is_instance_valid(Target):
					var interacted : bool = await Target._interact(self)
				current_task = Task.Wondering
				run_once = true
			pass
		Task.Walking:
			if navigation.is_navigation_finished():
				if going_home:
					current_task = Task.Sleeping
					return
				current_task = Task.Sitting
		Task.Wondering:
			activities.clear()
			for child in BuilderManager.map_root.get_children():
				if child.is_in_group("Community"):
					activities.append(child)
			if activities.size() > 0:
				Target = activities.pick_random()
				if Target.has_node("SpawnPoint") :
					if Target.is_in_group("House"):
						going_home = true
					navigation.target_position = Target.get_node("SpawnPoint").global_position
					current_task = Task.Walking
			pass
		Task.Sleeping:
			if run_once:
				run_once = false
				visible = false
				await get_tree().create_timer(15).timeout
				visible = true
				going_home = false;
				current_task = Task.Wondering
				run_once = true
