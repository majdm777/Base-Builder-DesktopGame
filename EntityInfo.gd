extends VBoxContainer

@onready var title : Label = $MarginContainer/Control/Title
@onready var rows : VBoxContainer = $MarginContainer/Control/Rows

@onready var drawer : Control = $"../.."

@onready var preview : SubViewportContainer = $MarginContainer/Control/Preview
@onready var pivot : Node3D = $MarginContainer/Control/Preview/Viewport/Pivot
@onready var cam : Camera3D = $MarginContainer/Control/Preview/Viewport/Camera3D

const SPIN_SPEED := 0.6   # radians per second

var value_labels : Array[Label] = []
var _timer : Timer
var current : Node3D = null

func _ready() -> void:
	BuilderManager.selection_changed.connect(_on_selection_changed)
	_timer = Timer.new()
	_timer.wait_time = 0.25
	_timer.timeout.connect(_on_tick)
	add_child(_timer)
	_timer.start()
	_show_empty()

func _on_selection_changed(node: Node3D) -> void:
	current = node
	_refresh()
	_build_preview()
	if node != null:
		_show_tab()

func _refresh() -> void:
	if not is_instance_valid(current):
		_show_empty()
		return
	title.text = current.name
	_clear_rows()
	for r in current.get_info_rows():
		_add_row(r.label, r.value)

func _show_empty() -> void:
	current = null
	title.text = "No building selected"
	_clear_rows()

func _clear_rows() -> void:
	for c in rows.get_children():
		c.queue_free()
	value_labels.clear()

func _add_row(label_text: String, value_text: String) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.text = label_text
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := Label.new()
	value_labels.append(v)
	v.text = value_text
	row.add_child(l)
	row.add_child(v)
	rows.add_child(row)


func _show_tab() -> void:
	var tabs := get_parent() as TabContainer
	tabs.current_tab = tabs.get_tab_idx_from_control(self)
	if drawer:
		drawer.open()

func _on_tick() -> void:
	if not is_visible_in_tree() or current == null:
		return                       # costs nothing while the tab is closed
	if not is_instance_valid(current):
		BuilderManager.clear_selection()   # selected building was destroyed
		return
	var data : Array = current.get_info_rows()
	if data.size() != value_labels.size():
		_refresh()                   # structure changed, rebuild
		return
	for i in data.size():
		value_labels[i].text = data[i].value

func _build_preview() -> void:
	_clear_preview()
	if not is_instance_valid(current):
		return

	var found : Array = []
	_collect_meshes(current, found)
	if found.is_empty():
		preview.visible = false          # nothing to show, hide the box
		return

	# transforms relative to the building root, and the combined bounding box
	var inv := current.global_transform.affine_inverse()
	var bounds := AABB()
	var first := true
	var entries : Array = []
	for m : MeshInstance3D in found:
		var rel : Transform3D = inv * m.global_transform
		var box : AABB = rel * m.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
		entries.append({"mesh": m, "rel": rel})

	# copy each mesh into the preview, centered so it spins in place
	var center := bounds.get_center()
	for e in entries:
		var src : MeshInstance3D = e.mesh
		var copy := MeshInstance3D.new()
		copy.mesh = src.mesh
		copy.material_override = src.material_override
		for s in src.mesh.get_surface_count():
			var mat := src.get_surface_override_material(s)
			if mat:
				copy.set_surface_override_material(s, mat)
		var t : Transform3D = e.rel
		t.origin -= center
		copy.transform = t
		pivot.add_child(copy)

	# frame the camera from the size of the box
	var radius : float = max(bounds.size.length() * 0.5, 0.5)
	var dist : float = radius / tan(deg_to_rad(cam.fov * 0.5)) * 1.15
	cam.look_at_from_position(Vector3(0, radius * 0.5, dist), Vector3.ZERO)
	pivot.rotation = Vector3.ZERO
	preview.visible = true


func _collect_meshes(n: Node, out: Array) -> void:
	for c in n.get_children():
		if c is Area3D:
			continue                      # Area and Range are not visuals
		if c is MeshInstance3D and c.visible and c.mesh != null:
			out.append(c)
		_collect_meshes(c, out)


func _clear_preview() -> void:
	for c in pivot.get_children():
		c.queue_free()
	preview.visible = false


func _process(delta: float) -> void:
	if preview.visible and is_visible_in_tree():
		pivot.rotation.y += SPIN_SPEED * delta
