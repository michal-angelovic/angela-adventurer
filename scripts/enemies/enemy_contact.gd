extends Area2D
## Attach this to the enemy's HurtBox Area2D to deal contact damage to the player.

@export var damage: float = 10.0
@export var damage_cooldown: float = 1.0

var can_damage: bool = true
@onready var cooldown_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(func(): can_damage = true)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not can_damage:
		return
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		can_damage = false
		cooldown_timer.start(damage_cooldown)
