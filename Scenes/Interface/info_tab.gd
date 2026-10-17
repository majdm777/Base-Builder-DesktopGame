class_name InfoTab
extends ScrollContainer

const CARD := preload("res://Scenes/Interface/section_card.tscn")

@onready var content : VBoxContainer = $Margin/VBox

func _ready() -> void:
	build()
	refresh()
	var t := Timer.new()
	t.wait_time = 0.25
	t.timeout.connect(func():
		if is_visible_in_tree():
			refresh())
	add_child(t)
	t.start()

func make_card(title: String) -> Node:
	var c = CARD.instantiate()
	content.add_child(c)
	c.set_title(title)
	return c

func build() -> void: pass
func refresh() -> void: pass
