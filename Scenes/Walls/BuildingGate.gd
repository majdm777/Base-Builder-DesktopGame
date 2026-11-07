class_name BuildingGate
extends BuildingObject

const GATE_CARD = preload("res://Scenes/Interface/gate_card.tscn")
var gate_card

var is_open : bool = false

var aabb # for the navchunk
var animation_player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	animation_player = $Building/Gate/AnimationPlayer
	aabb = BuilderManager._building_world_aabb(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func _open_gate():
	if is_open:
		return
	animation_player.play("open_gate")
	await animation_player.animation_finished

	aabb = BuilderManager._building_world_aabb(self)
	BuilderManager._handle_navchunk(aabb)
	is_open = true

func _close_gate():
	if not is_open:
		return
	animation_player.play("close_gate")
	await animation_player.animation_finished

	aabb = BuilderManager._building_world_aabb(self)
	BuilderManager._handle_navchunk(aabb)
	is_open = false

func build_info(container: Control) -> void:
	super(container)
	gate_card = GATE_CARD.instantiate()
	container.add_child(gate_card)
	gate_card.setup(self)
	pass
 
func update_info() -> void:
	super()
	if is_instance_valid(gate_card):
		gate_card.update()
	
