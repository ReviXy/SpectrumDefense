class_name LevelButton extends TextureButton

@onready var label = $Label
@onready var dottedLine = $DottedLine

func set_label(text):
	label.text = text

func set_dotted_line_visibility(vis):
	dottedLine.visible = vis

func disable():
	self.disabled = true
	(dottedLine.material as ShaderMaterial).set_shader_parameter("sourceColor", Color(0.4, 0.4, 0.4, 1.0))

func show_label():
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate", Color(1,1,1,1), 0.5)
	await tween.finished

func hide_label():
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate", Color(1,1,1,0), 0.5)
	await tween.finished

func on_toggle(toggled_on):
	if toggled_on: show_label()
	else: hide_label()

func _ready() -> void:
	label.modulate = Color(1,1,1,0)
	connect("toggled", on_toggle)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
