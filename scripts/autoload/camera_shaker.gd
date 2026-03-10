extends Node
## Autoload singleton for screen shake. Call CameraShaker.shake() from anywhere.

var camera: Camera2D = null
var shake_tween: Tween = null

func shake(intensity: float = 5.0, duration: float = 0.2) -> void:
	if not is_instance_valid(camera):
		camera = get_viewport().get_camera_2d()
	if not is_instance_valid(camera):
		return

	if shake_tween and shake_tween.is_running():
		shake_tween.kill()

	shake_tween = create_tween()
	var steps: int = int(duration / 0.03)
	for i in steps:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		shake_tween.tween_property(camera, "offset", offset, 0.03)
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.03)
