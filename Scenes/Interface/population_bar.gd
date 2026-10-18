extends ProgressBar

# fallbacks, used only if the theme does not define the item
const DEFAULTS := {
	"Workers": Color("#c28a3a"),
	"Army": Color("#a83a2a"),
	"Available": Color("#5a8a3a"),
	"Empty": Color("#2b2b2b"),
	"Border": Color("#8a6a3f"),
}

var workers := 0
var army := 0
var available := 0
var max_pop := 1


func _color(item: String) -> Color:
	if has_theme_color(item, "PopulationBar"):
		return get_theme_color(item, "PopulationBar")
	return DEFAULTS[item]


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()                   # repaint when the theme changes


func set_values(w: int, a: int, v: int, m: int) -> void:
	if w == workers and a == army and v == available and m == max_pop:
		return
	workers = w
	army = a
	available = v
	max_pop = m
	queue_redraw()


func _draw() -> void:
	var full := Rect2(Vector2.ZERO, size)
	draw_rect(full, _color("Empty"))

	var total : float = max(max_pop, workers + army + available)
	if total <= 0.0:
		draw_rect(full, _color("Border"), false, 2.0)
		return

	var x := 0.0
	for seg in [[workers, "Workers"], [army, "Army"], [available, "Available"]]:
		var w : float = size.x * float(seg[0]) / total
		if w > 0.0:
			draw_rect(Rect2(x, 0, w, size.y), _color(seg[1]))
		x += w

	draw_rect(full, _color("Border"), false, 2.0)
