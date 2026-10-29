extends PanelContainer

# index = Notifications.Severity: INFO, SUGGESTION, WARNING, DANGER
const COLORS := [Color("263F55"),Color("3F4529"), Color("a76f00ff"), Color("610d01ff")]
const FONTS_COLORS := [Color("8CCBFF"),Color("D6E79A"), Color("FFD18A"), Color("FF9A9A")]
var msg_id := -1

func setup(msg: Dictionary) -> void:
	msg_id = msg.id
	$HBox/Stripe.color = COLORS[msg.severity]
	$HBox/Body/Time.text = msg.time
	$HBox/Footer/Dismiss.pressed.connect(func(): Notification.dismiss(msg_id))
	update(msg)

func update(msg: Dictionary) -> void:
	$HBox/Body/Text.text = msg.text
	
	#TODO later 
	#$HBox/Body/Text.add_theme_color_override("font_color",COLORS[msg.severity])
	
	$HBox/Footer/Count.text = "x%d" % msg.count
	$HBox/Footer/Count.visible = msg.count > 1
	modulate.a = 0.5 if msg.resolved else 1.0    # resolved messages fade out but stay as a record
