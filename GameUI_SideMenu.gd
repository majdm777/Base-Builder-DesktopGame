extends Control

@export var open_width := 200.0
@export var anim_time := 0.25

var is_open := false
var tween : Tween

func _ready() -> void:
	# closed: pushed one full width off the right edge
	offset_left = 0.0
	offset_right = open_width
	$Handle.text = "<"

	$Handle.pressed.connect(toggle)

func toggle() -> void:
	is_open = not is_open
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_left", -open_width if is_open else 0.0, anim_time)
	tween.tween_property(self, "offset_right", 0.0 if is_open else open_width, anim_time)
	$Handle.text = ">" if is_open else "<"
