shader_type canvas_item;

uniform float outline_size = 1.0;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // white

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // If the current pixel is transparent, check for nearby opaque pixels
    if (tex.a < 0.1) {
        float alpha_sum = 0.0;
        for (float x = -outline_size; x <= outline_size; x++) {
            for (float y = -outline_size; y <= outline_size; y++) {
                vec2 offset = vec2(x, y) / TEXTURE_PIXEL_SIZE;
                vec4 sample = texture(TEXTURE, UV + offset);
                alpha_sum += step(0.1, sample.a);
            }
        }

        if (alpha_sum > 0.0) {
            COLOR = outline_color;
        }
    }

    COLOR = tex;
}
