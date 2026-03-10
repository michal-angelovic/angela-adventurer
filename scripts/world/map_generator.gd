extends Node2D
## Procedural map generator. Fills ground, places wall borders,
## scatters interior walls and environment objects for cover.

@export var enabled: bool = false  # Toggle in Inspector: false = hand-painted map, true = procedural
@export var map_width: int = 40   # in tiles
@export var map_height: int = 30  # in tiles
@export var tile_size: int = 64
@export var wall_thickness: int = 2
@export var min_cover_clusters: int = 8
@export var max_cover_clusters: int = 14
@export var min_object_count: int = 15
@export var max_object_count: int = 30
@export var player_safe_radius: float = 200.0  # no objects near spawn

@onready var ground_layer: TileMapLayer = $"../GroundLayer"
@onready var wall_layer: TileMapLayer = $"../WallLayer"
@onready var object_layer: Node2D = $"../ObjectLayer"

# Sprite folders for environment objects
var crate_textures: Array[Texture2D] = []
var barrel_textures: Array[Texture2D] = []
var plant_textures: Array[Texture2D] = []

var _env_object_script: GDScript = preload("res://scripts/world/environment_object.gd")

# Cache available tile atlas coords from tilesets
var _ground_tiles: Array[Vector2i] = []
var _wall_tiles: Array[Vector2i] = []
var _ground_source_id: int = 0
var _wall_source_id: int = 0

func _ready() -> void:
	if not enabled:
		return
	_load_environment_textures()
	_cache_tileset_info()
	generate()

func _load_environment_textures() -> void:
	# Load crate sprites
	var crate_dir := DirAccess.open("res://assets/sprites/environment/crates")
	if crate_dir:
		crate_dir.list_dir_begin()
		var file_name := crate_dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				var tex := load("res://assets/sprites/environment/crates/" + file_name) as Texture2D
				if tex:
					crate_textures.append(tex)
			file_name = crate_dir.get_next()

	# Load barrel sprites
	var barrel_dir := DirAccess.open("res://assets/sprites/environment/barrels")
	if barrel_dir:
		barrel_dir.list_dir_begin()
		var file_name := barrel_dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				var tex := load("res://assets/sprites/environment/barrels/" + file_name) as Texture2D
				if tex:
					barrel_textures.append(tex)
			file_name = barrel_dir.get_next()

	# Load plant sprites
	var plant_dir := DirAccess.open("res://assets/sprites/environment/plants")
	if plant_dir:
		plant_dir.list_dir_begin()
		var file_name := plant_dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				var tex := load("res://assets/sprites/environment/plants/" + file_name) as Texture2D
				if tex:
					plant_textures.append(tex)
			file_name = plant_dir.get_next()

func _cache_tileset_info() -> void:
	# Get available ground tiles from the tileset
	if ground_layer and ground_layer.tile_set:
		var ts := ground_layer.tile_set
		if ts.get_source_count() > 0:
			_ground_source_id = ts.get_source_id(0)
			var source := ts.get_source(_ground_source_id) as TileSetAtlasSource
			if source:
				for i in source.get_tiles_count():
					_ground_tiles.append(source.get_tile_id(i))

	# Get available wall tiles from the tileset
	if wall_layer and wall_layer.tile_set:
		var ts := wall_layer.tile_set
		if ts.get_source_count() > 0:
			_wall_source_id = ts.get_source_id(0)
			var source := ts.get_source(_wall_source_id) as TileSetAtlasSource
			if source:
				for i in source.get_tiles_count():
					_wall_tiles.append(source.get_tile_id(i))

func generate() -> void:
	# Clear existing tiles
	ground_layer.clear()
	wall_layer.clear()
	for child in object_layer.get_children():
		child.queue_free()

	_fill_ground()
	_place_border_walls()
	_place_cover_walls()
	_scatter_objects()
	_reposition_player()
	_setup_camera_limits()

func _fill_ground() -> void:
	if _ground_tiles.is_empty():
		return
	for x in range(map_width):
		for y in range(map_height):
			var atlas_coord: Vector2i = _ground_tiles[randi() % _ground_tiles.size()]
			ground_layer.set_cell(Vector2i(x, y), _ground_source_id, atlas_coord)

func _place_border_walls() -> void:
	if _wall_tiles.is_empty():
		return
	for x in range(map_width):
		for y in range(map_height):
			var is_border: bool = (
				x < wall_thickness or x >= map_width - wall_thickness or
				y < wall_thickness or y >= map_height - wall_thickness
			)
			if is_border:
				var atlas_coord: Vector2i = _wall_tiles[randi() % _wall_tiles.size()]
				wall_layer.set_cell(Vector2i(x, y), _wall_source_id, atlas_coord)

