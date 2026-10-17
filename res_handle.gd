extends ScrollContainer


const GOOD := Color("#5a8a3a")
const WARN := Color("#d19a2e")
const BAD := Color("#a83a2a")

var _state := -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if ! visible:
		return 
	_fill_label($Margin/VBox/WoodPanel/VBox/Label,"Wood" , ResourceManager.resources["wood"],ResourceManager.capacities["wood"])
	_fill_Bar($Margin/VBox/WoodPanel/VBox/ProgressBar, ResourceManager.resources["wood"],ResourceManager.capacities["wood"],"fill")
	
	_fill_label($Margin/VBox/StonePanel/VBox/Label,"Stone" , ResourceManager.resources["stone"],ResourceManager.capacities["stone"])
	_fill_Bar($Margin/VBox/StonePanel/VBox/ProgressBar, ResourceManager.resources["stone"],ResourceManager.capacities["stone"],"fill")
	
	_fill_label($Margin/VBox/IronPanel/VBox/Label,"Iron" , ResourceManager.resources["iron"],ResourceManager.capacities["iron"])
	_fill_Bar($Margin/VBox/IronPanel/VBox/ProgressBar, ResourceManager.resources["iron"],ResourceManager.capacities["iron"],"fill")
	
	_fill_label($Margin/VBox/FoodPanel/VBox/Label,"Food" , ResourceManager.resources["food"],ResourceManager.capacities["food"])
	_fill_Bar($Margin/VBox/FoodPanel/VBox/ProgressBar, ResourceManager.resources["food"],ResourceManager.capacities["food"],"drain")
	
	_fill_label($Margin/VBox/GoldPanel/VBox/Label,"Gold" , ResourceManager.resources["gold"],ResourceManager.capacities["gold"])
	_fill_Bar($Margin/VBox/GoldPanel/VBox/ProgressBar, ResourceManager.resources["gold"],ResourceManager.capacities["gold"],"fill")
	
	var food_lasts = food_seconds_left()
	$Margin/VBox/food_consumtion/VBox/FoodLasts.text = "food lasts :" + format_time(food_lasts)
	
	
	pass


func _fill_label(label : Label ,Name  : String , Value : int , Max_Value : int ):
	label.text = Name + " : " + str(Value) + "/" + str(Max_Value)

func _fill_Bar(Bar : ProgressBar, Value :int , Max_Value : int , mode := "fill"):
	Bar.max_value = Max_Value
	Bar.value = Value

	var r : float = float(Value) / max(Max_Value, 1)

	var state := 0
	if mode == "fill":
		state = 2 if r >= 0.95 else (1 if r >= 0.75 else 0)
	else:
		state = 2 if r <= 0.25 else (1 if r <= 0.5 else 0)
	if state != _state:                       # only touch the style when it changes
		_state = state
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


func _fill_workers(label : Label,Name : String , reference : String):
	pass
	
