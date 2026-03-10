extends Area2D
## Bullet fired by ranged enemies. Uses EnemyProjectiles layer (5).

var speed: float = 400.0
var damage: float = 8.0

@onready var lifetime_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(lifetime_timer)
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start(3.0)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
