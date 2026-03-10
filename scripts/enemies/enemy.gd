extends CharacterBody2D

signal died(enemy: CharacterBody2D)

@export var speed: float = 120.0
@export var max_health: float = 50.0
@export var contact_damage: float = 10.0
@export var score_value: int = 10

var current_health: float
var player: CharacterBody2D = null

func _ready() -> void:
	current_health = max_health
	# Find the player in the scene
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	# Chase the player
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * speed
	look_at(player.global_position)
	move_and_slide()

func take_damage(amount: float) -> void:
	current_health -= amount

	# Flash white on hit
	var sprite := get_node_or_null("Sprite2D")
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.05)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if current_health <= 0.0:
		die()

func die() -> void:
	died.emit(self)
	queue_free()
