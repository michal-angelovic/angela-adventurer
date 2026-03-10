extends Node2D

@onready var fill: ColorRect = $Fill
@onready var bg: ColorRect = $Background
var _tween: Tween
var _max_hp: float = 1.0
const BAR_WIDTH: float = 40.0

func _ready() -> void:
	modulate.a = 0.0
	set_as_top_level(true)

func _process(_delta: float) -> void:
	if is_instance_valid(get_parent()):
		global_position = get_parent().global_position

func setup(max_hp: float, current_hp: float) -> void:
	_max_hp = max_hp
	_update_fill(current_hp)

func update_health(current_hp: float) -> void:
	_update_fill(current_hp)
	show_bar()

func _update_fill(current_hp: float) -> void:
	var ratio := clampf(current_hp / _max_hp, 0.0, 1.0)
	fill.size.x = BAR_WIDTH * ratio
	# Green when healthy, yellow at half, red when low
	if ratio > 0.5:
		fill.color = Color(0.2, 0.8, 0.2)
	elif ratio > 0.25:
		fill.color = Color(0.9, 0.8, 0.1)
	else:
		fill.color = Color(0.9, 0.2, 0.2)

func show_bar() -> void:
	if _tween:
		_tween.kill()
	modulate.a = 1.0
	_tween = create_tween()
	_tween.tween_interval(1.0)
	_tween.tween_property(self, "modulate:a", 0.0, 0.4)
