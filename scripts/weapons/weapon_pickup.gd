extends Area2D
## Weapon pickup that floats and can be collected by the player.

@export var weapon_scene: PackedScene
@export var weapon_display_name: String = "Weapon"

var bob_time: float = 0.0
var start_y: float = 0.0

func _ready() -> void:
	start_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Bobbing animation
	bob_time += delta * 3.0
	position.y = start_y + sin(bob_time) * 4.0

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var weapon_pivot := body.get_node_or_null("WeaponPivot")
	if not weapon_pivot or not weapon_scene:
		return

	# Check if player already has this weapon type
	for child in weapon_pivot.get_children():
		if child.weapon_name == weapon_display_name:
			# Already has it — just add ammo
			child.add_ammo(child.max_ammo)
			queue_free()
			return

	# Add new weapon to player
	var new_weapon: Node2D = weapon_scene.instantiate() as Node2D
	new_weapon.visible = false
	weapon_pivot.add_child(new_weapon)

	# Update player's weapon list
	if body.has_method("_refresh_weapons"):
		body._refresh_weapons()

	queue_free()
