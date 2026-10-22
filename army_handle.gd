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
	DefenseDetails()
	pass
	
	
func SummaryDetails():
	$MarginContainer/VBoxContainer/Summary/VBox/remaining.text = "Next round in : " + WorldTime._get_time_remaining(0.0)
	$MarginContainer/VBoxContainer/Summary/VBox/Round.text = "Round : " + str(AttackManager.round_number)
	


func DefenseDetails():
	var post_container = $MarginContainer/VBoxContainer/DefenseDetail/panelContainer/VBox/Posts
	var defense_container = $MarginContainer/VBoxContainer/DefenseDetail/panelContainer/VBox/Defenses

	var posts = get_tree().get_nodes_in_group("Post")
	var defenses = get_tree().get_nodes_in_group("Defenses")

	$MarginContainer/VBoxContainer/DefenseDetail/panelContainer/VBox/TotalBuilding.text = "Total Buildings :" + str(posts.size() + defenses.size())

	post_container.visible = not posts.is_empty()
	defense_container.visible = not defenses.is_empty()

	if post_container.visible:
		post_container.title = "Posts:" + str(posts.size())

	if defense_container.visible:
		defense_container.title = "Defenses:" + str(defenses.size())

	_update_building_details(posts, post_container.get_node("VBox"))
	_update_building_details(defenses, defense_container.get_node("VBox"))

func _update_building_details(buildings: Array, container: Node) -> void:
	var Label_card: PackedScene = preload("res://Scenes/Interface/Label_card.tscn")

	for child in container.get_children():
		child.queue_free()

	for building in buildings:
		if is_instance_valid(building) and building.spawned:
			var label = Label_card.instantiate()
			label.get_node("Symbol").text = building.name + ":"
			label.get_node("Value").text = str(building.occupants.size()) + "|" + str(building.capacity)
			container.add_child(label)
