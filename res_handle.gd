extends Handler


const GOOD := Color("#5a8a3a")
const WARN := Color("#d19a2e")
const BAD := Color("#a83a2a")

const PANELS := {
	"wood": ["WoodPanel", "Wood", "fill"],
	"stone": ["StonePanel", "Stone", "fill"],
	"iron": ["IronPanel", "Iron", "fill"],
	"food": ["FoodPanel", "Food", "drain"],
	"gold": ["GoldPanel", "Gold", "fill"],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass

func _refresh() -> void:
	if not is_visible_in_tree():
		return
	for res in PANELS:
		var info : Array = PANELS[res]
		var box : Node = $Margin/VBox.get_node(info[0] + "/VBox")
		var value : int = ResourceManager.resources[res]
		var cap : int = ResourceManager.capacities[res]
		_fill_label(box.get_node("Label"), info[1], value, cap)
		_fill_Bar(box.get_node("ProgressBar"), value, cap, info[2])
	var food_lasts = food_seconds_left()
	$Margin/VBox/food_consumption/VBox/FoodLasts.text = "food lasts :" + format_time(food_lasts)
	
	$Margin/VBox/WorkerCount/VBoxContainer/Title.text = "Total Workers "+str(GameManager.Workers.values().reduce(func(a, b): return a + b, 0))
	_fill_workers($Margin/VBox/WorkerCount/VBoxContainer/Wood_cutter , "Wood Cutter", GameManager.Workers["Wood Cutter"])
	_fill_workers($Margin/VBox/WorkerCount/VBoxContainer/Farmer , "Farmer", GameManager.Workers["Farmer"])
	_fill_workers($Margin/VBox/WorkerCount/VBoxContainer/Stone_miner , "Stone Miner", GameManager.Workers["Stone Miner"])
	_fill_workers($Margin/VBox/WorkerCount/VBoxContainer/Iron_miner , "Iron Miner", GameManager.Workers["Iron Miner"])
	pass

func _fill_label(label : Label ,Name  : String , Value : int , Max_Value : int ):
	label.text = Name + " : " + str(Value) + "/" + str(Max_Value)

func _fill_Bar(Bar : ProgressBar, Value : int, Max_Value : int, mode := "fill"):
	Bar.max_value = Max_Value
	Bar.value = Value

	var r : float = float(Value) / max(Max_Value, 1)
	var state := 0
	if mode == "fill":
		state = 2 if r >= 0.95 else (1 if r >= 0.75 else 0)
	else:
		state = 2 if r <= 0.25 else (1 if r <= 0.5 else 0)

	if Bar.get_meta("state", -1) != state:    # per bar, not shared
		Bar.set_meta("state", state)
		var fill := StyleBoxFlat.new()
		fill.bg_color = [GOOD, WARN, BAD][state]
		fill.set_corner_radius_all(2)
		Bar.add_theme_stylebox_override("fill", fill)


func food_seconds_left() -> float:
	var pop : int = GameManager.population
	if pop <= 0:
		return INF                                   # nobody eats
	var food : int = ResourceManager.resources["food"]
	if food <= 0:
		return 0.0
	var ticks := ceili(float(food) / pop)
	return GameManager.food_consumption_timer.time_left + (ticks - 1) * 10.0
	
func format_time(sec: float) -> String:
	if is_inf(sec):
		return "no consumption"
	if sec <= 0.0:
		return "out of food"
	return "%dh %02dm" % [int(sec) / 60, int(sec) % 60]


func _fill_workers(label : Label,Name : String , Value : int):
	label.text = Name + " : " + str(Value)
	pass
	
