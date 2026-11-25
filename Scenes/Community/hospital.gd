extends BuildingObject

@export var max_capacity := 4
@export var healing_time : float = 10.0
@export var healing_value := 10

var patients : Array = []
var waiting_queue : Array = []


func _process(delta: float) -> void:
	super(delta)
	if not spawned:
		return

	patients = patients.filter(func(p): return is_instance_valid(p))
	waiting_queue = waiting_queue.filter(func(p): return is_instance_valid(p))

	while patients.size() < max_capacity and not waiting_queue.is_empty():
		var p = waiting_queue.pop_front()
		patients.append(p)
		p.visible = false                  # hidden while being treated
		_healing(p)                        # starts once, here
	if not patients.is_empty():
		$MainBuilding/light.visible = true
		$MainBuilding/light2.visible = true
		$MainBuilding/AnimationPlayer.play("active")
	else:
		$MainBuilding/light.visible = false
		$MainBuilding/light2.visible = false
		$MainBuilding/AnimationPlayer.stop()

func _interact(patient: Node3D) -> void:
	if waiting_queue.has(patient) or patients.has(patient):
		return
	waiting_queue.append(patient)


func _healing(patient: Node3D) -> void:
	while is_instance_valid(patient) and patients.has(patient):
		await get_tree().create_timer(healing_time).timeout
		if not is_inside_tree() or not is_instance_valid(patient) or not patients.has(patient):
			return
		patient.Health = min(patient.Health + healing_value, patient.MaxHealth)
		if patient.Health >= patient.MaxHealth:
			_exit(patient)
			return


func _exit(patient: Node3D) -> void:
	patients.erase(patient)
	if not is_instance_valid(patient):
		return
	patient.visible = true
	patient.current_state = patient.State.Idle


func _freeall() -> void:
	for p in patients.duplicate():
		_exit(p)
	for p in waiting_queue.duplicate():
		if is_instance_valid(p):
			p.current_state = p.State.Idle
	waiting_queue.clear()


func run_despawn() -> void:
	_freeall()
	super()
