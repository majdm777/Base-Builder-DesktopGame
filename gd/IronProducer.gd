extends ResourceProducer



func on_harvest() -> void:
	var mesh = get_parent().get_node_or_null("wheelbarrow")
	if mesh != null:
		var animation_player = mesh.get_node("AnimationPlayer")
		animation_player.play("mining")
		await get_tree().create_timer(2.0).timeout 
		mesh.get_node("iron_nugget").visible = true
		animation_player.play("mining_2")
		await get_tree().create_timer(2.2).timeout
		mesh.get_node("iron_nugget").visible = false 
		print(remaining_resource_amount)
	return
