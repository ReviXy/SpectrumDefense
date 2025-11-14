extends CanvasLayer

@onready var debugLabel = $DebugLabel

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		event = (event as InputEventKey)
		if event.pressed and event.keycode == KEY_Z:
			visible = !visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var draws = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var frameTime = Performance.get_monitor(Performance.TIME_PROCESS) * 1000
	var memory = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024 / 1024
	var str = ""
	str += "FPS: %.0f \n" % fps
	str += "Frame Time: %.0f ms\n" % frameTime
	str += "Memory: %.1f MB\n" % memory
	str += "Draws: %.0f " % draws
	debugLabel.text = str
