@tool
extends EditorScript

# Run this from the Script Editor (open it, then Editor > Run, or Ctrl+Shift+X)
# while your Map scene is the currently open/active scene.
# It (re)builds the full chunk grid under the "Navigation" node.

# ---- Adjust these to match your map ----
const MAP_MIN := Vector2(-250.07, -254.09)  # measured from the terrain MeshInstance3D's world AABB
const MAP_SIZE := Vector2(500.14, 508.19)   # measured, not the earlier assumed 500/508 round numbers
const CHUNK_SIZE := Vector2(100.0, 100.0)  # desired chunk width/depth (edge chunks may be smaller)
const CHUNK_Y := 0.0                       # world Y position for chunk nodes
const BAKE_Y_MIN := -1.5                   # local Y where the bake volume starts (below terrain's measured bottom, -1.26)
const BAKE_HEIGHT := 12.0                  # local Y extent of the bake volume (raise if trees/buildings are tall)
const NAV_GROUP := "nav_geometry"          # group your obstacle-holding nodes belong to
# -----------------------------------------

func _run() -> void:
	var scene_root := get_scene()
	if scene_root == null:
		push_error("Open your Map scene first, then run this script.")
		return

	var nav_parent: Node = scene_root.find_child("Navigation", true, false)
	if nav_parent == null:
		push_error("No node named 'Navigation' found anywhere under the scene root ('%s'). Check the exact name/casing in your Scene dock." % scene_root.name)
		return
	print("Found Navigation node at: ", nav_parent.get_path())

	# Clear any previously generated chunks so this is safely re-runnable.
	for child in nav_parent.get_children():
		if child.name.begins_with("chunk_"):
			nav_parent.remove_child(child)
			child.queue_free()

	var col := 0
	var x := MAP_MIN.x
	while x < MAP_MIN.x + MAP_SIZE.x - 0.001:
		var w := minf(CHUNK_SIZE.x, MAP_MIN.x + MAP_SIZE.x - x)
		var row := 0
		var z := MAP_MIN.y
		while z < MAP_MIN.y + MAP_SIZE.y - 0.001:
			var d := minf(CHUNK_SIZE.y, MAP_MIN.y + MAP_SIZE.y - z)

			var region := NavigationRegion3D.new()
			region.name = "chunk_%d_%d" % [col, row]
			nav_parent.add_child(region)
			region.owner = scene_root
			region.position = Vector3(x, CHUNK_Y, z)

			var navmesh := NavigationMesh.new()
			navmesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_BOTH
			navmesh.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
			navmesh.geometry_source_group_name = NAV_GROUP
			navmesh.filter_baking_aabb = AABB(Vector3(0.0, BAKE_Y_MIN, 0.0), Vector3(w, BAKE_HEIGHT, d))
			region.navigation_mesh = navmesh

			# Bake now, synchronously, so the resulting navmesh data is saved
			# into the scene along with the chunk. This covers the static
			# terrain/rocks/trees only - buildings placed or restored later
			# get baked incrementally via NavChunks at runtime.
			region.bake_navigation_mesh(false)

			z += d
			row += 1
		x += w
		col += 1

	print("Chunk grid generated and baked: %d columns. Remember to save the scene (Ctrl+S)." % col)
	print("Also make sure your 'Map' node (or whatever parents your rocks/trees/terrain) is added to the '%s' group." % NAV_GROUP)
