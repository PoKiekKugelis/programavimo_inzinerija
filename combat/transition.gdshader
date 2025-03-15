shader_type canvas_item;

uniform float fill: hint_range(-0.1, 1.) = 0.;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float mask = texture(TEXTURE, UV).r;
	vec3 black = vec3(0.);
	COLOR = vec4(black, step(mask, fill));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
