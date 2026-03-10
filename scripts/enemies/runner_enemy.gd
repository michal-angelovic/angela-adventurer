extends CharacterBody2D
## Fast, low-health enemy that rushes the player.

signal died(enemy: CharacterBody2D)

@export var speed: float = 220.0
@export var max_health: float = 25.0
@export var contact_damage: float = 5.0
@export var score_value: int = 15

var current_health: float
var player: CharacterBody2D = null
var _hit_flash_shader: Shader = preload("res://resources/shaders/hit_flash.gdshader")
var _blood_scene: PackedScene = preload("res://scenes/effects/blood_splatter.tscn")
var _health_bar: Node2D = null
var _health_bar_scene: PackedScene = preload("res://scenes/enemies/enemy_health_bar.tscn")

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr:
		var mat := ShaderMaterial.new()
		mat.shader = _hit_flash_shader
		mat.set_shader_parameter("flash_amount", 0.0)
		mat.set_shader_parameter("flash_color", Color(1, 1, 1, 1))
		spr.material = mat
	_health_bar = _health_bar_scene.instantiate()
	add_child(_health_bar)
	_health_bar.setup(max_health, current_health)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * speed
	look_at(player.global_position)
	move_and_slide()

func take_damage(amount: float) -> void:
	current_health -= amount
	var blood := _blood_scene.instantiate()
	blood.global_position = global_position
	get_tree().current_scene.add_child(blood)
	if _health_bar:
		_health_bar.update_health(current_health)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and sprite.material is ShaderMaterial:
		var mat := sprite.material as ShaderMaterial
		var tween := create_tween()
		tween.tween_method(func(val: float) -> void: mat.set_shader_parameter("flash_amount", val), 1.0, 0.0, 0.15)
	if current_health <= 0.0:
		die()

func die() -> void:
	CameraShaker.shake(3.0, 0.1)
	died.emit(self)
	queue_free()
