
extends Handler

@onready var previous_happiness_value = GameManager.Happiness

@onready var pop_bar = $MarginContainer/VBox/PopulationBar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	var happiness_timer := Timer.new()
	happiness_timer.one_shot = false
	happiness_timer.timeout.connect(_on_happiness_timerout)
	happiness_timer.wait_time = 10.0
	happiness_timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_happiness_timerout():
	var current_happiness_value = GameManager.Happiness
	
	if previous_happiness_value > current_happiness_value:
		$MarginContainer/VBox/HappinessDetails/T_Happiness/Increase.visible = false
		$MarginContainer/VBox/HappinessDetails/T_Happiness/Dercrease.visible = true
	else:
		$MarginContainer/VBox/HappinessDetails/T_Happiness/Increase.visible = true
		$MarginContainer/VBox/HappinessDetails/T_Happiness/Dercrease.visible = false
		
func _refresh():
	var soldiers := 0
	var workers := 0
	for t in GameManager.Soldiers:
		soldiers += GameManager.Soldiers[t]
	var avl : int = GameManager.AvlPopulation
	for w in GameManager.Workers:
		workers += GameManager.Workers[w]
	pop_bar.set_values(workers, soldiers, avl, GameManager.MaxPopulation)
	$"MarginContainer/VBox/Legend/VBox/Worker color/Label".text = "Worker : " + str(workers)
	$"MarginContainer/VBox/Legend/VBox/Army Color/Label".text = "Soldiers : " + str(soldiers)
	$"MarginContainer/VBox/Legend/VBox/Avalaible Color/Label".text = "Available : " + str(GameManager.AvlPopulation)
	$"MarginContainer/VBox/Legend/VBox/Free Space/Label".text = "Free Space : " + str(GameManager.population - GameManager.MaxPopulation)
	
	$MarginContainer/VBox/Population_details/T_population/Tpop.text="T.Population : " + str(GameManager.population) +"/"+ str(GameManager.MaxPopulation)

	_citizen_spawn()
	pass

func _citizen_spawn():
	if !GameManager.citizen_spawn_timer.is_stopped() and GameManager.spawnReady:
		#icons
		$MarginContainer/VBox/Population_details/T_population/Dercrease.visible = false
		$MarginContainer/VBox/Population_details/T_population/Increase.visible = true 
		
		
		$MarginContainer/VBox/Population_details/Pop_time_counter/Label.visible = true
		$MarginContainer/VBox/Population_details/Pop_time_counter/Timer.visible = true
		$MarginContainer/VBox/Population_details/Pop_time_counter/Requirment.visible = false
		$MarginContainer/VBox/Population_details/Pop_time_counter/Timer.text = str(format_time(GameManager.citizen_spawn_timer.time_left))
		return
	if ! GameManager.spawnReady:
		#icons
		$MarginContainer/VBox/Population_details/T_population/Dercrease.visible = true
		$MarginContainer/VBox/Population_details/T_population/Increase.visible = false 
		
		$MarginContainer/VBox/Population_details/Pop_time_counter/Requirment.text = ""
		$MarginContainer/VBox/Population_details/Pop_time_counter/Label.visible = false
		$MarginContainer/VBox/Population_details/Pop_time_counter/Timer.visible = false
		$MarginContainer/VBox/Population_details/Pop_time_counter/Requirment.visible = true
		if GameManager.Happiness < 60:
			$MarginContainer/VBox/Population_details/Pop_time_counter/Requirment.text = "happiness is low."
		if GameManager.population >= GameManager.MaxPopulation:
			$MarginContainer/VBox/Population_details/Pop_time_counter/Requirment.text += "no enough space."
		

func format_time(sec: float) -> String:
	if is_inf(sec):
		return "no "
	if sec <= 0.0:
		return "out "
	return "%dh %02dm" % [int(sec) / 60, int(sec) % 60]

func _happiness_deatail():
	var happiness = GameManager.Happiness
	var status = $MarginContainer/VBox/HappinessDetails/HappinessStatus/Label
	$MarginContainer/VBox/HappinessDetails/T_Happiness/Thap.text = str(GameManager.Happiness)
	var color : Color
	if happiness < 20:
		status.text = "Status : Very Sad"
		color = Color("#a83a2a")
	elif happiness < 40:
		status.text = "Status : Sad"
		color = Color("#a83a2a")
	elif happiness <= 60:
		status.text = "Status : content"
		color = Color("#d19a2e")
	elif happiness < 80:
		status.text = "Status : happy"
		color = Color("#5a8a3a")
	elif happiness < 95:
		status.text = "Status : very happy"
		color = Color("#5a8a3a")
	else:
		status.text = "Status : Thriving"
		color = Color("#5a8a3a")
	status.add_theme_color_override("font_color", color)
	
	#if GameManager.food_availability <= 30:
		#$MarginContainer/VBox/HappinessDetails/HappinessStatus/Requirment.text += ""
	#pass
	
	
	
	
	
	
	
	
	
	
	
	
	
	
