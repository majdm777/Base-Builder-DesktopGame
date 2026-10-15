extends HBoxContainer

func set_data(symbol: String, value: String) -> void:
	$Symbol.text = symbol + " : "
	$Value.text = value
