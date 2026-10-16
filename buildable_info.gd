extends PanelContainer

const CHIP := preload("res://Scenes/InterFace/stat_chip.tscn")   # adjust the path

@onready var name_label : Label = $VBox/Name
@onready var cost_group : HFlowContainer = $VBox/Cost
@onready var gives_group : HFlowContainer = $VBox/Gives

var shown : Node = null
var cost_chips : Array = []     # [{ "chip": ..., "check": Callable }]


func _ready() -> void:
	_ignore_mouse(self)
	visible = false


func _process(_delta: float) -> void:
	var g = BuilderManager.currentSpawnable
	var active : bool = GameManager.Current_State == GameManager.State.building \
		and is_instance_valid(g)

	if not active:
		if visible:
			visible = false
			shown = null
		return

	if g != shown:
		_build(g)
	_refresh()


func _build(b: Node) -> void:
	shown = b
	cost_chips.clear()
	for c in cost_group.get_children():
		c.queue_free()
	for c in gives_group.get_children():
		c.queue_free()

	name_label.text = b.display_name if "display_name" in b else str(b.name)

	# what it costs (red when you can't afford it)
	_cost_chip("W", b.WoodCost, func(): return ResourceManager.resources["wood"] >= b.WoodCost)
	_cost_chip("S", b.StoneCost, func(): return ResourceManager.resources["stone"] >= b.StoneCost)
	_cost_chip("I", b.IronCost, func(): return ResourceManager.resources["iron"] >= b.IronCost)
	_cost_chip("G", b.GoldCost, func(): return ResourceManager.resources["gold"] >= b.GoldCost)
	_cost_chip("P", b.PopulationCost, func(): return GameManager.AvlPopulation >= b.PopulationCost)

	# what it gives
	if b.IncreasePopcap:
		_gives_chip("H+", b.IncreaseCapAmount)
	_gives_chip("W", b.wood_capacity)
	_gives_chip("S", b.stone_capacity)
	_gives_chip("I", b.iron_capacity)
	_gives_chip("G", b.gold_capacity)
	_gives_chip("F", b.food_capacity)

	cost_group.visible = cost_group.get_child_count() > 0
	gives_group.visible = gives_group.get_child_count() > 0
	_ignore_mouse(self)             # the new chips need it too
	visible = true


func _cost_chip(symbol: String, amount, check: Callable) -> void:
	if amount <= 0:
		return
	var chip = CHIP.instantiate()
	cost_group.add_child(chip)
	chip.set_data(symbol, str(amount))
	cost_chips.append({"chip": chip, "check": check})


func _gives_chip(symbol: String, amount) -> void:
	if amount <= 0:
		return
	var chip = CHIP.instantiate()
	gives_group.add_child(chip)
	chip.set_data(symbol, "+%d" % amount)


# re-checks affordability, because resources change while you place
func _refresh() -> void:
	for e in cost_chips:
		e.chip.set_ok(e.check.call())


func _ignore_mouse(n: Node) -> void:
	if n is Control:
		n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_ignore_mouse(c)
