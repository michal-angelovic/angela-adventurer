extends Area2D

enum LootType { HEALTH, AMMO }

@export var loot_type: LootType = LootType.HEALTH
@export var health_amount: float = 25.0
@export var ammo_amount: int = 6

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# Randomly choose loot type
	if randf() < 0.5:
		loot_type = LootType.HEALTH
	else:
		loot_type = LootType.AMMO

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	match loot_type:
		LootType.HEALTH:
			var health_comp := body.get_node_or_null("PlayerHealth")
			if health_comp:
				health_comp.heal(health_amount)
		LootType.AMMO:
			var weapon_pivot := body.get_node_or_null("WeaponPivot")
			if weapon_pivot and weapon_pivot.get_child_count() > 0:
				var weapon := weapon_pivot.get_child(0)
				if weapon.has_method("add_ammo"):
					weapon.add_ammo(ammo_amount)

	queue_free()
