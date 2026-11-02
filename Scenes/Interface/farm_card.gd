extends PanelContainer

@onready var time_to_grow := $VBox/TimeToGrow
@onready var crops_amount := $VBox/CropsAmount
@onready var container := $VBox/Container

const plot_status = ["ready","empty","growing","harvested"]
const plot_status_colors = [
	Color("#D6B45C"), # Ready - Gold
	Color("#A89B88"), # Empty - Muted stone
	Color("#8CCB78"), # Growing - Green
	Color("#D99A58")  # Harvested - Warm orange
]
var plot_state_labels: Dictionary = {}

var House: Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(house : Node):
	House = house
	for plot in House.plots:
		Buildcard(plot)
	pass

func update():
	if not is_instance_valid(House):
		return

	time_to_grow.text = "Time To Grow: " + str(House.time_to_grow) + "mins / each"
	crops_amount.text = "Crops Amount: " + str(House.crops_amount / House.plots.size()) + "F / each"

	for plot in plot_state_labels:
		if not is_instance_valid(plot):
			continue

		var state_label: Label = plot_state_labels[plot]
		state_label.text = plot_status[plot.current_state]
		state_label.add_theme_color_override("font_color",plot_status_colors[plot.current_state])
		

func Buildcard(plot: Node):
	var Hbox = HBoxContainer.new()
	var Name = Label.new()
	var Plot_state = Label.new()

	#Name.theme_type_variation = "CardLabel"
	Name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Name.text = "Plot"

	#Plot_state.theme_type_variation = "CardLabel"
	Plot_state.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	Plot_state.text = plot_status[plot.current_state]
	Plot_state.add_theme_color_override("font_color",plot_status_colors[plot.current_state])
	Hbox.add_child(Name)
	Hbox.add_child(Plot_state)

	container.add_child(Hbox)

	# Connect the plot to its state label
	plot_state_labels[plot] = Plot_state
