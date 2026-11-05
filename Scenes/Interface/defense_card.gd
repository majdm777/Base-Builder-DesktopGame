extends PanelContainer
const CTAKEN = "#719B55"
const CEMPTY= "#493A2B"

@onready var State := $Card/header/State
@onready var info := $Card/Garrison/info

@onready var DamagePerSoldier := $Card/CombatStat/RowStat1/Damage_Soldier/Value
@onready var AttackInterval := $Card/CombatStat/RowStat1/AttackInterval/Value
@onready var Dps := $Card/CombatStat/RowStat2/Dps/Value
@onready var AttackRange := $Card/CombatStat/RowStat2/Range/Value
@onready var TotalDamage := $Card/CombatStat/TotalDamage

@onready var Capacity := $Card/Garrison/Capacity/Value

@onready var OccupantsBar := $Card/Garrison/Occupants
var Defense : Node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(defense : Node):
	Defense = defense
	pass
	
func update():
	if not is_instance_valid(Defense):
		return
	if Defense.occupants.size() == 0:
		State.text ="Inactive"
		State.theme_type_variation ="Inactive"
		info.visible = true
		info.text = "Tower Is Empty"
	else:
		State.text ="Active"
		State.theme_type_variation ="Active"
		info.visible = false
		
	DamagePerSoldier.text =str(Defense.damage_per_soldier)
	AttackInterval.text = str(Defense.attack_interval)
	Dps.text = str(Defense.dps)
	AttackRange.text = "--"
	
	Capacity.text = str(Defense.occupants.size())+"/"+str(Defense.capacity)
	TotalDamage.text = "Total Damage : "+str(Defense.occupants.size() * Defense.damage_per_soldier)
	for i in OccupantsBar.get_children():
		i.queue_free()
		
	for i in Defense.occupants.size():
		var cr = get_ColorRect(true)
		OccupantsBar.add_child(cr)
		pass
	for y in (Defense.capacity - Defense.occupants.size()):
		var cr = get_ColorRect(false)
		OccupantsBar.add_child(cr)
		pass

func get_ColorRect(taken : bool) -> ColorRect:
	var cr = ColorRect.new()
	if taken:
		cr.color =CTAKEN
	else:
		cr.color = CEMPTY
	cr.custom_minimum_size.y = 6
	cr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return cr
