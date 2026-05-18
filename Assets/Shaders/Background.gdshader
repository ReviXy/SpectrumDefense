shader_type canvas_item;

uniform sampler2D u_texture: filter_nearest, repeat_enable;
uniform float u_texture_scale = 1.0;
uniform float u_proportion: hint_range(0, 1) = 0.5; 

varying vec2 local_pos;

void vertex(){
	local_pos = VERTEX;
}

void fragment() {
	vec2 world_pos = (vec3(VERTEX, 1.0)).xy;

    vec2 texture_size = vec2(textureSize(u_texture, 0)) * u_texture_scale;
    vec2 uv = mod(local_pos, texture_size) / texture_size;
    
	vec4 color = texture(u_texture, uv);
	if (color.a == 0.0) COLOR = vec4(0.0);
	else COLOR = mix(vec4(0.0), color, u_proportion);
	
	COLOR.a = 1.0;
}
