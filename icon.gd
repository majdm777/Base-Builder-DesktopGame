extends TextureRect

const ICON_SIZE := 32

@export var icon_sheet: Texture2D

# Each icon has its own coordinates in the sheet.
var icons = {
	"Sunrise": Vector2i(7, 21),
	"Sunset": Vector2i(9, 21),
	"Sun": Vector2i(8, 21),
	"Moon": Vector2i(10, 21)
}

func set_icon(icon_name: String) -> void:
	if not icons.has(icon_name):
		return

	var position: Vector2i = icons[icon_name]

	var atlas := AtlasTexture.new()
	atlas.atlas = icon_sheet
	atlas.region = Rect2(
		position.x * ICON_SIZE,
		position.y * ICON_SIZE,
		ICON_SIZE,
		ICON_SIZE
	)

	texture = atlas
