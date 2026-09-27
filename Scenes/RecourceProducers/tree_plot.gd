extends MeshInstance3D  # adjust to whatever your plot node type actually is

enum State {
	ready,
	empty,
	growing,
	harvested
}

signal plot_ready(plot)

var tree_scene: PackedScene = ResourceLoader.load("res://Scenes/RecourceProducers/Trees/tree.tscn")

var amount:int = 0 
var current_state: State
var run_once := true
var time_to_grow: int
var current_tree: Node3D = null
var ready_emitted := false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# only poll while we actually expect a tree to be there
	match current_state:
		State.empty:
			if not ready_emitted:
				ready_emitted = true
				plot_ready.emit(self)
		State.growing:
			ready_emitted = false
			get_node("Tree_lvl0").visible = false
			if run_once:
				run_once = false
				get_node("Tree_lvl1").visible = true
				_start_growth()
		State.ready:
			get_node("Tree_lvl1").visible = false
			if not is_instance_valid(current_tree):
				current_state = State.harvested
			pass 
		State.harvested:
			get_node("Tree_lvl0").visible = true
			current_state = State.empty

func plant() -> void:
	current_tree = tree_scene.instantiate()
	get_parent().get_parent().get_parent().add_child(current_tree)  # adjust to your actual "map" node
	current_tree.global_position = global_position
	current_tree.scale = Vector3(1,1,1)
	current_state = State.growing

func _start_growth() -> void:
	await get_tree().create_timer(time_to_grow).timeout
	if current_state != State.growing:
		return
	plant()
	current_state = State.ready
	run_once = true
