extends Label

@export var lifetime: float = 1.0
@export var float_speed: float = 50.0
@export var fade_time: float = 0.3

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 50.0
var time: float = 0.0
var start_position: Vector2

@onready var tween: Tween

func _ready():
	set_process(false)
	visible = false

func show_damage(damage: float, damageCoefficient: float, color: ColorRYB_Operations.ColorRYB, position: Vector2):
	time = 0.0
	start_position = position
	global_position = position
	
	text = "%.1f" % damage
	if damageCoefficient == 0.25: text += " ↓"
	elif damageCoefficient == 2.0: text += " ↑"
	
	add_theme_color_override("font_color", ColorRYB_Operations.ToColor(color))
	
	# Случайное направление
	velocity = Vector2(
		randf_range(-150, 150),
		randf_range(-80, -150)
	)
	
	visible = true
	set_process(true)
	
	# Автоматическое скрытие через время жизни
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_end)

func _process(delta):
	time += delta
	
	velocity.y += gravity * delta
	global_position += velocity * delta
	
	if time > lifetime - fade_time:
		var alpha = (lifetime - time) / fade_time
		modulate.a = alpha

func _on_lifetime_end():
	set_process(false)
	visible = false
	
	# Возвращаем в пул
	if get_parent().has_method("return_damage_number"):
		get_parent().return_damage_number(self)
	else:
		queue_free()
