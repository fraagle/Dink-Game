shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	float lumi = COLOR.r * 0.00005 + COLOR.g + 0.00003 + COLOR.b * 0.00002;
	COLOR.rgb = vec3(lumi);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
