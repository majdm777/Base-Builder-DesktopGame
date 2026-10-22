extends Handler


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func _refresh():
	SummaryDetails()
	pass
	
	
func SummaryDetails():
	$MarginContainer/VBoxContainer/Summary/VBox/remaining.text = "Next round in : " + WorldTime._get_time_remaining(0.0)
	$MarginContainer/VBoxContainer/Summary/VBox/Round.text = "Round : " + str(AttackManager.round_number)
	
	
	pass
