shader_type canvas_item;

uniform int color_scale; // 0 for viridis, 1 for inferno
uniform bool exaggerate_colors;
uniform bool display_BorA; // true for B, default

const vec4 vir_1 = vec4(51f/256f, 1f/256f, 63f/256f, 1);
const vec4 vir_6 = vec4(31f/256f, 158f/256f, 137f/256f, 1);
const vec4 vir_10 = vec4(253f/256f, 231f/256f, 37f/256f, 1);

const vec4 inf_1 = vec4(0, 0, 3f/256f, 1);
const vec4 inf_2 = vec4(120f/256f, 28f/256f, 109f/256f, 1);
const vec4 inf_3 = vec4(237f/256f, 104f/256f, 37f/256f, 1);
const vec4 inf_4 = vec4(252f/256f, 254f/256f, 164f/256f, 1);

void fragment() {
	
	vec4 c = texture(TEXTURE, UV);
	float val; 
	if(display_BorA) {
		val = c.b;
	}
	else {
		val = c.r;
	}
	
	if(exaggerate_colors) {
		val = val * 1.5; // exaggerate B value so we get more yellow
	}
	
	vec4 final_color;
	
	if(color_scale == 0) {
		float mix_factor;
		if(val < 0.6) {
			mix_factor = val * (1f / 0.6);
			final_color = mix(vir_1, vir_6, mix_factor);
		}
		else {
			mix_factor = (val - 0.6) * (1f / 0.4);
			final_color = mix(vir_6, vir_10, mix_factor);
		}
	}
	else if (color_scale == 1) {
		float mix_factor;
		if(val < 0.33) {
			mix_factor = val * (1f / 0.33);
			final_color = mix(inf_1, inf_2, mix_factor);
		}
		else if (val < 0.66) {
			mix_factor = (val - 0.33) * (1f / 0.33);
			final_color = mix(inf_2, inf_3, mix_factor);
		}
		else {
			mix_factor = (val - 0.66) * (1f / 0.33);
			final_color = mix(inf_3, inf_4, mix_factor);
		}
	}

	COLOR = final_color;
}