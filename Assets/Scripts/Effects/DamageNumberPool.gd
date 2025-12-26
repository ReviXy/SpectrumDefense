class_name DamageNumberPool extends SubViewport

var damage_pool = []
var active_numbers = []
var pool_size = 10
var damage_scene = preload("res://Assets/Scenes/Statuses/DamageNumber.tscn")

func _ready():
	# Предварительно создаем пул объектов
	for i in range(pool_size):
		var damage_number = damage_scene.instantiate()
		damage_number.visible = false
		add_child(damage_number)
		damage_pool.append(damage_number)

func get_damage_number():
	if damage_pool.size() > 0:
		var number = damage_pool.pop_back()
		active_numbers.append(number)
		return number
	else:
		# Если пул исчерпан, создаем новый объект
		var number = active_numbers.pop_front()
		active_numbers.append(number)
		return number

func return_damage_number(number):
	var index = active_numbers.find(number)
	if index != -1:
		active_numbers.remove_at(index)
		damage_pool.append(number)

func show_damage(damage: float, damageCoefficient: float, color: ColorRYB_Operations.ColorRYB):
	var damage_number = get_damage_number()
	if damage_number:
		damage_number.show_damage(damage, damageCoefficient, color, Vector2(size.x / 2 - damage_number.size.x / 2, size.y / 2 - damage_number.size.y / 2 - 20))
		active_numbers.append(damage_number)
