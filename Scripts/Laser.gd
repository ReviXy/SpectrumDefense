extends RayCast3D
@onready var beam_mesh = $BeamMesh
@onready var end_particles = $EndParticles
@onready var beam_particles = $BeamParticles

var tween: Tween
var beam_radius: float = 0.03
var max_beam_distance: float = 1000.0  # Максимальная дистанция луча
var is_hitting_mirror: bool = false  # Флаг столкновения с зеркалом

func _ready():
	await get_tree().create_timer(2.0).timeout
	deactivate(1)
	await get_tree().create_timer(2.0).timeout
	activate(1)

func _process(delta):
	var beam_length
	var end_position
	force_raycast_update()
	
	# Проверяем столкновение с объектом группы "Mirror"
	if is_colliding():
		var collider = get_collider()
		
		# Проверяем коллайдер и всех его родителей на наличие группы "Mirror"
		is_hitting_mirror = false
		var current_node = collider
		while current_node and not is_hitting_mirror:
			if current_node.is_in_group("Mirror"):
				is_hitting_mirror = true
			current_node = current_node.get_parent()
		
		# Выводим информацию о столкновении (можно убрать в финальной версии)
		if is_hitting_mirror:
			print("Луч попал в зеркало!")
		else:
			print("Луч попал в объект, но не в зеркало")
		
		# Получаем точку столкновения в локальных координатах
		end_position = to_local(get_collision_point())
		beam_length = end_position.y
	else:
		# Если нет коллизии, сбрасываем флаг
		is_hitting_mirror = false
		print("Луч не попал ни в один объект")
		
		# Если нет коллизии, луч простирается на максимальную дистанцию
		beam_length = -max_beam_distance
		end_position = Vector3(0, beam_length, 0)
	
	# Настраиваем меш луча
	beam_mesh.mesh.height = abs(beam_length)
	beam_mesh.position.y = beam_length / 2
	
	# Настраиваем частицы на конце
	end_particles.position = end_position
	beam_particles.position.y = beam_length / 2
	
	# Настраиваем количество частиц
	var particle_amount = snapped(abs(beam_length) * 50, 1)
	beam_particles.amount = max(1, particle_amount)
	
	# Настраиваем размер эмиттера частиц
	beam_particles.process_material.set_emission_box_extents(
		Vector3(beam_mesh.mesh.top_radius, abs(beam_length) / 2, beam_mesh.mesh.top_radius))

# Функция для проверки столкновения с зеркалом извне
func is_colliding_with_mirror() -> bool:
	return is_hitting_mirror

# Функция для получения информации о текущем столкновении
func get_collision_info() -> Dictionary:
	var info = {
		"is_colliding": is_colliding(),
		"is_mirror": is_hitting_mirror,
		"collision_point": get_collision_point() if is_colliding() else Vector3.ZERO,
		"collider": get_collider() if is_colliding() else null
	}
	return info

# Вспомогательная функция для проверки группы у объекта и его родителей
func is_in_group_or_parents(node: Node, group: String) -> bool:
	if not node:
		return false
	
	var current = node
	while current:
		if current.is_in_group(group):
			return true
		current = current.get_parent()
	
	return false

func activate(time: float):
	tween = get_tree().create_tween()
	visible = true
	beam_particles.emitting = true
	end_particles.emitting = true
	tween.set_parallel(true)
	tween.tween_property(beam_mesh.mesh, "top_radius", beam_radius, time)
	tween.tween_property(beam_mesh.mesh, "bottom_radius", beam_radius, time)
	tween.tween_property(beam_particles.process_material, "scale_min", 1, time)
	tween.tween_property(end_particles.process_material, "scale_min", 1, time)
	await tween.finished

func deactivate(time: float):
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(beam_mesh.mesh, "top_radius", 0.0, time)
	tween.tween_property(beam_mesh.mesh, "bottom_radius", 0.0, time)
	tween.tween_property(beam_particles.process_material, "scale_min", 0.0, time)
	tween.tween_property(end_particles.process_material, "scale_min", 0.0, time)
	await tween.finished
	visible = false
	beam_particles.emitting = false
	end_particles.emitting = false
