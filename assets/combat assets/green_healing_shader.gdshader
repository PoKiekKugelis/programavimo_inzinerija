shader_type canvas_item;

uniform float fade_speed : hint_range(0.0, 1.0) = 0.3; // Control the speed of the fade effect

void fragment() {
    // Sample the texture's alpha value
    float tex_alpha = texture(TEXTURE, UV).a;

    // Calculate how much green color should be applied based on the vertical position
    float fade = smoothstep(0.0, 1.0, UV.y - fade_speed);

    // Final color: mix green with the texture based on the fading calculation
    COLOR = vec4(0.0, 1.0, 0.0, tex_alpha * fade); // Green with alpha fade
}