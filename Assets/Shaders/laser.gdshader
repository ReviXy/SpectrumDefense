shader_type spatial;
render_mode blend_mix;


uniform vec4 laser_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float glow_intensity : hint_range(0, 25) = 2.0;

void fragment() {
    ALBEDO = laser_color.rgb;
    EMISSION = laser_color.rgb * glow_intensity;
    ALPHA = laser_color.a;
}