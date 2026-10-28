extends ScrollContainer

const CARD := preload("res://Scenes/InterFace/notification_card.tscn")   # adjust the path

@onready var list : VBoxContainer = $Margin/VBox/List
@onready var empty_label : Label = $Margin/VBox/EmptyLabel

var cards := {}       # message id -> card


func _ready() -> void:
	Notification.message_added.connect(_on_added)
	Notification.message_changed.connect(_on_changed)
	Notification.message_removed.connect(_on_removed)

	# messages pushed before this tab existed (oldest first, so the newest ends up on top)
	for i in range(Notification.messages.size() - 1, -1, -1):
		_on_added(Notification.messages[i])
	_update_empty()


func _on_added(msg: Dictionary) -> void:
	var card = CARD.instantiate()
	list.add_child(card)
	list.move_child(card, 0)               # newest at the top
	card.setup(msg)
	cards[msg.id] = card
	_update_empty()


func _on_changed(msg: Dictionary) -> void:
	if cards.has(msg.id):
		cards[msg.id].update(msg)


func _on_removed(msg: Dictionary) -> void:
	if cards.has(msg.id):
		cards[msg.id].queue_free()
		cards.erase(msg.id)
	_update_empty()


func _update_empty() -> void:
	empty_label.visible = cards.is_empty()
