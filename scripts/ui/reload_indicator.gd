extends Control
## Draws a circular reload progress arc around the mouse cursor.

var _is_reloading: bool = false
var _reload_duration: float = 0.0
var _reload_elapsed: float = 0.0
var _connected_weapon: Node2D = null

const ARC_RADIUS: float = 20.0
const ARC_WIDTH: float = 3.0
const ARC_COLOR: Color = Color(1.0, 1.0, 1.0, 0.8)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Full screen so we can draw anywhere
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player:
		if player.current_weapon:
			connect_weapon(player.current_weapon)
		if player.has_signal("weapon_switched"):
			player.weapon_switched.connect(_on_weapon_switched)

func _process(delta: float) -> void:
	if _is_reloading:
		_reload_elapsed += delta
		if _reload_elapsed >= _reload_duration:
			_is_reloading = false
		queue_redraw()
	elif is_visible():
		queue_redraw()

func _draw() -> void:
	if not _is_reloading:
		return
	var progress: float = clampf(_reload_elapsed / _reload_duration, 0.0, 1.0)
	var mouse_pos: Vector2 = get_local_mouse_position()
	var end_angle: float = -PI / 2.0 + progress * TAU
	# Draw background arc (dim)
	draw_arc(mouse_pos, ARC_RADIUS, -PI / 2.0, -PI / 2.0 + TAU, 32, Color(0.3, 0.3, 0.3, 0.4), ARC_WIDTH)
	# Draw progress arc
	if progress > 0.01:
		draw_arc(mouse_pos, ARC_RADIUS, -PI / 2.0, end_angle, 32, ARC_COLOR, ARC_WIDTH)

func connect_weapon(weapon: Node2D) -> void:
	_disconnect_weapon()
	_connected_weapon = weapon
	if weapon.has_signal("reload_started"):
		weapon.reload_started.connect(_on_reload_started)
	if weapon.has_signal("reload_cancelled"):
		weapon.reload_cancelled.connect(_on_reload_finished)

func _disconnect_weapon() -> void:
	if _connected_weapon:
		if _connected_weapon.reload_started.is_connected(_on_reload_started):
			_connected_weapon.reload_started.disconnect(_on_reload_started)
		if _connected_weapon.reload_cancelled.is_connected(_on_reload_finished):
			_connected_weapon.reload_cancelled.disconnect(_on_reload_finished)
	_connected_weapon = null

func _on_weapon_switched(weapon: Node2D) -> void:
	_is_reloading = false
	connect_weapon(weapon)

func _on_reload_started(duration: float) -> void:
	_is_reloading = true
	_reload_duration = duration
	_reload_elapsed = 0.0

func _on_reload_finished() -> void:
	_is_reloading = false
