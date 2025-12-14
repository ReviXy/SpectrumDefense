shader_type spatial;
render_mode blend_mix;
uniform vec3 base_color : source_color = vec3(1.0);
uniform sampler2D base_texture;
uniform vec3 part_color : source_color = vec3(1.0);
uniform sampler2D part_mask;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 tex = texture(base_texture,UV).rgb;
	float mask = texture(part_mask, UV).r;
	vec3 part = part_color * mask;
	vec3 base = base_color * tex * (1.0-mask);
	ALBEDO = part + base;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
