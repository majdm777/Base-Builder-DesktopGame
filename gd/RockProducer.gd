extends ResourceProducer



func on_harvest() -> void:
	var small_rocks = $SmallRocks.get_children()
	
	if small_rocks.size() > 0:
		small_rocks[0].queue_free()
