extends PanelContainer


@onready var Value := $VBox/HBox/Value

var House : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(house : Node):
	House = house
	update()
	pass

func update():
	if not is_instance_valid(House):
		return
	Value.text = str(House.remaining_space) + " / " + str(House.IncreaseCapAmount)
