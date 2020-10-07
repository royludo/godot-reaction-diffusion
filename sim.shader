shader_type canvas_item;

uniform sampler2D previous_image;
uniform float DA;
uniform float f;
uniform float DB;
uniform float k;
uniform bool pause_shader;

vec4 get_neighbor_color(vec2 uv, vec2 offset, vec2 size) {
	float neighbor_x = clamp(uv.x + (offset.x * size.x), 0.001, 0.999);
	float neighbor_y = clamp(uv.y + (offset.y * size.y), 0.001, 0.999);
	
	return texture(previous_image, vec2( neighbor_x, neighbor_y));
}

float average_of_neighbors(vec4 straight, vec4 diag) {
	
	return straight[0] * 0.2 + straight[1] * 0.2 + straight[2] * 0.2 + straight[3] * 0.2 +
	diag[0] * 0.05 + diag[1] * 0.05 + diag[2] * 0.05 + diag[3] * 0.05;
}

vec4 get_straight_neighbors_r(vec2 uv, vec2 size) {
	float c_up = get_neighbor_color(uv, vec2(0,-1), size).r;
	float c_down = get_neighbor_color(uv, vec2(0,1), size).r;
	float c_left = get_neighbor_color(uv, vec2(-1,0), size).r;
	float c_right = get_neighbor_color(uv, vec2(1,0), size).r;
	
	return vec4(c_up, c_down, c_left, c_right);
}

vec4 get_diagonal_neighbors_r(vec2 uv, vec2 size) {
	float c_up_right = get_neighbor_color(uv, vec2(1,-1), size).r;
	float c_up_left = get_neighbor_color(uv, vec2(-1,-1), size).r;
	float c_down_right = get_neighbor_color(uv, vec2(1,1), size).r;
	float c_down_left = get_neighbor_color(uv, vec2(-1,1), size).r;
	
	return vec4(c_up_right, c_up_left, c_down_right, c_down_left);
}

vec4 get_straight_neighbors_b(vec2 uv, vec2 size) {
	float c_up = get_neighbor_color(uv, vec2(0,-1), size).b;
	float c_down = get_neighbor_color(uv, vec2(0,1), size).b;
	float c_left = get_neighbor_color(uv, vec2(-1,0), size).b;
	float c_right = get_neighbor_color(uv, vec2(1,0), size).b;
	
	return vec4(c_up, c_down, c_left, c_right);
}

vec4 get_diagonal_neighbors_b(vec2 uv, vec2 size) {
	float c_up_right = get_neighbor_color(uv, vec2(1,-1), size).b;
	float c_up_left = get_neighbor_color(uv, vec2(-1,-1), size).b;
	float c_down_right = get_neighbor_color(uv, vec2(1,1), size).b;
	float c_down_left = get_neighbor_color(uv, vec2(-1,1), size).b;
	
	return vec4(c_up_right, c_up_left, c_down_right, c_down_left);
}

void fragment() {
	
	if(pause_shader == true){
		COLOR = texture(previous_image, UV);
		return
	}
	else {
	
	float size_x = 1.0/TEXTURE_PIXEL_SIZE.x;
	float size_y = 1.0/TEXTURE_PIXEL_SIZE.y;
	
	int pixel_x = int(floor(size_x * UV.x));
	int pixel_y = int(floor(size_y * UV.y));
	//vec4 c_up = texelFetch(previous_image, ivec2(pixel_x, pixel_y - 1), 0);
	//vec4 c_up = texture(previous_image, vec2(UV.x * float(pixel_x), UV.y * float(pixel_y) ));
	//vec4 c_up = texture(previous_image, vec2(UV.x, UV.y - TEXTURE_PIXEL_SIZE.y));
	vec4 straight_r = get_straight_neighbors_r(UV, TEXTURE_PIXEL_SIZE);
	vec4 diag_r = get_diagonal_neighbors_r(UV, TEXTURE_PIXEL_SIZE);
	
	vec4 straight_b = get_straight_neighbors_b(UV, TEXTURE_PIXEL_SIZE);
	vec4 diag_b = get_diagonal_neighbors_b(UV, TEXTURE_PIXEL_SIZE);
	
	vec4 c = texture(previous_image, UV);
	
	float A = c.r;
	float B = c.b;
	
	float laplace_A = average_of_neighbors(straight_r, diag_r) - A;
	float laplace_B = average_of_neighbors(straight_b, diag_b) - B;
	
	//float local_average = -1.0 * A;
	//float average_diff = neighbor_average_A;// - local_average;
	float next_A;
	float next_B;
	/*if(stop_spread == true){
		next_A =  A + ((DA * laplace_A) - f * A);
	}
	else {
		next_A =  A + ((DA * laplace_A));// - fA * A);
	}*/
	
	next_A =  A + ((DA * laplace_A) - (A * B * B) + f * (1.0 - A));
	next_B =  B + ((DB * laplace_B) + (A * B * B) - (k + f) * B);
	
	COLOR = vec4(next_A, 0.0, next_B, 1.0);
	}
}
