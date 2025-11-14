extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var move_speed = 20

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
