extends Node2D

@export var enemy_scene: PackedScene
@export var initial_spawn_interval: float = 3.0
@export var min_spawn_interval: float = 0.5
@export var spawn_acceleration: float = 0.02
@export var max_enemies: int = 50
@export var spawn_distance: float = 600.0

var current_spawn_interval: float
var enemy_count: int = 0

@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	current_spawn_interval = initial_spawn_interval
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start(current_spawn_interval)

func _on_spawn_timer_timeout() -> void:
	if enemy_count >= max_enemies:
		return

	var player := get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player):
		return

	# Spawn at random position around the player
	var angle := randf() * TAU
	var spawn_pos := player.global_position + Vector2.RIGHT.rotated(angle) * spawn_distance

	var enemy := enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	enemy.died.connect(_on_enemy_died)
	get_parent().add_child(enemy)
	enemy_count += 1

	# Gradually increase spawn rate
	current_spawn_interval = max(current_spawn_interval - spawn_acceleration, min_spawn_interval)
	spawn_timer.wait_time = current_spawn_interval

func _on_enemy_died(enemy: CharacterBody2D) -> void:
	enemy_count -= 1
	GameManager.add_score(enemy.score_value)
	# Drop loot with a chance
	if randf() < 0.3:
		_spawn_loot(enemy.global_position)

func _spawn_loot(pos: Vector2) -> void:
	var loot_scene := preload("res://scenes/weapons/loot.tscn")
	var loot := loot_scene.instantiate()
	loot.global_position = pos
	get_parent().add_child(loot)
