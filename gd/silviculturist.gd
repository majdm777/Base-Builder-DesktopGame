extends CharacterBody3D  # adjust to your worker's actual base type

var plots_array: Array = []  # assign in inspector, or populate in _ready()
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var move_speed: float = 4.0
var Hut
var queue: Array = []
var current_target: Node3D = null
var is_busy: bool = false

func _ready() -> void:
	Hut.plot_ready.connect(_on_plot_ready)
	pass

func _on_plot_ready(plot: Node3D) -> void:
	queue.append(plot)
	if not is_busy:
		_process_next()

func _process_next() -> void:
	if queue.is_empty():
		is_busy = false
		return
	is_busy = true
	current_target = queue.pop_front()
	nav_agent.target_position = current_target.global_position

func _physics_process(delta: float) -> void:
	if not is_busy or current_target == null:
		return

	if nav_agent.is_navigation_finished():
		#current_target.plant()
		current_target.current_state = current_target.State.growing
		current_target = null
		_process_next()
		return

	var next_pos := nav_agent.get_next_path_position()
	var direction := (next_pos - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()
