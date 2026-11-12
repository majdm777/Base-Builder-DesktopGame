extends PanelContainer

const CTAKEN = "#719B55"
const CEMPTY= "#493A2B"

@onready var State := $VBoxContainer/Header/State
@onready var Name := $VBoxContainer/PostType/VBox/Name
@onready var Availability := $VBoxContainer/PostType/VBox/Availability
@onready var OccupancyValue := $VBoxContainer/HBox/Value

@onready var Occupancy := $VBoxContainer/Occupancy

@onready var IncomingValue := $VBoxContainer/HBox2/value





var Post : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(post:Node):
	Post = post 
	Name.text = Post.name
	update()
	pass

func update():
	if not is_instance_valid(Post):
		return
	OccupancyValue.text = str(Post.occupants.size()) + "/" + str(Post.capacity)
	IncomingValue.text = str(Post.incoming)
	
	for i in Occupancy.get_children():
		i.queue_free()
		
	for i in Post.occupants.size():
		var cr = get_ColorRect(true)
		Occupancy.add_child(cr)
		pass
	for y in (Post.capacity - Post.occupants.size()):
		var cr = get_ColorRect(false)
		Occupancy.add_child(cr)
		pass
	
	pass








func get_ColorRect(taken : bool) -> ColorRect:
	var cr = ColorRect.new()
	if taken:
		cr.color =CTAKEN
	else:
		cr.color = CEMPTY
	cr.custom_minimum_size.y = 6
	cr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return cr


func _on_active_button_down() -> void:
	if not is_instance_valid(Post):
		return
	if Post.Active:
		Post.Active = false
		State.text = "Inactive"
		State.theme_type_variation = "Inactive"
		$VBoxContainer/HBoxContainer/Active.text = "Activate"
		$VBoxContainer/HBoxContainer/Active.theme_type_variation = "ButtonActive"
	else:
		Post.Active = true
		State.text = "Active"
		State.theme_type_variation = "Active"
		$VBoxContainer/HBoxContainer/Active.text = "Deactivate"
		$VBoxContainer/HBoxContainer/Active.theme_type_variation = "ButtonDeactive"
	pass # Replace with function body.


func _on_available_button_down() -> void:
	
	if not is_instance_valid(Post):
		return
	if Post.Available:
		Post.Available = false
		Availability.text = "Available for assignment"
		$VBoxContainer/HBoxContainer/Available.text = "Unavailable"
		$VBoxContainer/HBoxContainer/Available.theme_type_variation = "ButtonDeactive"
	else:
		Post.Available = true
		Availability.text = "Unavailable for assignment"
		$VBoxContainer/HBoxContainer/Available.text = "Available"
		$VBoxContainer/HBoxContainer/Available.theme_type_variation = "ButtonActive"
	pass # Replace with function body.


func _on_deploy_button_down() -> void:
	if not is_instance_valid(Post):
		return
	Post._deploy()
