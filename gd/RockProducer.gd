extends ResourceProducer



func on_harvest() -> void:
	var small_rocks_node = get_node_or_null("SmallRocks")
	if small_rocks_node == null:
		var mesh = get_parent().get_node_or_null("wheelbarrow")
		if mesh != null:
			var animation_player = mesh.get_node("AnimationPlayer")
			animation_player.play("mining")
			await get_tree().create_timer(2.0).timeout 
			mesh.get_node("stone_chunks").visible = true
			animation_player.play("mining_2")
			await get_tree().create_timer(2.2).timeout
			mesh.get_node("stone_chunks").visible = false 
			print(remaining_resource_amount)
		return
	var small_rocks = small_rocks_node.get_children()
	if small_rocks.size() > 0:
		if remaining_resource_amount < amount/small_rocks.size():
			small_rocks[0].queue_free()
	return
