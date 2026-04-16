shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_front, depth_test_default;

uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform vec3 laser_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float noise_speed = 0.5;
uniform float texture_scale = 5.0;

// Параметры пульсации
uniform float pulse_speed = 5.0;
uniform float pulse_amplitude = 0.05;
uniform float pulse_offset = 0.0;

void vertex() {
	// Масштабируем UV по Y для контроля плотности текстуры
	UV.y = UV.y * texture_scale;
	
	// Пульсация радиуса
	// Используем синус от времени и позиции по Y для волнового эффекта
	float pulse = sin(TIME * pulse_speed + pulse_offset) * pulse_amplitude;
	
	// Получаем текущую позицию вершины в локальном пространстве
	vec3 local_pos = VERTEX;
	
	// Для цилиндра, ориентированного вдоль оси Y,
	// нормализуем XZ компоненты для получения направления от центра
	float radius = length(local_pos.xz);
	
	if (radius > 0.001) { // Избегаем деления на ноль
		vec2 direction = local_pos.xz / radius;
		// Смещаем вершину наружу/внутрь по направлению от центра
		local_pos.x += direction.x * pulse;
		local_pos.z += direction.y * pulse;
		
		// Обновляем вершину
		VERTEX = local_pos;
	}
}

void fragment() {
	// Шум движется только по локальной оси Y
	// UV.x остается статичным для обертывания вокруг цилиндра
	vec2 uv = vec2(UV.x, UV.y + TIME * noise_speed);
	
	float noise_value = texture(noise_texture, uv).r * texture(noise_texture, uv).r;
	
	ALBEDO = laser_color * noise_value;
	ALPHA = min(max(noise_value, 0.1) + 0.5, 1.0);
	//EMISSION = laser_color * 0.5;
}