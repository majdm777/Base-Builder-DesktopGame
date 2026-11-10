extends BuildingPost



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

func _on_round_started():
	pass

func _on_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		print("Majd")
		_deploy()
	pass # Replace with function body.
