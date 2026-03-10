extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel

func _ready() -> void:
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)

	var best: int = HighScoreManager.get_high_score()
	if best > 0:
		high_score_label.text = "High Score: %d" % best
	else:
		high_score_label.text = ""

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/world/game_world.tscn")

func _on_quit() -> void:
	get_tree().quit()
