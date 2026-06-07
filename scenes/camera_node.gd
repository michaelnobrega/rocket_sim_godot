extends Camera2D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom *= (1.0 + Config.ZOOM_STEP)
			zoom = zoom.clamp(Vector2(Config.ZOOM_MIN, Config.ZOOM_MIN), Vector2(Config.ZOOM_MAX, Config.ZOOM_MAX))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom *= (1.0 - Config.ZOOM_STEP)
			zoom = zoom.clamp(Vector2(Config.ZOOM_MIN, Config.ZOOM_MIN), Vector2(Config.ZOOM_MAX, Config.ZOOM_MAX))
