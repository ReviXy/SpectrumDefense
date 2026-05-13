shader_type canvas_item;

uniform sampler2D u_texture: filter_nearest, repeat_enable;
uniform vec2 u_speed = vec2(0.5, 0.25);
uniform float u_texture_scale = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment()
{
    vec2 world_pos = (vec3(VERTEX, 1.0)).xy;
    vec2 offset = u_speed * TIME;

    vec2 texture_size = vec2(textureSize(u_texture, 0)) * u_texture_scale;
    vec2 uv = mod(world_pos, texture_size) / texture_size;
    
    COLOR = texture(u_texture, uv + offset);
}
