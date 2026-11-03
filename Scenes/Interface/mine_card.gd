extends PanelContainer

var Mine : Node 
const RESOURCE_TYPE := ["Stone" , "Iron"]

@onready var ResourceName := $VBoxContainer/ResourceName
@onready var Remaining := $VBoxContainer/HBox/VBox/Remaining
@onready var Status := $VBoxContainer/Status
@onready var time := $VBoxContainer/Generatinglabel/Timer
@onready var GeneratingLabel := $VBoxContainer/Generatinglabel

@onready var AmountBar := $VBoxContainer/HBox/Bar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(mine : Node):
	Mine = mine
	ResourceName.text = "Resource Name : " + mine.ResourceType
	if is_instance_valid(Mine.SpawnPoint):
		
		AmountBar.max_value = Mine.SpawnPoint.amount
	else :
		AmountBar.max_value = 0
	update()
	pass
	

func update():
	if not is_instance_valid(Mine):
		return
	var percentage: int
	if is_instance_valid(Mine.SpawnPoint):
		percentage = (float(Mine.SpawnPoint.remaining_resource_amount) / Mine.SpawnPoint.amount) * 100.0
		AmountBar.value = Mine.SpawnPoint.remaining_resource_amount
		Status.text= "The Mine is Available"
		GeneratingLabel.visible = false
	else :
		GeneratingLabel.visible = true
		time.text = format_time(Mine.Building.cooldown_timer.time_left)
		
		Status.text = "The Mine is Empty"
		AmountBar.value = 0
		percentage = 0
		
	
	Remaining.text = "%"+str(percentage)+" Remaining"
	
func format_time(sec: float) -> String:
	if is_inf(sec):
		return "no consumption"
	if sec <= 0.0:
		return "out of food"
	return "%dh %02dm" % [int(sec) / 60, int(sec) % 60]
