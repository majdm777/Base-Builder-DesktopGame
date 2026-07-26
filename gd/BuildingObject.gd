extends StaticBody3D

var object : Array 
var ActiveBuildableObject : bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area.area_entered.connect(_on_area_area_entered)
	$Area.area_exited.connect(_on_area_area_exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_area_entered(area: Area3D) -> void:
	if(ActiveBuildableObject):
		BuilderManager.AbleToBuild = false
		object.append(area)
	pass # Replace with function body.


func _on_area_area_exited(area: Area3D) -> void:
	if(ActiveBuildableObject):
		object.remove_at(object.find(area))
		if object.size() <= 0:
			BuilderManager.AbleToBuild = true
	pass # Replace with function body.
