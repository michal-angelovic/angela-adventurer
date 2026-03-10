extends Node

signal health_changed(current_health: float, max_health: float)
signal died

@export var max_health: float = 100.0
@export var invincibility_duration: float = 0.5

var current_health: float
var is_invincible: bool = false

@onready var invincibility_timer: Timer = Timer.new()

func _ready() -> void:
	current_health = max_health
	add_child(invincibility_timer)
	invincibility_timer.one_shot = true
	invincibility_timer.timeout.connect(_on_invincibility_timeout)
	health_changed.emit(current_health, max_health)

func take_damage(amount: float) -> void:
	if is_invincible:
		return
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		died.emit()
		return

	# Start invincibility frames
	is_invincible = true
	invincibility_timer.start(invincibility_duration)

	# Screen shake on damage
	CameraShaker.shake(6.0, 0.2)

	# Visual feedback — flash the player sprite
	var sprite := get_parent().get_node_or_null("Sprite2D")
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func _on_invincibility_timeout() -> void:
	is_invincible = false
