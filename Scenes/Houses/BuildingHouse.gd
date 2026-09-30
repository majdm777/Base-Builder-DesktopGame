extends BuildingObject

var remaining_space : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remaining_space = IncreaseCapAmount
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func Occupy() -> Vector3:
	remaining_space -= 1
	return $SpawnPoint.global_position
