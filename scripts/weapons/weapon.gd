extends Node2D

signal ammo_changed(current_ammo: int, max_ammo: int)
signal reload_started(duration: float)
signal reload_cancelled()

@export var weapon_name: String = "Pistol"
@export var shoot_sound: AudioStream
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3
@export var bullet_speed: float = 800.0
@export var damage: float = 25.0
@export var max_ammo: int = 12
@export var reload_time: float = 1.5
@export var bullet_count: int = 1
@export var spread_angle: float = 0.0
@export var bullet_lifetime: float = 2.0

var current_ammo: int
var can_shoot: bool = true
var is_reloading: bool = false

@onready var muzzle: Marker2D = $Muzzle
@onready var cooldown_timer: Timer = Timer.new()
@onready var reload_timer: Timer = Timer.new()

func _ready() -> void:
	current_ammo = max_ammo

	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

	add_child(reload_timer)
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_timeout)

	ammo_changed.emit(current_ammo, max_ammo)

func shoot() -> void:
	if not can_shoot or is_reloading or current_ammo <= 0:
		if current_ammo <= 0:
			reload()
		return

	can_shoot = false
	current_ammo -= 1
	ammo_changed.emit(current_ammo, max_ammo)

	# Spawn bullet(s)
	var base_rotation: float = muzzle.global_rotation
	for i in bullet_count:
		var bullet := bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		if bullet_count > 1:
			var offset: float = lerp(-spread_angle, spread_angle, float(i) / float(bullet_count - 1))
			bullet.global_rotation = base_rotation + deg_to_rad(offset)
		else:
			bullet.global_rotation = base_rotation
		bullet.speed = bullet_speed
		bullet.damage = damage
		bullet.lifetime = bullet_lifetime
		get_tree().current_scene.add_child(bullet)

	# Muzzle flash
	_show_muzzle_flash()

	# Shoot sound (dedicated channel — restarts each shot, no pool exhaustion)
	if shoot_sound:
		SoundManager.play_weapon_sfx(shoot_sound)

	# Light screen shake on shoot
	CameraShaker.shake(2.0, 0.05)

	cooldown_timer.start(fire_rate)

func _show_muzzle_flash() -> void:
	var flash := GPUParticles2D.new()
	flash.emitting = true
	flash.one_shot = true
	flash.amount = 8
	flash.lifetime = 0.15
	flash.explosiveness = 1.0

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 25.0
	mat.initial_velocity_min = 100.0
	mat.initial_velocity_max = 200.0
	mat.scale_min = 2.0
	mat.scale_max = 4.0
	mat.color = Color(1.0, 0.9, 0.3)
	flash.process_material = mat

	flash.global_position = muzzle.global_position
	flash.global_rotation = muzzle.global_rotation
	get_tree().current_scene.add_child(flash)

	# Auto-cleanup after particles finish
	get_tree().create_timer(0.5).timeout.connect(flash.queue_free)

func reload() -> void:
	if is_reloading or current_ammo == max_ammo:
		return
	is_reloading = true
	reload_timer.start(reload_time)
	reload_started.emit(reload_time)

func cancel_reload() -> void:
	if not is_reloading:
		return
	is_reloading = false
	reload_timer.stop()
	reload_cancelled.emit()

func add_ammo(amount: int) -> void:
	current_ammo = min(current_ammo + amount, max_ammo)
	ammo_changed.emit(current_ammo, max_ammo)

func _on_cooldown_timeout() -> void:
	can_shoot = true

func _on_reload_timeout() -> void:
	current_ammo = max_ammo
	is_reloading = false
	can_shoot = true
	ammo_changed.emit(current_ammo, max_ammo)
	reload_cancelled.emit()
