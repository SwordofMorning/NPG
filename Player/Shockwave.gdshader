shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform vec2 center;
uniform float force;
uniform float size;
uniform float ringColor_R;
uniform float ringColor_G;
uniform float ringColor_B;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Display chroma UV 
	//COLOR = vec4(UV, 0.0, 1.0);
	// Pan right 0.5 shader's size
	//COLOR = texture(TEXTURE, SCREEN_UV - vec2(0.5, 0));
	
	// Change Shader to Square, if the screen is Rect
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaledUV = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	// Mask to make a circle
	float mask = 1.0 - smoothstep(size-0.1, size, length(scaledUV - center));
	// now to make a ring
	mask *= smoothstep(size-0.15, size-0.1, length(scaledUV - center));
	
	// Generate a vector opposite to the center point for each pixel
	vec2 radiation_vec = normalize(scaledUV - center) * force * mask;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - radiation_vec);
	COLOR.rgb += 0.5 * vec3(mask) * vec3(ringColor_R, ringColor_G, ringColor_B);
	// To vertify mask is a circle
	//COLOR.rgb = vec3(mask);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
