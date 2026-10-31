extends ScrollContainer

@onready var content : Control = $MarginContainer/Control  # the container sections are added to
@onready var empty_label : Label = $MarginContainer/EmptyLabel   # new: "Nothing selected"
@onready var drawer : Control = $"../.."

var current : Node3D = null
var _timer : Timer


func _ready() -> void:
	BuilderManager.selection_changed.connect(_on_selection_changed)
	_timer = Timer.new()
	_timer.wait_time = 0.25
	_timer.timeout.connect(_on_tick)
	add_child(_timer)
	_timer.start()
	_show_empty()


func _on_selection_changed(node: Node3D) -> void:
	for c in content.get_children():
		c.queue_free()
	current = node
	if node == null or not node.has_method("build_info"):
		_show_empty()
		return
	empty_label.visible = false
	node.build_info(content)
	_show_tab()


func _show_empty() -> void:
	current = null
	empty_label.visible = true


func _show_tab() -> void:
	var tabs := get_parent() as TabContainer
	tabs.current_tab = tabs.get_tab_idx_from_control(self)
	if drawer:
		drawer.open()


func _on_tick() -> void:
	if not is_visible_in_tree() or current == null:
		return
	if not is_instance_valid(current):
		BuilderManager.clear_selection()
		return
	current.update_info()
