extends Node

signal day_changed(day: int, month: int, year: int)
signal month_changed(month: int, year: int)
signal year_changed(year: int)

const SECONDS_PER_HOUR := 60
const HOURS_PER_DAY := 24.0
const SECONDS_PER_DAY := SECONDS_PER_HOUR * HOURS_PER_DAY  # 1440

const DAYS_PER_MONTH := 30
const MONTHS_PER_YEAR := 12

var day : int = 1
var month : int = 1
var year : int = 1000

var moon_light : DirectionalLight3D
const MOON_COLOR := Color(0.4, 0.5, 0.75)
const MAX_MOON_ENERGY := 0.12

var time_of_day : float = 0.5  # 0.0 = midnight, 0.5 = noon, 1.0 = next midnight
var elapsed_seconds_today : float = SECONDS_PER_DAY * 00

var sun_light : DirectionalLight3D
var max_sun_energy : float = 1.2
var min_night_energy : float = 0.12  # "hard to see, not pure black"

func _ready() -> void:
	sun_light = get_tree().current_scene.find_child("Sun", true, false)
	moon_light = get_tree().current_scene.find_child("Moon", true, false)
	if sun_light == null:
		push_error("WorldTime: no DirectionalLight3D named 'Sun' found.")
	if moon_light == null:
		push_error("WorldTime: no DirectionalLight3D named 'Moon' found.")
func _process(delta: float) -> void:
	elapsed_seconds_today += delta
	time_of_day = elapsed_seconds_today / SECONDS_PER_DAY
	if elapsed_seconds_today >= SECONDS_PER_DAY:
		elapsed_seconds_today -= SECONDS_PER_DAY
		_advance_day()

	_update_sun()
	_update_moon()

func _advance_day() -> void:
	day += 1
	if day > DAYS_PER_MONTH:
		day = 1
		month += 1
		if month > MONTHS_PER_YEAR:
			month = 1
			year += 1
			year_changed.emit(year)
		month_changed.emit(month, year)
	day_changed.emit(day, month, year)

func _update_sun() -> void:
	if sun_light == null:
		return
	var theta_deg := time_of_day * 360.0 - 270.0
	sun_light.rotation_degrees = Vector3(theta_deg, 0.0, 0.0)
	var sun_factor = clamp(-sin(deg_to_rad(theta_deg)), 0.0, 1.0)
	sun_light.light_energy = sun_factor * max_sun_energy

func _update_moon() -> void:
	if moon_light == null:
		return
	# Moon is opposite the sun: same theta, offset 180 degrees
	var theta_deg := time_of_day * 360.0 - 270.0 + 180.0
	moon_light.rotation_degrees = Vector3(theta_deg, 0.0, 0.0)
	var moon_factor = clamp(-sin(deg_to_rad(theta_deg)), 0.0, 1.0)
	moon_light.light_energy = moon_factor * MAX_MOON_ENERGY
	moon_light.light_color = MOON_COLOR

func get_time_string() -> String:
	var hours := int(elapsed_seconds_today / SECONDS_PER_HOUR)
	var minutes := int(fmod(elapsed_seconds_today, SECONDS_PER_HOUR) / SECONDS_PER_HOUR * 60.0)
	return "%02d:%02d" % [hours, minutes]
	
func get_date_string() -> String:
	return "%d/ %d / %d" % [day, month, year]
