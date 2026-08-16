extends BuildingObject

@export var time_mining :int
@export var ResourceAmount :int = 10
@export_enum("Wood", "Stone", "Iron")
var ResourceType: String 
# Called when the node enters the scene tree for the first time.
func _mining():
	var animation :=$CharacterBody3D/AnimationPlayer
	if animation != null:
		animation.play("mining")
		await animation.animation_finished
		
		await get_tree().create_timer(time_mining).timeout

		animation.play_backwards("mining")
		await animation.animation_finished
		await get_tree().create_timer(2).timeout
		match ResourceType:
			"Wood": GameManager.Wood += ResourceAmount
			"Stone": GameManager.Stone += ResourceAmount
			"Iron": GameManager.Iron += ResourceAmount
		print(GameManager.Iron)
	pass
