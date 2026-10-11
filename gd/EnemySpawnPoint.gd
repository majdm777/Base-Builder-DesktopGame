class_name EnemySpawnPoint
extends Marker3D

@export var active_from_round : int = 1

func _ready() -> void:
	add_to_group("EnemySpawnPoint")
