extends HBoxContainer

const GOOD := Color("#5a8a3a")
const WARN := Color("#d19a2e")
const BAD := Color("#a83a2a")

var _state := -1

func setup(symbol: String, label: String) -> void:
	$Symbol.text = symbol
	$Name.text = label

# mode "fill":  red when almost full (storage)
# mode "drain": red when almost empty (happiness factors)
func set_values(value: float, max_value: float, mode := "fill") -> void:
	$Bar.max_value = max_value
	$Bar.value = value
	$Bar/Text.text = "%d / %d" % [value, max_value]

	var r : float = value / max(max_value, 1.0)
	var state := 0
	if mode == "fill":
		state = 2 if r >= 0.95 else (1 if r >= 0.75 else 0)
	else:
		state = 2 if r <= 0.25 else (1 if r <= 0.5 else 0)
	if state != _state:                       # only touch the style when it changes
		_state = state
		var fill := StyleBoxFlat.new()
		fill.bg_color = [GOOD, WARN, BAD][state]
		fill.set_corner_radius_all(2)
		$Bar.add_theme_stylebox_override("fill", fill)
