extends Handler

@onready var day_time := $VBox/HBox/VBox/Time
@onready var day_date := $VBox/HBox/VBox/Date
@onready var year := $VBox/HBox/VBox2/Year
@onready var day_status :=$VBox/HBox/VBox2/status

const MONTH_NAMES : Array[String] = [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	day_time.text = WorldTime.get_time_string()
	
	day_date.text = "Day " + str(WorldTime.day) + " · " + MONTH_NAMES[WorldTime.month - 1]
	year.text = "year " + str(WorldTime.year)
	
	set_status()
	pass

func _refresh():
	_set_icon()
	pass

func set_status():
	if WorldTime._get_worldtime_hours() >= 6 and WorldTime._get_worldtime_hours() <= 7:
		day_status.text = "Sun Rise"
	elif WorldTime._get_worldtime_hours() > 7 and WorldTime._get_worldtime_hours() < 12:
		day_status.text = "Morning"
	elif WorldTime._get_worldtime_hours() >= 12 and WorldTime._get_worldtime_hours() <= 12+2:
		day_status.text = "Noon"
	elif WorldTime._get_worldtime_hours() > 2 + 12 and WorldTime._get_worldtime_hours() <= 4 + 12:
		day_status.text = "After Noon"
	elif WorldTime._get_worldtime_hours() > 4 + 12 and WorldTime._get_worldtime_hours() < 6 + 12:
		day_status.text = "Sun Set"
	else :
		day_status.text = "Night"

func _set_icon():
	var icon := $VBox/HBox/Icon
	icon.set_icon("Sun")
	match day_status.text:
		"Night":
			icon.set_icon("Moon")
		"Sun Set":
			icon.set_icon("Sunset")
		"Sun Rise":
			icon.set_icon("Sunrise")
	pass
