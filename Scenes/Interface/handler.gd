class_name Handler
extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var t := Timer.new()
	t.wait_time = 0.25
	t.timeout.connect(_refresh)
	add_child(t)
	t.start()
	_refresh()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _build():
	pass

func _refresh():
	pass
