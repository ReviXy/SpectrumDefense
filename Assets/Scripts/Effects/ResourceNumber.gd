class_name ResourceNumber extends Label

@export var lifetime: float = 3.0
@export var fade_time: float = 1.0

var velocity: Vector2 = Vector2(0, -250)
var time: float = 0.0

func _ready():
	set_process(false)
	visible = false


func show_resource_gain(resource: float, position: Vector2):
	time = 0.0
	global_position = position
	
	text = "+%.0f$" % resource
	
	visible = true
	set_process(true)
	
	# Автоматическое скрытие через время жизни
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_end)

func _process(delta):
	time += delta

	global_position += velocity * delta
	
	if time > lifetime - fade_time:
		var alpha = (lifetime - time) / fade_time
		modulate.a = alpha

func _on_lifetime_end():
	queue_free()
