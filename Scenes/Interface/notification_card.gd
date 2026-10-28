extends PanelContainer

# index = Notifications.Severity: INFO, SUGGESTION, WARNING, DANGER
const COLORS := [Color("00f7fdff"), Color("ffffffff"), Color("fca700ff"), Color("#a83a2a")]

var msg_id := -1

func setup(msg: Dictionary) -> void:
	msg_id = msg.id
	$HBox/Stripe.color = COLORS[msg.severity]
	$HBox/Body/Time.text = msg.time
	$HBox/Footer/Dismiss.pressed.connect(func(): Notification.dismiss(msg_id))
	update(msg)

func update(msg: Dictionary) -> void:
	$HBox/Body/Text.text = msg.text
	$HBox/Footer/Count.text = "x%d" % msg.count
	$HBox/Footer/Count.visible = msg.count > 1
	modulate.a = 0.5 if msg.resolved else 1.0    # resolved messages fade out but stay as a record
