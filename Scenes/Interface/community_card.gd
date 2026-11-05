extends PanelContainer

var Community : Node

const CTAKEN = "#719B55"
const CEMPTY= "#493A2B"

@onready var State := $Card/Header/state
@onready var info := $Card/info

@onready var InteractionValue := $Card/HBoxContainer/InteractionValue/Value
@onready var InteractionTime := $Card/HBoxContainer/InteractionTime/Value
@onready var Capacity := $Card/Capacity/Value

@onready var Occupancy = $Card/Occupancy
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(community : Node):
	Community = community
	update()
	pass

func update():
	if not is_instance_valid(Community):
		return
	InteractionTime.text =str(Community.interaction_Value)+"min"
	InteractionValue.text = "+"+str(Community.time_interacting)
	Capacity.text = str(Community.current_occupants) + "/" + str(Community.capacity)
	if Community.current_occupants == 0:
		State.text = "Inactive"
		State.theme_type_variation = "Inactive"
		info.visible = true
	else :
		State.text = "Active"
		State.theme_type_variation = "Active"
		info.visible = false

	for i in Occupancy.get_children():
		i.queue_free()
		
	for i in Community.current_occupants:
		var cr = get_ColorRect(true)
		Occupancy.add_child(cr)
		pass
	for y in (Community.capacity - Community.current_occupants):
		var cr = get_ColorRect(false)
		Occupancy.add_child(cr)
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
