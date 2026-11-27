extends Node3D

@export var grass_scene: PackedScene 
@export var cliff_scene: PackedScene
@export var map_width := 12
@export var map_height := 8
@export var cliff_angle_offset := 0.0   # degrees, tweak until cliffs face outward

const SIZE := 1.0           # hex radius (center to corner), match your tile
const LEVEL_HEIGHT := 0.5   # height of one level, match your cliff piece
const TOP_OFFSET := 0.0     # how far the tile's top surface is above its origin
const MAX_LEVEL := 2
const MAP_PATH := "res://maps/map.json"
const DIRS = [Vector2i(1,0), Vector2i(1,-1), Vector2i(0,-1),
			  Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,1)]

var cells := {}   # Vector2i -> HexCell
var nodes := {}   # Vector2i -> Node3D spawned for that hex


func _ready():
	if FileAccess.file_exists(MAP_PATH):
		load_map()
	else:
		generate_cells()
		smooth_heights()
		save_map()
	build_map()


# ---------- DATA ----------

func generate_cells():
	cells.clear()
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.2

	var entries := []
	for col in map_width:
		for row in map_height:
			var coord = Vector2i(col, row - floori(col / 2.0))
			entries.append([coord, noise.get_noise_2d(col, row)])
	entries.sort_custom(func(a, b): return a[1] < b[1])

	var low_share := 0.2
	var mid_share := 0.6
	for i in entries.size():
		var cell = HexCell.new()
		var t = float(i) / entries.size()
		if t < low_share:
			cell.height = 0
		elif t < low_share + mid_share:
			cell.height = 1
		else:
			cell.height = 2
		cells[entries[i][0]] = cell


# returns the hexes it changed
func smooth_heights() -> Array:
	var changed_cells := {}
	var changed := true
	while changed:
		changed = false
		for coord in cells:
			var cell = cells[coord]
			for d in DIRS:
				var n = coord + d
				if cells.has(n) and cell.height - cells[n].height > 1:
					cell.height = cells[n].height + 1
					changed_cells[coord] = true
					changed = true
	return changed_cells.keys()


func save_map():
	var data := {}
	for coord in cells:
		var c: HexCell = cells[coord]
		data["%d,%d" % [coord.x, coord.y]] = {"height": c.height, "terrain": String(c.terrain)}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://maps"))
	var f = FileAccess.open(MAP_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	print("Map saved")


func load_map():
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(MAP_PATH))
	cells.clear()
	for key in parsed:
		var p = key.split(",")
		var cell = HexCell.new()
		cell.height = int(parsed[key]["height"])
		cell.terrain = StringName(parsed[key]["terrain"])
		cells[Vector2i(int(p[0]), int(p[1]))] = cell


# ---------- BUILDER ----------

func build_map():
	for n in nodes.values():
		n.queue_free()
	nodes.clear()
	for coord in cells:
		build_cell(coord)


func build_cell(coord: Vector2i):
	if nodes.has(coord):
		nodes[coord].queue_free()
	var cell: HexCell = cells[coord]

	var root = Node3D.new()
	add_child(root)
	root.position = hex_to_world(coord, cell.height)
	nodes[coord] = root

	root.add_child(grass_scene.instantiate())

	for d in DIRS:
		var n = coord + d
		if cells.has(n) and cells[n].height < cell.height:
			var cliff = cliff_scene.instantiate()
			root.add_child(cliff)
			var dir = hex_to_world(n, 0) - hex_to_world(coord, 0)
			cliff.rotation.y = atan2(dir.x, dir.z) + deg_to_rad(cliff_angle_offset)


func hex_to_world(coord: Vector2i, level: int) -> Vector3:
	var x = SIZE * 1.5 * coord.x
	var z = SIZE * sqrt(3.0) * (coord.y + coord.x / 2.0)
	return Vector3(x, level * LEVEL_HEIGHT, z)


# ---------- EDITING ----------

func edit_height(coord: Vector2i, delta: int):
	cells[coord].height = clampi(cells[coord].height + delta, 0, MAX_LEVEL)

	var dirty := {coord: true}
	for c in smooth_heights():
		dirty[c] = true

	# cliffs depend on neighbors, so rebuild neighbors too
	var rebuild := {}
	for c in dirty:
		rebuild[c] = true
		for d in DIRS:
			if cells.has(c + d):
				rebuild[c + d] = true
	for c in rebuild:
		build_cell(c)


func world_to_hex(p: Vector3) -> Vector2i:
	var q = p.x / (1.5 * SIZE)
	var r = p.z / (sqrt(3.0) * SIZE) - q / 2.0
	var s = -q - r
	var rq = round(q)
	var rr = round(r)
	var rs = round(s)
	var dq = abs(rq - q)
	var dr = abs(rr - r)
	var ds = abs(rs - s)
	if dq > dr and dq > ds:
		rq = -rr - rs
	elif dr > ds:
		rr = -rq - rs
	return Vector2i(int(rq), int(rr))


# find which hex is under the mouse, checking the highest level first
func pick_hex(mouse_pos: Vector2):
	var cam = get_viewport().get_camera_3d()
	var from = cam.project_ray_origin(mouse_pos)
	var dir = cam.project_ray_normal(mouse_pos)
	for level in range(MAX_LEVEL, -1, -1):
		var plane = Plane(Vector3.UP, level * LEVEL_HEIGHT + TOP_OFFSET)
		var hit = plane.intersects_ray(from, dir)
		if hit == null:
			continue
		var coord = world_to_hex(hit)
		if cells.has(coord) and cells[coord].height == level:
			return coord
	return null


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var coord = pick_hex(event.position)
		if coord == null:
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			edit_height(coord, 1)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			edit_height(coord, -1)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_K:      # save
			save_map()
		elif event.keycode == KEY_G:    # new random map (press K to keep it)
			generate_cells()
			smooth_heights()
			build_map()
