extends Node

signal message_added(msg: Dictionary)
signal message_changed(msg: Dictionary)     # repeat count went up, or it was resolved
signal message_removed(msg: Dictionary)
signal unread_changed(count: int)

enum Severity { INFO, SUGGESTION, WARNING, DANGER }

const MAX_MESSAGES := 50
const COOLDOWN_MS := 60000          # a key can't come back for 60 s after it is resolved or dismissed

var messages : Array = []           # newest first
var suggestions_enabled := true     # a settings toggle can flip this later
var _next_id := 0
var _blocked_until : Dictionary = {}   # key -> time in ms when it may be pushed again


func push(severity: int, text: String, key: String = "", target: Node = null) -> void:
	if severity == Severity.SUGGESTION and not suggestions_enabled:
		return

	if key != "":
		var active = _find_active(key)
		if active:
			return                                  # already showing, don't spam
		if Time.get_ticks_msec() < _blocked_until.get(key, 0):
			return                                  # still cooling down

	# identical keyless messages in a row become "x2", "x3"
	if key == "" and not messages.is_empty():
		var top : Dictionary = messages[0]
		if top.text == text and not top.resolved:
			top.count += 1
			message_changed.emit(top)
			return

	var msg := {
		"id": _next_id,
		"severity": severity,
		"text": text,
		"key": key,
		"time": WorldTime.get_time_string() +","+ WorldTime.get_date_string(),
		"target": target,
		"read": false,
		"resolved": false,
		"count": 1,
	}
	_next_id += 1
	messages.push_front(msg)
	_trim()
	message_added.emit(msg)
	unread_changed.emit(unread_count())


# the condition is over (food recovered, etc.)
func resolve(key: String) -> void:
	var msg = _find_active(key)
	if msg == null:
		return
	msg.resolved = true
	msg.read = true
	_blocked_until[key] = Time.get_ticks_msec() + COOLDOWN_MS
	message_changed.emit(msg)
	unread_changed.emit(unread_count())


func dismiss(id: int) -> void:
	for m in messages:
		if m.id == id:
			messages.erase(m)
			if m.key != "":
				_blocked_until[m.key] = Time.get_ticks_msec() + COOLDOWN_MS
			message_removed.emit(m)
			unread_changed.emit(unread_count())
			return


func mark_all_read() -> void:
	for m in messages:
		m.read = true
	unread_changed.emit(0)


func unread_count() -> int:
	var n := 0
	for m in messages:
		if not m.read:
			n += 1
	return n


func _find_active(key: String):
	for m in messages:
		if m.key == key and not m.resolved:
			return m
	return null


func _trim() -> void:
	while messages.size() > MAX_MESSAGES:
		# drop the oldest INFO first, otherwise the oldest message
		var victim = messages.back()
		for i in range(messages.size() - 1, -1, -1):
			if messages[i].severity == Severity.INFO:
				victim = messages[i]
				break
		messages.erase(victim)
		message_removed.emit(victim)


func _ready() -> void:
	message_added.connect(func(m): print("[+] ", Severity.keys()[m.severity], ": ", m.text, "  (", m.time, ")"))
	message_changed.connect(func(m): print("[~] ", m.text, " x", m.count, " resolved=", m.resolved))
	message_removed.connect(func(m): print("[-] ", m.text))


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_F1: push(Severity.INFO, "Training finished")
		KEY_F2: push(Severity.SUGGESTION, "Build a house to grow", "no_house")
		KEY_F3: push(Severity.WARNING, "Food is running low", "food_low")
		KEY_F4: push(Severity.DANGER, "The castle is under attack", "castle_attack")
		KEY_F5: resolve("food_low")
		KEY_F6: dismiss(messages[0].id) if not messages.is_empty() else null
		KEY_F7: push(Severity.WARNING, "Storage is full")
