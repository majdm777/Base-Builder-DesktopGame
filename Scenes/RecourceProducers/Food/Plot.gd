extends MeshInstance3D
signal plot_ready(plot)

enum State {
	ready,
	empty,
	growing,
	harvested
}

@onready var plot = get_children()
var plot_amount:int =0 
var current_state: State
var run_once := true
var time_to_grow: int

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	match current_state:
		State.empty:
			for i in plot:
				i.visible = false
			current_state = State.growing

		State.growing:
			if run_once:
				run_once = false
				for i in plot:
					await get_tree().create_timer(time_to_grow).timeout
					i.visible = true
				current_state = State.ready
				plot_ready.emit(self)
				run_once = true

		State.harvested:
			current_state = State.empty
