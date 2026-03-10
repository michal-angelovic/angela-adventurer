extends Node2D
## Wave-based enemy spawner. Replaces the continuous spawner.

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_enemies_dead

@export var spawn_distance: float = 600.0
@export var rest_duration: float = 4.0

var current_wave: int = 0
var enemies_remaining: int = 0
var enemies_to_spawn: int = 0
var is_spawning: bool = false
var is_resting: bool = false

var enemy_scenes: Array[PackedScene] = [
	preload("res://scenes/enemies/basic_enemy.tscn"),
	preload("res://scenes/enemies/runner_enemy.tscn"),
	preload("res://scenes/enemies/tank_enemy.tscn"),
	preload("res://scenes/enemies/ranged_enemy.tscn"),
]

@onready var spawn_timer: Timer = Timer.new()
@onready var rest_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_spawn_one_enemy)

	add_child(rest_timer)
	rest_timer.one_shot = true
	rest_timer.timeout.connect(_start_next_wave)

	# Start first wave after a brief delay
	rest_timer.start(2.0)

func _start_next_wave() -> void:
	current_wave += 1
	is_resting = false

	# Calculate enemies for this wave
	enemies_to_spawn = 5 + current_wave * 3
	enemies_remaining = enemies_to_spawn

	wave_started.emit(current_wave)

	# Spawn interval gets faster each wave
	var interval: float = max(0.8 - current_wave * 0.05, 0.2)
	spawn_timer.start(interval)
	is_spawning = true

func _spawn_one_enemy() -> void:
	if enemies_to_spawn <= 0:
		spawn_timer.stop()
		is_spawning = false
		return

	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if not is_instance_valid(player):
		return

	var angle: float = randf() * TAU
	var spawn_pos: Vector2 = player.global_position + Vector2.RIGHT.rotated(angle) * spawn_distance

	var enemy_scene: PackedScene = _pick_enemy_for_wave()
	var enemy: Node2D = enemy_scene.instantiate() as Node2D
	enemy.global_position = spawn_pos
	enemy.died.connect(_on_enemy_died)
	get_parent().add_child(enemy)

	enemies_to_spawn -= 1

func _pick_enemy_for_wave() -> PackedScene:
	# Weighted selection based on wave number
	var roll: float = randf()

	if current_wave < 3:
		# Early waves: mostly basic
		return enemy_scenes[0]
	elif current_wave < 6:
		# Mid waves: introduce runners
		if roll < 0.6:
			return enemy_scenes[0]
		elif roll < 0.9:
			return enemy_scenes[1]
		else:
			return enemy_scenes[2]
	else:
		# Late waves: all types
		if roll < 0.3:
			return enemy_scenes[0]
		elif roll < 0.55:
			return enemy_scenes[1]
		elif roll < 0.8:
			return enemy_scenes[2]
		else:
			return enemy_scenes[3]

func _on_enemy_died(enemy: CharacterBody2D) -> void:
	enemies_remaining -= 1
	GameManager.add_score(enemy.score_value)

	# Drop loot
	if randf() < 0.25:
		_spawn_loot(enemy.global_position)

	# Check if wave is complete
	if enemies_remaining <= 0 and not is_spawning:
		wave_completed.emit(current_wave)
		is_resting = true
		rest_timer.start(rest_duration)

func _spawn_loot(pos: Vector2) -> void:
	var loot_scene: PackedScene = preload("res://scenes/weapons/loot.tscn")
	var loot: Node2D = loot_scene.instantiate() as Node2D
	loot.global_position = pos
	get_parent().add_child(loot)
