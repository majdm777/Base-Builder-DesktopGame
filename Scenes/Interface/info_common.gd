extends VBoxContainer

const CHIP := preload("res://Scenes/Interface/Stat_chip.tscn")   # adjust the path

@onready var name_label : Label = $Name
@onready var preview = $Preview
@onready var health_bar : ProgressBar = $Health/HealthBar
@onready var health_label : Label = $Health/HealthLabel
@onready var cost_section = $Cost
@onready var capacity_section = $Capacity
@onready var population_section = $Population
@onready var worker_section = $WorkerSection
@onready var worker_preview = $WorkerSection/WorkerView
@onready var demolish_button : Button = $Buttons/DemolishButton

var building : BuildingObject
var _worker_shown := false


func setup(b: BuildingObject) -> void:
	building = b
	name_label.text = b.display_name
	preview.visible = preview.show_node(b)

	# placeholder letters, to be replaced by icons later
	_fill(cost_section, [
		["W", b.WoodCost], ["S", b.StoneCost],
		["I", b.IronCost], ["G", b.GoldCost],
	])
	_fill(capacity_section, [
		["W", b.wood_capacity], ["S", b.stone_capacity], ["I", b.iron_capacity],
		["G", b.gold_capacity], ["F", b.food_capacity],
	])
	_fill(population_section, [
		["P-", b.PopulationCost],
		["H+", b.IncreaseCapAmount if b.IncreasePopcap else 0],
	])

	demolish_button.visible = b.can_demolish
	demolish_button.pressed.connect(func():
		b.demolish()
		BuilderManager.clear_selection())

	worker_section.visible = false
	update()


func update() -> void:
	if not is_instance_valid(building):
		return
	health_bar.max_value = building.Max_Health
	health_bar.value = building.Health
	health_label.text = "%d / %d" % [building.Health, building.Max_Health]

	# the worker spawns a couple of seconds after placement, so check every tick
	if not _worker_shown and building.SpawnActor:
		var w = building.CurrentActor
		if is_instance_valid(w) and w.is_inside_tree():
			_worker_shown = worker_preview.show_node(w)
			worker_section.visible = _worker_shown


# shows a chip per non-zero entry, and hides the whole section if nothing is non-zero
func _fill(section: Control, entries: Array) -> void:
	var chips : Control = section.get_node("Chips")
	var any := false
	for e in entries:
		#if e[1] <= 0:
			#continue
		var chip = CHIP.instantiate()
		chips.add_child(chip)
		chip.set_data(e[0], str(e[1]))
		any = true
	section.visible = any
