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
	OccupancyValue.text = str(Post.occupants.size) + "/" + str(Post.capacity)
	IncomingValue.text = str(Post.incoming)
	
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
		State.Text = "Inactive"
		State.theme_type_variation = "Inactive"
		$VBoxContainer/HBoxContainer/Active.text = "Activate"
		$VBoxContainer/HBoxContainer/Active.theme_type_variation = "ButtonDeactive"
	else:
		Post.Active = true
		State.Text = "Active"
		State.theme_type_variation = "Active"
		$VBoxContainer/HBoxContainer/Active.text = "Deactivate"
		$VBoxContainer/HBoxContainer/Active.theme_type_variation = "ButtonActivate"
	pass # Replace with function body.



func _on_available_button_down() -> void:
	
	if not is_instance_valid(Post):
		return
	if Post.Available:
		Post.Available = false
		Availability.Text = "Unavailable for assignment"
	else:
		Post.Available = true
		Availability.Text = "Available for assignment"
	pass # Replace with function body.


func _on_deploy_button_down() -> void:
	if not is_instance_valid(Post):
		return
	Post._deploy()
