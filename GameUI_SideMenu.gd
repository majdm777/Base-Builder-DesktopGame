extends Control

@export_range(0.0, 1.0) var open_width_ratio := 0.2
@export var anim_time := 0.25

func get_open_width() -> float:
	return get_viewport_rect().size.x * open_width_ratio

var is_open := false
var tween : Tween

var show :Texture2D=ResourceLoader.load("res://Assets/Icon/IconGodotNode/white/icon_visibility.png")
var hide : Texture2D=ResourceLoader.load("res://Assets/Icon/IconGodotNode/white/icon_visibility_off.png")

func _ready() -> void:
	# closed: pushed one full width off the right edge
	offset_left = 0.0
	offset_right = get_open_width()
	
	$Handle.icon = show

	$Handle.pressed.connect(toggle)

func toggle() -> void:
	is_open = not is_open
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "offset_left", -get_open_width() if is_open else 0.0, anim_time)
	tween.tween_property(self, "offset_right", 0.0 if is_open else get_open_width(), anim_time)
	#$Handle.text = ">" if is_open else "<"
	$Handle.icon = hide if is_open else show

func open() -> void:
	if not is_open:
		toggle()

func close() -> void:
	if is_open:
		toggle()
