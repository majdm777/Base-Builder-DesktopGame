# BuildingFarm.gd
extends BuildingObject
@export var time_to_grow: int = 5
signal plot_ready(plot) 
var plots
@export var crops_amount: int = 20

func _ready() -> void:
	super()
	plots = $farm/beds.get_children()
	for plot in plots:
		plot.plot_ready.connect(_on_plot_ready)
	building_spawned.connect(_on_spawned)

func _on_spawned() -> void:
	for plot in plots:
		plot.amount = crops_amount/plots.size()
		plot.time_to_grow = time_to_grow
		plot.current_state = plot.State.empty

func _on_plot_ready(plot) -> void:
	plot_ready.emit(plot)
