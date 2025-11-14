extends Camera3D

var move_speed = 20
var zoom_speed = 0.5  # Скорость зума
var size_min = 5      # Минимальный размер
var size_max = 50     # Максимальный размер

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL

func _process(delta):
	var input_vector = Vector2(0, 0)
	
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1

	input_vector = input_vector.normalized()
	position += Vector3(input_vector.x, 0, input_vector.y) * move_speed * delta

func _input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				size = clamp(size - zoom_speed, size_min, size_max)
			MOUSE_BUTTON_WHEEL_DOWN:
				size = clamp(size + zoom_speed, size_min, size_max)
