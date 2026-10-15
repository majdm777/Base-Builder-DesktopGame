extends PanelContainer

const CHIP := preload("res://Scenes/InterFace/stat_chip.tscn")    # adjust the path
const SYMBOLS := {"wood": "W", "stone": "S", "iron": "I", "gold": "G", "food": "F"}

@onready var buttons_box : VBoxContainer = $VBoxContainer/Buttons
@onready var queue_box : VBoxContainer = $VBoxContainer/Queue
@onready var queue_title : Label = $VBoxContainer/QueueTitle

var barracks : Node          # typed as Node on purpose, see the note below
var train_buttons : Array = []   # [{ "type": ..., "button": Button }]
var front_bar : ProgressBar = null


func setup(b: Node) -> void:
	barracks = b
	_build_buttons()
	barracks.queue_changed.connect(_rebuild_queue)
	_rebuild_queue()
	update()


# ---------------- Train buttons, built from the barracks' own table ----------------

func _build_buttons() -> void:
	for type in barracks.trainable:
		var d : Dictionary = barracks.trainable[type]

		var row := HBoxContainer.new()
		var name_label := Label.new()
		name_label.theme_type_variation = "CardLabel"
		name_label.text = d.name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		# cost chips: P = population, the rest come from the costs table
		_add_chip(row, "P", d.pop_cost)
		for res in d.costs:
			_add_chip(row, SYMBOLS.get(res, res.left(1).to_upper()), d.costs[res])

		for amount in [1, 5]:
			var b := Button.new()
			b.text = "+%d" % amount
			b.pressed.connect(_train.bind(type, amount))
			row.add_child(b)
			train_buttons.append({"type": type, "button": b})

		buttons_box.add_child(row)


func _add_chip(row: Control, symbol: String, value: int) -> void:
	if value <= 0:
		return
	var chip = CHIP.instantiate()
	row.add_child(chip)
	chip.set_data(symbol, str(value))


func _train(type, amount: int) -> void:
	for i in amount:
		if not barracks.train(type):
			break              # out of pop or resources, stop early
	update()


# ---------------- Queue list ----------------

func _rebuild_queue() -> void:
	for c in queue_box.get_children():
		c.queue_free()
	front_bar = null
	queue_title.visible = not barracks.queue.is_empty()

	for i in barracks.queue.size():
		var idx : int = i                         # each cancel button needs its own copy of i
		var type = barracks.queue[i]
		var d : Dictionary = barracks.trainable[type]

		var row := HBoxContainer.new()
		var label := Label.new()
		label.text = d.name
		label.custom_minimum_size.x = 70
		label.theme_type_variation = "CardLabel"
		row.add_child(label)

		if i == 0:
			var bar := ProgressBar.new()
			bar.max_value = d.train_time
			bar.show_percentage = false
			bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(bar)
			front_bar = bar
		else:
			var waiting := Label.new()
			waiting.text = "waiting"
			waiting.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(waiting)

		var cancel := Button.new()
		cancel.text = "X"
		cancel.pressed.connect(func(): barracks.cancel(idx))
		row.add_child(cancel)

		queue_box.add_child(row)


# ---------------- Refresh ----------------

# called from the panel's 0.25 s tick: enables or disables the train buttons
func update() -> void:
	if not is_instance_valid(barracks):
		return
	for e in train_buttons:
		e.button.disabled = not barracks.can_train(e.type)


# the progress bar runs every frame so it fills smoothly
func _process(_delta: float) -> void:
	if front_bar and is_instance_valid(front_bar) and is_instance_valid(barracks):
		front_bar.value = barracks.progress
