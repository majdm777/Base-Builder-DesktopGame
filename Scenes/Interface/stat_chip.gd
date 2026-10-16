extends HBoxContainer

func set_data(symbol: String, value: String) -> void:
	$Symbol.text = symbol + " : "
	$Value.text = value

func set_ok(ok: bool) -> void:
	if ok:
		$Value.remove_theme_color_override("font_color")
	else:
		$Value.add_theme_color_override("font_color", Color("#a83a2a"))
