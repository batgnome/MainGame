shader_type spatial;

uniform sampler2D viewport_tex;

void fragment() {
    vec4 color = texture(viewport_tex, UV);

    // Discard fully transparent pixels
    if (color.a < 0.1) {
        discard;
    }

    ALBEDO = color.rgb;
    ALPHA = color.a;
}
