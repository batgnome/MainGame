shader_type canvas_item;

uniform vec4 outline_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_thickness = 4.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (tex_color.a < 0.1) {
        vec2 offsets[8] = vec2[](
            vec2(-outline_thickness, -outline_thickness),
            vec2(0.0, -outline_thickness),
            vec2(outline_thickness, -outline_thickness),
            vec2(-outline_thickness, 0.0),
            vec2(outline_thickness, 0.0),
            vec2(-outline_thickness, outline_thickness),
            vec2(0.0, outline_thickness),
            vec2(outline_thickness, outline_thickness)
        );

        for (int i = 0; i < 8; i++) {
            vec4 sample = texture(TEXTURE, UV + offsets[i] / vec2(textureSize(TEXTURE, 0)));
            if (sample.a > 0.1) {
                COLOR = outline_color;

            }
        }
        discard;
    }

    COLOR = tex_color;
}
