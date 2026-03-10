extends CharacterBody2D

signal weapon_switched(weapon: Node2D)

@export var speed: float = 300.0

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var player_health: Node = $PlayerHealth
@onready var sprite: Sprite2D = $Sprite2D

var weapons: Array[Node2D] = []
var current_weapon_index: int = 0
var current_weapon: Node2D = null

# Preload player sprites for each weapon type
var weapon_sprites: Dictionary = {
	"Pistol": preload("res://assets/sprites/player/manBlue_pistol.png"),
	"Rifle": preload("res://assets/sprites/player/manBlue_rifle.png"),
	"Shotgun": preload("res://assets/sprites/player/manBlue_shotgun.png"),
}

# Muzzle positions matching gun tips in player sprites
var muzzle_offsets: Dictionary = {
	"Pistol": Vector2(25, 8),
	"Rifle": Vector2(30, 8),
	"Shotgun": Vector2(30, 8),
}

func _ready() -> void:
	# Collect all weapons from WeaponPivot
	for child in weapon_pivot.get_children():
		weapons.append(child)
		child.visible = false

	# Activate first weapon
	if weapons.size() > 0:
		current_weapon = weapons[0]
		current_weapon.visible = true
		_update_player_sprite(current_weapon)

	# Connect death signal
	player_health.died.connect(_on_died)

func _physics_process(_delta: float) -> void:
	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

	# Rotate toward mouse
	var mouse_pos := get_global_mouse_position()
	look_at(mouse_pos)

	# Full-auto shooting — hold LMB to keep firing (fire rate timer handles cooldown)
	if Input.is_action_pressed("shoot") and current_weapon:
		current_weapon.shoot()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload") and current_weapon:
		current_weapon.reload()
	elif event.is_action_pressed("weapon_1"):
		_switch_weapon(0)
	elif event.is_action_pressed("weapon_2"):
		_switch_weapon(1)
	elif event.is_action_pressed("weapon_3"):
		_switch_weapon(2)

func _switch_weapon(index: int) -> void:
	if index < 0 or index >= weapons.size() or index == current_weapon_index:
		return

	if current_weapon:
		current_weapon.visible = false
		current_weapon.cancel_reload()

	current_weapon_index = index
	current_weapon = weapons[index]
	current_weapon.visible = true
	_update_player_sprite(current_weapon)
	weapon_switched.emit(current_weapon)

func _refresh_weapons() -> void:
	"""Called when a new weapon is added via pickup."""
	weapons.clear()
	for child in weapon_pivot.get_children():
		weapons.append(child)
		if child != current_weapon:
			child.visible = false

func _update_player_sprite(weapon: Node2D) -> void:
	var wname: String = weapon.weapon_name if weapon else "Pistol"
	if weapon_sprites.has(wname):
		sprite.texture = weapon_sprites[wname]
	# Hide weapon sprite — player sprite already shows the gun
	var weapon_sprite: Sprite2D = weapon.get_node_or_null("Sprite2D")
	if weapon_sprite:
		weapon_sprite.visible = false
	# Reposition muzzle to match gun tip in player sprite
	var muzzle: Marker2D = weapon.get_node_or_null("Muzzle")
	if muzzle and muzzle_offsets.has(wname):
		muzzle.position = muzzle_offsets[wname]

func take_damage(amount: float) -> void:
	if player_health:
		player_health.take_damage(amount)

func _on_died() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	var game_over_scene := preload("res://scenes/ui/game_over.tscn")
	var game_over := game_over_scene.instantiate()
	get_tree().current_scene.add_child(game_over)
	GameManager.trigger_game_over()
