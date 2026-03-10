extends Node
## Autoload singleton for persisting high scores.

const SAVE_PATH: String = "user://high_scores.json"
const MAX_SCORES: int = 5

var high_scores: Array[int] = []

func _ready() -> void:
	_load_scores()

func add_score(score: int) -> bool:
	"""Returns true if this score made the top list."""
	high_scores.append(score)
	high_scores.sort()
	high_scores.reverse()
	if high_scores.size() > MAX_SCORES:
		high_scores.resize(MAX_SCORES)
	_save_scores()
	return score in high_scores

func get_high_score() -> int:
	if high_scores.size() > 0:
		return high_scores[0]
	return 0

func get_scores() -> Array[int]:
	return high_scores

func _save_scores() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"scores": high_scores}))

func _load_scores() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	var result := json.parse(file.get_as_text())
	if result == OK and json.data is Dictionary:
		var data: Dictionary = json.data
		if data.has("scores") and data["scores"] is Array:
			high_scores.clear()
			for s in data["scores"]:
				high_scores.append(int(s))
