extends CharacterBody2D
## Ranged enemy that keeps distance and shoots at the player.

signal died(enemy: CharacterBody2D)

@export var speed: float = 80.0
@export var max_health: float = 40.0
@export var contact_damage: float = 5.0
@export var score_value: int = 20
@export var preferred_distance: float = 300.0
@export var flee_distance: float = 150.0
@export var shoot_cooldown: float = 2.0
@export var bullet_speed: float = 400.0
@export var bullet_damage: float = 8.0

var current_health: float
var player: CharacterBody2D = null
var can_shoot: bool = true
var _hit_flash_shader: Shader = preload("res://resources/shaders/hit_flash.gdshader")
var _blood_scene: PackedScene = preload("res://scenes/effects/blood_splatter.tscn")
var _health_bar: Node2D = null
var _health_bar_scene: PackedScene = preload("res://scenes/enemies/enemy_health_bar.tscn")

@onready var shoot_timer: Timer = Timer.new()

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
	add_child(shoot_timer)
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(func(): can_shoot = true)
	_health_bar = _health_bar_scene.instantiate()
	add_child(_health_bar)
	_health_bar.setup(max_health, current_health)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	var dist := global_position.distance_to(player.global_position)
	var direction := global_position.direction_to(player.global_position)
	look_at(player.global_position)

	# Flee if too close, approach if too far, strafe if in range
	if dist < flee_distance:
		velocity = -direction * speed * 1.5
	elif dist > preferred_distance + 50.0:
		velocity = direction * speed
	else:
		# Strafe perpendicular
		velocity = direction.rotated(PI / 2) * speed * 0.5

	move_and_slide()

	# Shoot at player if in range
	if dist < preferred_distance + 100.0 and can_shoot:
		_shoot_at_player()

func _shoot_at_player() -> void:
	can_shoot = false
	shoot_timer.start(shoot_cooldown)

	var bullet_scene: PackedScene = preload("res://scenes/enemies/enemy_bullet.tscn")
	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.global_rotation = global_position.angle_to_point(player.global_position) + PI
	bullet.speed = bullet_speed
	bullet.damage = bullet_damage
	get_tree().current_scene.add_child(bullet)

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
	CameraShaker.shake(4.0, 0.15)
	died.emit(self)
	queue_free()
