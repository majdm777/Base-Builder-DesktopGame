extends Node

signal round_started(round_number: int)
signal round_ended(round_number: int)

var round_number : int = 0
var attack_in_progress : bool = false

func _ready() -> void:
	WorldTime.day_changed.connect(_on_day_changed)

func _on_day_changed(day: int, month: int, year: int) -> void:
	round_number += 1
	round_started.emit(round_number)
	_start_attack(round_number)

func _start_attack(round_num: int) -> void:
	attack_in_progress = true
	print("Attack round %d starting!" % round_num)
	# enemy spawning logic goes here — step 2

func end_round() -> void:
	attack_in_progress = false
	round_ended.emit(round_number)
