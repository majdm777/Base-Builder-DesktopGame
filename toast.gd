extends PanelContainer

signal closed(id: int)

# index = Notifications.Severity: INFO, SUGGESTION, WARNING, DANGER
const COLORS := [Color("263F55"),Color("3F4529"), Color("a76f00ff"), Color("610d01ff")]

var msg_id := -1
var _duration := 5.0
var _tween : Tween
var _closing := false


func setup(msg: Dictionary, duration: float) -> void:
	msg_id = msg.id
	_duration = duration
	$VBox/Stripe.color = COLORS[msg.severity]
	$VBox/Text.text = _label(msg)
	_ignore_mouse(self)          # a toast must never block placement or selection clicks
	modulate.a = 0.0
	_run()


# a repeat of the same message: update the count and restart the timer
func refresh(msg: Dictionary) -> void:
	$VBox/Text.text = _label(msg)
	_run()


func close() -> void:
	if _closing:
		return
	_closing = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.25)
	_tween.tween_callback(func():
		closed.emit(msg_id)
		queue_free())


func _run() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.25)   # fade in
	_tween.tween_interval(_duration)                       # stay
	_tween.tween_callback(close)


func _label(msg: Dictionary) -> String:
	return msg.text + ("  x%d" % msg.count if msg.count > 1 else "")


func _ignore_mouse(n: Node) -> void:
	if n is Control:
		n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_ignore_mouse(c)
