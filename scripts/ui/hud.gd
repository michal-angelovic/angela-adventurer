extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/HBoxContainer/HealthBar
@onready var ammo_label: Label = $MarginContainer/HBoxContainer/AmmoLabel
@onready var score_label: Label = $ScoreLabel

func _ready() -> void:
	# Connect to GameManager signals
	GameManager.score_changed.connect(_on_score_changed)

	# Find player and connect signals (deferred to ensure scene is ready)
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var health_comp := player.get_node_or_null("PlayerHealth")
		if health_comp:
			health_comp.health_changed.connect(_on_health_changed)
			health_bar.max_value = health_comp.max_health
			health_bar.value = health_comp.current_health

		var weapon_pivot := player.get_node_or_null("WeaponPivot")
		if weapon_pivot and weapon_pivot.get_child_count() > 0:
			var weapon := weapon_pivot.get_child(0)
			weapon.ammo_changed.connect(_on_ammo_changed)

func _on_health_changed(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current

func _on_ammo_changed(current: int, max_ammo: int) -> void:
	ammo_label.text = "%d / %d" % [current, max_ammo]

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
