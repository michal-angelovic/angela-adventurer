extends Node2D

signal ammo_changed(current_ammo: int, max_ammo: int)

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.3
@export var bullet_speed: float = 800.0
@export var damage: float = 25.0
@export var max_ammo: int = 12
@export var reload_time: float = 1.5

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

	# Spawn bullet
	var bullet := bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = muzzle.global_rotation
	bullet.speed = bullet_speed
	bullet.damage = damage
	get_tree().current_scene.add_child(bullet)

	cooldown_timer.start(fire_rate)

func reload() -> void:
	if is_reloading or current_ammo == max_ammo:
		return
	is_reloading = true
	reload_timer.start(reload_time)

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
