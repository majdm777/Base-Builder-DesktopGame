extends PanelContainer

const BAR_ROW := preload("res://Scenes/InterFace/bar_chip.tscn")     # adjust paths
const STAT_ROW := preload("res://Scenes/InterFace/Stat_chip.tscn")

func set_title(t: String) -> void:
	$VBox/Title.text = t

func add_bar(symbol: String, label: String) -> Node:
	var r = BAR_ROW.instantiate()
	$VBox/Content.add_child(r)
	r.setup(symbol, label)
	return r

func add_stat(label: String) -> Node:
	var r = STAT_ROW.instantiate()
	$VBox/Content.add_child(r)
	r.setup(label)
	return r
