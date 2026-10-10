extends Node

signal round_started(round_number: int)
signal round_ended(round_number: int)

# --- Round state ---
var round_number : int = 0
var attack_in_progress : bool = false
var alive_enemies : int = 0
var _spawning : bool = false

# --- Tuning ---
const BASE_BUDGET := 10
const BUDGET_GROWTH := 1.15
const MAX_WAVE_SIZE := 100      # hard cap on bodies per wave (performance)
const SPAWN_DELAY := 0.3        # seconds between each enemy
const SPAWN_JITTER := 2.0       # random offset around a spawn point

# --- Enemy types (plain data, since an autoload can't use @export) ---
# cost: budget points | min_round: first round it can appear | weight: how often it's picked
const ENEMY_TYPES := [
	{ "scene": preload("res://Scenes/Enemies/enemy.tscn"), "cost": 1, "min_round": 1, "weight": 10 },
	# Uncomment as you create these scenes (a wrong path fails at parse time):
	# { "scene": preload("res://Scenes/Enemies/enemy_ranged.tscn"), "cost": 3, "min_round": 3, "weight": 5 },
	# { "scene": preload("res://Scenes/Enemies/enemy_brute.tscn"),  "cost": 8, "min_round": 6, "weight": 2 },
]


func _ready() -> void:
	WorldTime.day_changed.connect(_on_day_changed)


func _on_day_changed(_day: int, _month: int, _year: int) -> void:
	round_number += 1
	_start_attack(round_number)


# Temporary debug key: remove when happy
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		round_number += 1
		_start_attack(round_number)


# ---------------- Attack flow ----------------

func _start_attack(round_num: int) -> void:
	var active_points : Array = []
	for sp in get_tree().get_nodes_in_group("EnemySpawnPoint"):
		if sp.active_from_round <= round_num:
			active_points.append(sp)

	if active_points.is_empty():
		push_warning("AttackManager: no active spawn points for round %d" % round_num)
		return

	var wave := _build_wave(round_num)
	if wave.is_empty():
		push_warning("AttackManager: empty wave for round %d" % round_num)
		return

	attack_in_progress = true
	_spawning = true
	round_started.emit(round_num)
	print("Round %d: budget %d, %d enemies" % [round_num, _get_round_budget(round_num), wave.size()])

	for i in wave.size():
		var sp = active_points[i % active_points.size()]
		if not is_instance_valid(sp):
			continue
		var enemy = wave[i].instantiate()
		BuilderManager.map_root.add_child(enemy)
		enemy.global_position = sp.global_position + Vector3(
			randf_range(-SPAWN_JITTER, SPAWN_JITTER), 0,
			randf_range(-SPAWN_JITTER, SPAWN_JITTER))
		alive_enemies += 1
		enemy.tree_exited.connect(_on_enemy_gone)
		await get_tree().create_timer(SPAWN_DELAY).timeout

	_spawning = false
	_check_round_end()


func _on_enemy_gone() -> void:
	alive_enemies = maxi(alive_enemies - 1, 0)
	_check_round_end()


func _check_round_end() -> void:
	if attack_in_progress and not _spawning and alive_enemies == 0:
		end_round()


func end_round() -> void:
	attack_in_progress = false
	round_ended.emit(round_number)


# ---------------- Budget / wave building ----------------

func _get_round_budget(round_num: int) -> int:
	return int(BASE_BUDGET * pow(BUDGET_GROWTH, round_num - 1))


func _build_wave(round_num: int) -> Array:
	var budget := _get_round_budget(round_num)
	var unlocked := ENEMY_TYPES.filter(func(t): return t.min_round <= round_num)
	var wave : Array = []

	while budget > 0 and wave.size() < MAX_WAVE_SIZE:
		var affordable := unlocked.filter(func(t): return t.cost <= budget)
		if affordable.is_empty():
			break
		var type : Dictionary = _pick_weighted(affordable)
		wave.append(type.scene)
		budget -= type.cost
	return wave


func _pick_weighted(types: Array) -> Dictionary:
	var total := 0
	for t in types:
		total += t.weight
	var roll := randi_range(1, total)
	for t in types:
		roll -= t.weight
		if roll <= 0:
			return t
	return types[0]
