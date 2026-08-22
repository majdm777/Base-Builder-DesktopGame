extends gatherer



func _ready() -> void:
	super()
	Hut.plot_ready.connect(_on_plot_ready)

func _process(delta: float) -> void:
	super(delta)

func _on_plot_ready(plot):
	Producers.append(plot)
	
	
func get_spawned_storage() -> Array:
	
	var mills: Array = []
	for mill in get_tree().get_nodes_in_group("Mills"):
		if mill.spawned:
			mills.append(mill)
	return mills
