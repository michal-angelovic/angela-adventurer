extends Node2D
## One-shot blood splatter animation. Frees itself when done.

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim_sprite.scale = Vector2(2.0, 2.0)
	anim_sprite.animation_finished.connect(_on_finished)
	var variant: int = randi_range(1, 5)
	var anim_name: String = "blood_%d" % variant
	if anim_sprite.sprite_frames.has_animation(anim_name):
		anim_sprite.play(anim_name)
	else:
		anim_sprite.play("blood_1")
	rotation = randf() * TAU
	z_index = -1
	# Safety: auto-free after 2s in case animation_finished never fires
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(queue_free)

func _on_finished() -> void:
	queue_free()
