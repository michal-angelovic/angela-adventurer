extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HBoxContainer/HealthBar
@onready var ammo_label: Label = $MarginContainer/HBoxContainer/AmmoLabel
@onready var weapon_label: Label = $MarginContainer/HBoxContainer/WeaponLabel
@onready var score_label: Label = $ScoreLabel
@onready var wave_label: Label = $WaveLabel

var _connected_weapon: Node2D = null

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)

	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var health_comp := player.get_node_or_null("PlayerHealth")
		if health_comp:
			health_comp.health_changed.connect(_on_health_changed)
			health_bar.max_value = health_comp.max_health
			health_bar.value = health_comp.current_health

		# Connect to current weapon
		if player.current_weapon:
			_connect_weapon(player.current_weapon)

		# Listen for weapon switches
		if player.has_signal("weapon_switched"):
			player.weapon_switched.connect(_on_weapon_switched)

	# Connect wave spawner if present
	var spawner := get_tree().get_first_node_in_group("wave_spawner")
	if not spawner:
		# Try finding by node name
		await get_tree().process_frame
		spawner = get_tree().current_scene.get_node_or_null("WaveSpawner")
	if spawner:
		if spawner.has_signal("wave_started"):
			spawner.wave_started.connect(_on_wave_started)
		if spawner.has_signal("wave_completed"):
			spawner.wave_completed.connect(_on_wave_completed)

func _connect_weapon(weapon: Node2D) -> void:
	if _connected_weapon and _connected_weapon.ammo_changed.is_connected(_on_ammo_changed):
		_connected_weapon.ammo_changed.disconnect(_on_ammo_changed)
	_connected_weapon = weapon
	weapon.ammo_changed.connect(_on_ammo_changed)
	weapon_label.text = weapon.weapon_name
	ammo_label.text = "%d / %d" % [weapon.current_ammo, weapon.max_ammo]

func _on_weapon_switched(weapon: Node2D) -> void:
	_connect_weapon(weapon)

func _on_health_changed(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	ammo_label.text = "%d / %d" % [current, max_ammo]

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "Wave %d" % wave_number
	# Flash the wave text
	var tween := create_tween()
	wave_label.modulate = Color(1, 1, 0)
	tween.tween_property(wave_label, "modulate", Color.WHITE, 1.0)

func _on_wave_completed(wave_number: int) -> void:
	wave_label.text = "Wave %d Complete!" % wave_number
