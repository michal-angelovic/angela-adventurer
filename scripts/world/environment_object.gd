extends StaticBody2D
## Base script for environment objects (crates, barrels, etc.)
## Can optionally be destructible.

@export var max_health: float = 0.0  # 0 = indestructible
@export var destructible: bool = false

var current_health: float

func _ready() -> void:
	current_health = max_health
	collision_layer = 1  # World layer

func take_damage(amount: float) -> void:
	if not destructible:
		return
	current_health -= amount
	# Flash on hit
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr:
		var tween := create_tween()
		tween.tween_property(spr, "modulate", Color(1, 0.5, 0.5), 0.05)
		tween.tween_property(spr, "modulate", Color.WHITE, 0.1)
	if current_health <= 0.0:
		queue_free()