func _place_cover_walls() -> void:
	if _wall_tiles.is_empty():
		return
	var cluster_count: int = randi_range(min_cover_clusters, max_cover_clusters)
	var player_spawn := Vector2i(map_width / 2, map_height / 2)
	var safe_tiles: int = ceili(player_safe_radius / tile_size)

	for _i in cluster_count:
		# Random position inside the playable area
		var cx: int = randi_range(wall_thickness + 1, map_width - wall_thickness - 2)
		var cy: int = randi_range(wall_thickness + 1, map_height - wall_thickness - 2)

		# Skip if too close to player spawn
		if absf(cx - player_spawn.x) < safe_tiles and absf(cy - player_spawn.y) < safe_tiles:
			continue

		# Random cluster shape: L, line, block, or single
		var shape: int = randi() % 4
		var cells: Array[Vector2i] = []

		match shape:
			0:  # Horizontal line (2-4 tiles)
				var length: int = randi_range(2, 4)
				for dx in length:
					cells.append(Vector2i(cx + dx, cy))
			1:  # Vertical line (2-4 tiles)
				var length: int = randi_range(2, 4)
				for dy in length:
					cells.append(Vector2i(cx, cy + dy))
			2:  # L-shape
				cells.append(Vector2i(cx, cy))
				cells.append(Vector2i(cx + 1, cy))
				cells.append(Vector2i(cx, cy + 1))
			3:  # 2x2 block
				cells.append(Vector2i(cx, cy))
				cells.append(Vector2i(cx + 1, cy))
				cells.append(Vector2i(cx, cy + 1))
				cells.append(Vector2i(cx + 1, cy + 1))

		for cell in cells:
			# Make sure it's inside the playable area
			if cell.x > wall_thickness and cell.x < map_width - wall_thickness - 1:
				if cell.y > wall_thickness and cell.y < map_height - wall_thickness - 1:
					var atlas_coord: Vector2i = _wall_tiles[randi() % _wall_tiles.size()]
					wall_layer.set_cell(cell, _wall_source_id, atlas_coord)

func _scatter_objects() -> void:
	var all_textures: Array[Texture2D] = []
	all_textures.append_array(crate_textures)
	all_textures.append_array(barrel_textures)
	all_textures.append_array(plant_textures)

	if all_textures.is_empty():
		return

	var obj_count: int = randi_range(min_object_count, max_object_count)
	var player_spawn := Vector2(map_width * tile_size / 2.0, map_height * tile_size / 2.0)
	var placed_positions: Array[Vector2] = []
	var min_distance: float = tile_size * 1.5  # Minimum distance between objects

	var attempts: int = 0
	var placed: int = 0

	while placed < obj_count and attempts < obj_count * 5:
		attempts += 1

		# Random position inside playable area (in pixels)
		var px: float = randf_range(
			(wall_thickness + 1) * tile_size,
			(map_width - wall_thickness - 1) * tile_size
		)
		var py: float = randf_range(
			(wall_thickness + 1) * tile_size,
			(map_height - wall_thickness - 1) * tile_size
		)
		var pos := Vector2(px, py)

		# Skip if too close to player spawn
		if pos.distance_to(player_spawn) < player_safe_radius:
			continue

		# Skip if too close to another object
		var too_close: bool = false
		for other_pos in placed_positions:
			if pos.distance_to(other_pos) < min_distance:
				too_close = true
				break
		if too_close:
			continue

		# Skip if there's a wall tile at this position
		var tile_pos := Vector2i(int(px / tile_size), int(py / tile_size))
		if wall_layer.get_cell_source_id(tile_pos) != -1:
			continue

		# Create the object
		var obj := StaticBody2D.new()
		obj.script = _env_object_script
		obj.position = pos

		var sprite := Sprite2D.new()
		sprite.texture = all_textures[randi() % all_textures.size()]
		obj.add_child(sprite)

		# Collision shape sized to the sprite
		var col_shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		if sprite.texture:
			var tex_size: Vector2 = sprite.texture.get_size()
			rect_shape.size = tex_size * 0.7  # Slightly smaller than visual
		else:
			rect_shape.size = Vector2(40, 40)
		col_shape.shape = rect_shape
		obj.add_child(col_shape)

		# Set collision — World layer, collide with everything
		obj.collision_layer = 1
		obj.collision_mask = 0

		# Random slight rotation for visual variety
		obj.rotation = randf_range(-0.1, 0.1)

		object_layer.add_child(obj)
		placed_positions.append(pos)
		placed += 1

func _reposition_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = get_player_spawn_position()

func _setup_camera_limits() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var camera: Camera2D = player.get_node_or_null("Camera2D")
	if not camera:
		return
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_width * tile_size
	camera.limit_bottom = map_height * tile_size

func get_player_spawn_position() -> Vector2:
	return Vector2(map_width * tile_size / 2.0, map_height * tile_size / 2.0)

func get_map_bounds() -> Rect2:
	return Rect2(
		Vector2.ZERO,
		Vector2(map_width * tile_size, map_height * tile_size)
	)
