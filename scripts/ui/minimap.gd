extends Control
## Simple minimap that draws dots for player and enemies.

@export var map_size: float = 150.0
@export var map_scale: float = 0.1
@export var player_color: Color = Color(0.3, 0.5, 1.0)
@export var enemy_color: Color = Color(1.0, 0.3, 0.3)
@export var bg_color: Color = Color(0, 0, 0, 0.5)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# Background circle
	var center := Vector2(map_size / 2.0, map_size / 2.0)
	draw_circle(center, map_size / 2.0, bg_color)

	var player := get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player):
		return

	# Player dot at center
	draw_circle(center, 4.0, player_color)

	# Enemy dots
	var enemies := get_tree().get_nodes_in_group("enemies")
	# Also get all CharacterBody2D on enemy layer
	for node in get_tree().get_nodes_in_group("enemies"):
		_draw_entity(center, player.global_position, node.global_position, enemy_color)

	# Fallback: find enemies by checking all nodes with "died" signal (our enemy scripts)
	if enemies.is_empty():
		for node in get_tree().get_nodes_in_group(""):
			pass  # handled below

func _draw_entity(center: Vector2, player_pos: Vector2, entity_pos: Vector2, color: Color) -> void:
	var offset: Vector2 = (entity_pos - player_pos) * map_scale
	var dot_pos: Vector2 = center + offset

	# Clamp to minimap circle
	var dist: float = dot_pos.distance_to(center)
	if dist > map_size / 2.0 - 4.0:
		dot_pos = center + (dot_pos - center).normalized() * (map_size / 2.0 - 4.0)

	draw_circle(dot_pos, 3.0, color)
