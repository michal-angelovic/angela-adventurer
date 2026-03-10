extends CanvasLayer

@onready var score_label: Label = $PanelContainer/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)
	score_label.text = "Score: %d" % GameManager.score
	# Pause the game
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameManager.restart_game()
