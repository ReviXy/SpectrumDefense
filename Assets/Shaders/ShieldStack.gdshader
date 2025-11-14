shader_type spatial;
render_mode shadows_disabled;
uniform vec3 fresnel_color: source_color;
uniform vec3 border_color: source_color;
uniform sampler2D _border_mask;
uniform float _fresnel_pow:hint_range(1, 8)=5;
uniform float _rotation:hint_range(0.0, 1.0);
uniform float _panning:hint_range(0.0, 1.0);
uniform float _displacement:hint_range(0.0, 1.0);

uniform sampler2D _noise;
varying float noise;

float remap(float value, float i_min, float i_max, float o_min, float o_max)
{
	return o_min + ((value-i_min) / (i_max-i_min) * (o_max - o_min));
}

vec2 remapV2(vec2 value, float i_min, float i_max, float o_min, float o_max)
{
	vec2 remapped;
	remapped.x = o_min + ((value.x-i_min) / (i_max-i_min) * (o_max - o_min));
	remapped.y = o_min + ((value.y-i_min) / (i_max-i_min) * (o_max - o_min));
	return remapped;
}

float saturate(float val)
{
	return clamp(val,0,1);
}

vec2 rotation(vec2 uv, vec2 center, float angle)
{
	mat2 rotation = mat2(vec2(cos(angle), -sin(angle)),
						vec2(sin(angle), cos(angle)));
	uv -= center;
	uv *= rotation;
	uv += center;
	return uv;
}

float fresnel(float power, vec3 normal, vec3 view)
{
	return pow(1.0-clamp(dot(normal,view),0.0,1.0),power);
}

void vertex() {
	// Called for every vertex the material is visible on.
	vec2 uv_normal = remapV2(NORMAL.xy,-1,1,0,1);
	uv_normal = rotation(uv_normal,vec2(0.5),TIME * _rotation);
	uv_normal += vec2(3,1) * TIME * _panning;
	noise = texture(_noise, uv_normal).r;
	VERTEX += noise * NORMAL * _displacement;
}

void fragment() {
	float hmask = texture(_border_mask,UV).r;
	vec3 color = border_color * hmask;
	float f = fresnel(_fresnel_pow,NORMAL,VIEW);
	vec3 color2 = fresnel_color * f;
	vec3 rcolor = max(color,color2);
	ALBEDO = rcolor;
	EMISSION = rcolor*12.;
	ALPHA = saturate(hmask*noise + f);
	// Called for every pixel the material is visible on.
}



//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
