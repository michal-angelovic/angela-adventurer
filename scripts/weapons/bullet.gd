extends Area2D

var speed: float = 800.0
var damage: float = 25.0
var lifetime: float = 2.0
var _is_impacting: bool = false

@onready var lifetime_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(lifetime_timer)
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_expired)
	lifetime_timer.start(lifetime)

	body_entered.connect(_on_body_entered)

	# Start fly animation if using AnimatedSprite2D
	var anim_sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if anim_sprite:
		anim_sprite.play("fly")
		anim_sprite.animation_finished.connect(_on_impact_finished)

func _physics_process(delta: float) -> void:
	if _is_impacting:
		return
	position += transform.x * speed * delta

func _play_impact() -> void:
	if _is_impacting:
		return
	_is_impacting = true
	lifetime_timer.stop()
	# Disable collision so it doesn't hit anything else during impact anim
	set_deferred("monitoring", false)
	var anim_sprite := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if anim_sprite and anim_sprite.sprite_frames.has_animation("impact"):
		# Flip so impact expands in the travel direction, not backwards
		anim_sprite.flip_h = true
		anim_sprite.flip_v = true
		anim_sprite.play("impact")
	else:
		queue_free()

func _on_impact_finished() -> void:
	if _is_impacting:
		queue_free()

func _on_lifetime_expired() -> void:
	_play_impact()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	_play_impact()
