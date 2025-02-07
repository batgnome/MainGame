shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform vec4 color = vec4(1.0, 1.0, 1.0, 0.1); // Albedo color with alpha transparency

void fragment() {
    ALBEDO = color.rgb;
    ALPHA = 0.1; // Controls transparency
}
