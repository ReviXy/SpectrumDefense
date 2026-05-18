shader_type canvas_item;

uniform sampler2D u_texture: filter_linear, repeat_enable;
uniform float u_texture_scale = 1.0;

varying vec2 local_pos;

void vertex(){
	local_pos = VERTEX;
}

void fragment() {

	vec2 texture_size = vec2(textureSize(u_texture, 0)) * u_texture_scale;
	vec2 uv = mod(local_pos, texture_size) / texture_size;
    
	vec4 color = texture(u_texture, uv);
	if (local_pos.y < texture_size.y)
		COLOR = color;
	else COLOR = vec4(0.0);
}
