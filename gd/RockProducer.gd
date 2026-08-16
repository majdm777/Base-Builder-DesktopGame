extends ResourceProducer



func on_harvest() -> void:
	var small_rocks_node = get_node_or_null("SmallRocks")
	if small_rocks_node == null:
		return
	var small_rocks = small_rocks_node.get_children()
	if small_rocks.size() > 0:
		if remaining_resource_amount < ResourceAmount/small_rocks.size():
			small_rocks[0].queue_free()
	return

		
