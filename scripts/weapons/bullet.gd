extends Area2D

var speed: float = 800.0
var damage: float = 25.0

@onready var lifetime_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(lifetime_timer)
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start(2.0)

	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
