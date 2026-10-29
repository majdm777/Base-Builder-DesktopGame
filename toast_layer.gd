extends Control

const TOAST := preload("res://Scenes/InterFace/toast.tscn")    # adjust the path
const MAX_TOASTS := 4

# which severities pop up, and for how long (seconds)
const DURATIONS := {
	Notification.Severity.WARNING: 5.0,
	Notification.Severity.DANGER: 8.0,
	Notification.Severity.SUGGESTION: 5.0,
	Notification.Severity.INFO: 8.0,
}

@onready var box : VBoxContainer = $Box

var toasts := {}     # message id -> toast


func _ready() -> void:
	Notification.message_added.connect(_on_added)
	Notification.message_changed.connect(_on_changed)
	Notification.message_removed.connect(_on_removed)


func _on_added(msg: Dictionary) -> void:
	if not DURATIONS.has(msg.severity):
		return                                   # info and suggestions only go to the tab

	while toasts.size() >= MAX_TOASTS:
		var oldest = box.get_child(0)            # the oldest toast is first in the box
		toasts.erase(oldest.msg_id)
		oldest.close()

	var t = TOAST.instantiate()
	box.add_child(t)
	t.setup(msg, DURATIONS[msg.severity])
	t.closed.connect(func(id): toasts.erase(id))
	toasts[msg.id] = t


func _on_changed(msg: Dictionary) -> void:
	if not toasts.has(msg.id):
		return
	if msg.resolved:
		toasts[msg.id].close()                   # the problem is over, the warning goes away
	else:
		toasts[msg.id].refresh(msg)


func _on_removed(msg: Dictionary) -> void:
	if toasts.has(msg.id):
		toasts[msg.id].close()
