extends CanvasLayer

@onready var score_label: Label = $PanelContainer/VBoxContainer/FinalScoreLabel
@onready var high_score_label: Label = $PanelContainer/VBoxContainer/HighScoreLabel
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $PanelContainer/VBoxContainer/MenuButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	var final_score: int = GameManager.score
	score_label.text = "Score: %d" % final_score

	# Save and check high score
	var is_new_high: bool = HighScoreManager.add_score(final_score)
	if is_new_high and final_score == HighScoreManager.get_high_score():
		high_score_label.text = "NEW HIGH SCORE!"
	else:
		high_score_label.text = "Best: %d" % HighScoreManager.get_high_score()

	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameManager.restart_game()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
