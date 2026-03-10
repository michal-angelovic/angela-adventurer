extends CharacterBody2D

@export var speed: float = 300.0

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var player_health: Node = $PlayerHealth

var current_weapon: Node2D = null

func _ready() -> void:
	# Get reference to the weapon if one exists
	if weapon_pivot.get_child_count() > 0:
		current_weapon = weapon_pivot.get_child(0)

	# Connect death signal
	player_health.died.connect(_on_died)

func _physics_process(_delta: float) -> void:
	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

	# Rotate toward mouse
	var mouse_pos := get_global_mouse_position()
	look_at(mouse_pos)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and current_weapon:
		current_weapon.shoot()
	elif event.is_action_pressed("reload") and current_weapon:
		current_weapon.reload()

func take_damage(amount: float) -> void:
	if player_health:
		player_health.take_damage(amount)

func _on_died() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	var game_over_scene := preload("res://scenes/ui/game_over.tscn")
	var game_over := game_over_scene.instantiate()
	get_tree().current_scene.add_child(game_over)
	GameManager.trigger_game_over()
