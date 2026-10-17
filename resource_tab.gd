extends InfoTab

const SYMBOLS := {"wood": "W", "stone": "S", "iron": "I", "gold": "G", "food": "F"}

var bars := {}
var drain_row

func build() -> void:
	var card = make_card("Materials")
	for res in ResourceManager.resources:
		bars[res] = card.add_bar(SYMBOLS.get(res, str(res).left(1).to_upper()), str(res).capitalize())
	drain_row = card.add_stat("Food use")

func refresh() -> void:
	for res in bars:
		bars[res].set_values(ResourceManager.resources[res], _capacity(res), "fill")
	drain_row.set_value("-%d every 10s" % GameManager.population)

# TODO: point this at wherever ResourceManager keeps the storage limits
func _capacity(res) -> int:
	return ResourceManager.capacities[res]
