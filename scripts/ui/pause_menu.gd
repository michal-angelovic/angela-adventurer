extends CanvasLayer

@onready var resume_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/QuitButton

func _ready() -> void:
	resume_button.pressed.connect(_on_resume)
	quit_button.pressed.connect(_on_quit)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	visible = !visible
	get_tree().paused = visible

func _on_resume() -> void:
	toggle_pause()

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().quit()
