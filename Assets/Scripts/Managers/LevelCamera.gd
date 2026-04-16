extends Camera3D

var pos: Vector3 = Vector3.UP*3
var dist = 25.0
var move_speed = 20
var zoom_speed = 0.5  # Скорость зума
@onready var vp : Viewport = get_viewport()
const sin45 = sqrt(2)/2

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#projection = Camera3D.PROJECTION_ORTHOGONAL

func _process(delta):
	var input_vector = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_S):
		input_vector.z += 1
	if Input.is_key_pressed(KEY_W):
		input_vector.z -= 1	
	if Input.is_key_pressed(KEY_SHIFT):
		input_vector.y -= 1
	if Input.is_key_pressed(KEY_SPACE):
		input_vector.y += 1

	input_vector = input_vector.normalized().rotated(Vector3.UP,rotation.y)
	#input_vector = global_basis * input_vector.normalized()
	pos += input_vector * move_speed * delta * max(dist,5)/25/Engine.time_scale
	if (input_vector.length() == 0 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		pos = lerp(pos, round(pos),0.05)
	position = pos + global_basis.z.normalized()*dist

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var input_vector = Vector3(event.relative.x/vp.size.y, event.relative.y/vp.size.y, 0)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			pos -= global_basis * (input_vector).rotated(Vector3.RIGHT,PI) * move_speed * max(dist,5)/25
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			rotation.x = clampf(rotation.x-input_vector.y*PI,-1.57,1.57)
			rotation.y -= input_vector.x*PI
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				dist = max(dist-1,0)
			MOUSE_BUTTON_WHEEL_DOWN:
				dist+=1
		size = max(dist,2)
