
extends Node

# Add this as an Autoload (Project Settings > Autoload) so it's available globally,
# e.g. as "NavChunks".
#
# Usage when a building is placed or removed:
#   NavChunks.rebake_affected_chunks(building_aabb)
#
# building_aabb should be in world space. It's a good idea to pad it outward a
# bit (e.g. by your unit's agent radius) so the navmesh edge regenerates cleanly
# right up to the building's footprint.

# Must match the values used in chunk_grid_generator.gd
const MAP_MIN := Vector2(-250.07, -254.09)
const CHUNK_SIZE := Vector2(100.0, 100.0)

var navigation_node: Node
var chunks: Dictionary = {}          # Vector2i -> NavigationRegion3D
var _baking: Dictionary = {}         # Vector2i -> bool, chunks currently baking
var _pending: Dictionary = {}        # Vector2i -> bool, another bake was requested mid-bake

func _ready() -> void:
	navigation_node = get_tree().current_scene.find_child("Navigation", true, false)
	if navigation_node == null:
		push_error("NavChunks: no node named 'Navigation' found under the current scene.")
		return
	for child in navigation_node.get_children():
		if child is NavigationRegion3D and child.name.begins_with("chunk_"):
			var parts := child.name.trim_prefix("chunk_").split("_")
			var coord := Vector2i(int(parts[0]), int(parts[1]))
			chunks[coord] = child
			child.bake_finished.connect(_on_chunk_bake_finished.bind(coord))

func _world_to_chunk_coord(world_pos: Vector3) -> Vector2i:
	var col := int(floor((world_pos.x - MAP_MIN.x) / CHUNK_SIZE.x))
	var row := int(floor((world_pos.z - MAP_MIN.y) / CHUNK_SIZE.y))
	return Vector2i(col, row)

func rebake_affected_chunks(building_aabb: AABB) -> void:
	var min_coord := _world_to_chunk_coord(building_aabb.position)
	var max_coord := _world_to_chunk_coord(building_aabb.position + building_aabb.size)

	# Sequential on purpose: a building spanning multiple chunks waits for
	# each chunk's bake in turn rather than firing them all in parallel.
	for col in range(min_coord.x, max_coord.x + 1):
		for row in range(min_coord.y, max_coord.y + 1):
			await _bake_chunk_and_wait(Vector2i(col, row))

func _bake_chunk_and_wait(coord: Vector2i) -> void:
	if not chunks.has(coord):
		return
	var region: NavigationRegion3D = chunks[coord]

	if _baking.get(coord, false):
		# Already baking - mark that another pass is needed once it's done,
		# then wait for that follow-up bake (not the one already in flight,
		# which may not include the geometry change we're here for).
		_pending[coord] = true
		await region.bake_finished
		if _baking.get(coord, false):
			await region.bake_finished
		return

	_baking[coord] = true
	region.bake_navigation_mesh(true)  # async, off the main thread
	await region.bake_finished

func _on_chunk_bake_finished(coord: Vector2i) -> void:
	_baking[coord] = false
	if _pending.get(coord, false):
		_pending[coord] = false
		_baking[coord] = true
		chunks[coord].bake_navigation_mesh(true)
